#!/usr/bin/env bash
set -euo pipefail

# Full PR validation pipeline. Runs all checks in sequence.
#
# Usage: ./harness/validate-pr.sh /path/to/mautic /path/to/plugin

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ $# -lt 2 ]]; then
    echo "Usage: $0 MAUTIC_PATH PLUGIN_PATH"
    exit 1
fi

MAUTIC_PATH="$(cd "$1" && pwd)"
PLUGIN_PATH="$(cd "$2" && pwd)"
OVERALL_EXIT=0

echo "============================================"
echo "  MautomicCrmBundle — Full PR Validation"
echo "============================================"
echo ""
echo "Mautic: ${MAUTIC_PATH}"
echo "Plugin: ${PLUGIN_PATH}"
echo ""

# Step 1: Architecture validation
echo "============================================"
echo "  Step 1/3: Architecture Validation"
echo "============================================"
if "${SCRIPT_DIR}/validate-architecture.sh" "${PLUGIN_PATH}"; then
    echo ""
else
    OVERALL_EXIT=1
    echo ""
fi

# Step 2: Lint (PHPStan + CS) — plugin only
echo "============================================"
echo "  Step 2/3: Lint (PHPStan + CS) — plugin only"
echo "============================================"
if "${SCRIPT_DIR}/lint.sh" "${MAUTIC_PATH}"; then
    echo ""
else
    OVERALL_EXIT=1
    echo ""
fi

# Step 3: Tests — plugin only
echo "============================================"
echo "  Step 3/3: Tests (PHPUnit) — plugin only"
echo "============================================"
if "${SCRIPT_DIR}/test.sh" "${MAUTIC_PATH}"; then
    echo ""
else
    OVERALL_EXIT=1
    echo ""
fi

# Summary
echo "============================================"
if [[ ${OVERALL_EXIT} -eq 0 ]]; then
    echo "  ALL CHECKS PASSED — PR is ready for review"
else
    echo "  SOME CHECKS FAILED — fix issues before merging"
fi
echo "============================================"

exit ${OVERALL_EXIT}
