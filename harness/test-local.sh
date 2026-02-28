#!/usr/bin/env bash
set -euo pipefail

# Local test runner for DDEV environments.
#
# Usage: ./harness/test-local.sh /path/to/mautic [filter]
#
# Runs tests inside the DDEV container.

if [[ $# -lt 1 ]]; then
    echo "Usage: $0 MAUTIC_PATH [FILTER]"
    echo ""
    echo "  MAUTIC_PATH  Path to Mautic DDEV project on host"
    echo "  FILTER       Optional PHPUnit --filter argument"
    exit 1
fi

MAUTIC_PATH="$(cd "$1" && pwd)"
FILTER="${2:-}"
PLUGIN_DIR="${MAUTIC_PATH}/plugins/MautomicCrmBundle"

if [[ ! -d "${PLUGIN_DIR}" ]]; then
    echo "ERROR: Plugin not found at ${PLUGIN_DIR}."
    exit 1
fi

if ! command -v ddev &> /dev/null; then
    echo "ERROR: ddev not found. Install ddev or use test.sh for non-DDEV environments."
    exit 1
fi

cd "${MAUTIC_PATH}"

OVERALL_EXIT=0

# --- Unit Tests ---
if [[ -d "${PLUGIN_DIR}/Tests/Unit" ]]; then
    echo "=== Unit Tests ==="
    UNIT_CMD="php bin/phpunit plugins/MautomicCrmBundle/Tests/Unit/ --testdox"
    if [[ -n "${FILTER}" ]]; then
        UNIT_CMD="php bin/phpunit --filter ${FILTER} plugins/MautomicCrmBundle/Tests/Unit/ --testdox"
    fi
    echo "Running: ddev exec ${UNIT_CMD}"
    echo ""
    if ddev exec ${UNIT_CMD}; then
        echo ""
        echo "Unit tests: PASSED"
    else
        OVERALL_EXIT=1
        echo ""
        echo "Unit tests: FAILED"
    fi
    echo ""
fi

# --- Functional Tests ---
if [[ -d "${PLUGIN_DIR}/Tests/Functional" ]]; then
    echo "=== Functional Tests ==="
    FUNC_CMD="php bin/phpunit -c app/phpunit.xml.dist plugins/MautomicCrmBundle/Tests/Functional/ --testdox"
    if [[ -n "${FILTER}" ]]; then
        FUNC_CMD="php bin/phpunit -c app/phpunit.xml.dist --filter ${FILTER} plugins/MautomicCrmBundle/Tests/Functional/ --testdox"
    fi
    echo "Running: ddev exec ${FUNC_CMD}"
    echo ""
    if ddev exec ${FUNC_CMD}; then
        echo ""
        echo "Functional tests: PASSED"
    else
        OVERALL_EXIT=1
        echo ""
        echo "Functional tests: FAILED"
    fi
    echo ""
fi

# --- Summary ---
echo "============================================"
if [[ ${OVERALL_EXIT} -eq 0 ]]; then
    echo "  ALL TESTS PASSED"
else
    echo "  SOME TESTS FAILED"
fi
echo "============================================"

exit ${OVERALL_EXIT}
