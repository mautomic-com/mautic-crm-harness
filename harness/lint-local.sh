#!/usr/bin/env bash
set -euo pipefail

# Local lint runner for DDEV environments.
#
# Usage: ./harness/lint-local.sh /path/to/mautic [--fix]
#
# Runs PHPStan and CS Fixer inside the DDEV container,
# scoped to plugins/MautomicCrmBundle/ only.
#
# Pass --fix to auto-fix coding standards issues.

if [[ $# -lt 1 ]]; then
    echo "Usage: $0 MAUTIC_PATH [--fix]"
    echo ""
    echo "  MAUTIC_PATH  Path to Mautic DDEV project on host"
    echo "  --fix        Auto-fix coding standards issues"
    exit 1
fi

MAUTIC_PATH="$(cd "$1" && pwd)"
FIX_MODE="${2:-}"
PLUGIN_DIR="${MAUTIC_PATH}/plugins/MautomicCrmBundle"
PLUGIN_REL="plugins/MautomicCrmBundle"

if [[ ! -d "${PLUGIN_DIR}" ]]; then
    echo "ERROR: Plugin not found at ${PLUGIN_DIR}."
    exit 1
fi

if ! command -v ddev &> /dev/null; then
    echo "ERROR: ddev not found. Install ddev or use lint.sh for non-DDEV environments."
    exit 1
fi

cd "${MAUTIC_PATH}"

OVERALL_EXIT=0

# --- PHPStan ---
echo "=== PHPStan (level 6) — plugin only ==="
echo ""
if ddev exec php bin/phpstan analyse "${PLUGIN_REL}/" --level=6 --no-progress; then
    echo ""
    echo "PHPStan: PASSED"
else
    OVERALL_EXIT=1
    echo ""
    echo "PHPStan: FAILED"
fi
echo ""

# --- Coding Standards ---
if [[ "${FIX_MODE}" == "--fix" ]]; then
    echo "=== CS Fixer (auto-fix mode) — plugin only ==="
    echo ""
    if ddev exec bin/php-cs-fixer fix "${PLUGIN_REL}/" --config=.php-cs-fixer.php; then
        echo ""
        echo "CS Fix: DONE"
    else
        OVERALL_EXIT=1
        echo ""
        echo "CS Fix: FAILED"
    fi
else
    echo "=== CS Fixer (dry-run) — plugin only ==="
    echo ""
    if ddev exec bin/php-cs-fixer fix "${PLUGIN_REL}/" --dry-run --diff --config=.php-cs-fixer.php; then
        echo ""
        echo "CS Check: PASSED"
    else
        OVERALL_EXIT=1
        echo ""
        echo "CS Check: FAILED — run with --fix to auto-fix"
    fi
fi
echo ""

# --- Summary ---
echo "============================================"
if [[ ${OVERALL_EXIT} -eq 0 ]]; then
    echo "  ALL LINT CHECKS PASSED"
else
    echo "  SOME LINT CHECKS FAILED"
fi
echo "============================================"

exit ${OVERALL_EXIT}
