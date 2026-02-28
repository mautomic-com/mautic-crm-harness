#!/usr/bin/env bash
set -euo pipefail

# Lint script: runs PHPStan and coding standards checks on the plugin ONLY.
#
# Usage: ./harness/lint.sh /path/to/mautic
#
# Runs inside the Mautic directory but scopes all analysis to
# plugins/MautomicCrmBundle/ — never the whole Mautic codebase.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ $# -lt 1 ]]; then
    echo "Usage: $0 MAUTIC_PATH"
    echo ""
    echo "  MAUTIC_PATH  Path to Mautic installation with plugin symlinked in"
    exit 1
fi

MAUTIC_PATH="$(cd "$1" && pwd)"
PLUGIN_REL="plugins/MautomicCrmBundle"
PLUGIN_DIR="${MAUTIC_PATH}/${PLUGIN_REL}"
EXIT_CODE=0

if [[ ! -d "${PLUGIN_DIR}" ]]; then
    echo "ERROR: Plugin not found at ${PLUGIN_DIR}. Run setup.sh first."
    exit 1
fi

echo "=== MautomicCrmBundle Lint ==="
echo "Mautic: ${MAUTIC_PATH}"
echo "Plugin: ${PLUGIN_DIR}"
echo ""

cd "${MAUTIC_PATH}"

# --- PHPStan ---
echo "--- PHPStan (level 6) — plugin only ---"
PHPSTAN_BIN=""
if [[ -x "bin/phpstan" ]]; then
    PHPSTAN_BIN="php bin/phpstan"
elif [[ -f "vendor/bin/phpstan" ]]; then
    PHPSTAN_BIN="php vendor/bin/phpstan"
elif command -v phpstan &> /dev/null; then
    PHPSTAN_BIN="phpstan"
fi

if [[ -z "${PHPSTAN_BIN}" ]]; then
    echo "SKIP — phpstan binary not found"
else
    if ${PHPSTAN_BIN} analyse "${PLUGIN_REL}/" --level=6 --no-progress 2>&1; then
        echo "PHPStan: PASSED"
    else
        echo "PHPStan: FAILED"
        EXIT_CODE=1
    fi
fi
echo ""

# --- Coding Standards ---
echo "--- Coding Standards (PHP CS Fixer) — plugin only ---"
CSFIXER_BIN=""
if [[ -x "bin/php-cs-fixer" ]]; then
    CSFIXER_BIN="bin/php-cs-fixer"
elif [[ -f "vendor/bin/php-cs-fixer" ]]; then
    CSFIXER_BIN="php vendor/bin/php-cs-fixer"
elif command -v php-cs-fixer &> /dev/null; then
    CSFIXER_BIN="php-cs-fixer"
fi

if [[ -z "${CSFIXER_BIN}" ]]; then
    echo "SKIP — php-cs-fixer binary not found"
else
    if ${CSFIXER_BIN} fix "${PLUGIN_REL}/" --dry-run --diff --config=.php-cs-fixer.php 2>&1; then
        echo "CS Check: PASSED"
    else
        echo "CS Check: FAILED"
        echo ""
        echo "REMEDIATION: Run '${CSFIXER_BIN} fix ${PLUGIN_REL}/ --config=.php-cs-fixer.php' to auto-fix."
        EXIT_CODE=1
    fi
fi
echo ""

if [[ ${EXIT_CODE} -eq 0 ]]; then
    echo "=== All lint checks PASSED ==="
else
    echo "=== Some lint checks FAILED (exit code: ${EXIT_CODE}) ==="
fi

exit ${EXIT_CODE}
