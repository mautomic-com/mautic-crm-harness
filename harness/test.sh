#!/usr/bin/env bash
set -euo pipefail

# Test script: runs PHPUnit tests for the plugin.
#
# Usage: ./harness/test.sh /path/to/mautic [filter]
#
# Runs unit tests directly, and functional tests with Mautic's phpunit config
# to ensure KERNEL_CLASS and test database are available.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ $# -lt 1 ]]; then
    echo "Usage: $0 MAUTIC_PATH [FILTER]"
    echo ""
    echo "  MAUTIC_PATH  Path to Mautic installation with plugin installed"
    echo "  FILTER       Optional PHPUnit --filter argument"
    exit 1
fi

MAUTIC_PATH="$(cd "$1" && pwd)"
FILTER="${2:-}"
PLUGIN_DIR="${MAUTIC_PATH}/plugins/MautomicCrmBundle"

if [[ ! -d "${PLUGIN_DIR}" ]]; then
    echo "ERROR: Plugin not found at ${PLUGIN_DIR}. Run setup.sh first."
    exit 1
fi

if [[ ! -d "${PLUGIN_DIR}/Tests" ]]; then
    echo "WARNING: No Tests/ directory found in plugin. Nothing to run."
    exit 0
fi

echo "=== MautomicCrmBundle Tests ==="
echo "Mautic: ${MAUTIC_PATH}"
echo "Plugin: ${PLUGIN_DIR}"
echo ""

cd "${MAUTIC_PATH}"

OVERALL_EXIT=0

# --- Unit Tests ---
UNIT_DIR="plugins/MautomicCrmBundle/Tests/Unit/"
if [[ -d "${PLUGIN_DIR}/Tests/Unit" ]]; then
    echo "--- Unit Tests ---"
    UNIT_ARGS="${UNIT_DIR}"
    if [[ -n "${FILTER}" ]]; then
        UNIT_ARGS="--filter ${FILTER} ${UNIT_ARGS}"
    fi
    echo "Running: bin/phpunit ${UNIT_ARGS}"
    if php bin/phpunit ${UNIT_ARGS}; then
        echo ""
        echo "Unit tests: PASSED"
    else
        OVERALL_EXIT=1
        echo ""
        echo "Unit tests: FAILED"
    fi
    echo ""
fi

# --- Functional Tests (require Mautic's phpunit config for KERNEL_CLASS, DB) ---
FUNC_DIR="plugins/MautomicCrmBundle/Tests/Functional/"
if [[ -d "${PLUGIN_DIR}/Tests/Functional" ]]; then
    echo "--- Functional Tests ---"
    FUNC_ARGS="-c app/phpunit.xml.dist ${FUNC_DIR}"
    if [[ -n "${FILTER}" ]]; then
        FUNC_ARGS="-c app/phpunit.xml.dist --filter ${FILTER} ${FUNC_DIR}"
    fi
    echo "Running: bin/phpunit ${FUNC_ARGS}"
    if php bin/phpunit ${FUNC_ARGS}; then
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
