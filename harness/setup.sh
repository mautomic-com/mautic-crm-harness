#!/usr/bin/env bash
set -euo pipefail

# Setup script: links the plugin into a Mautic installation.
#
# Usage: ./harness/setup.sh /path/to/mautic /path/to/plugin
#
# This creates a symlink at MAUTIC/plugins/MautomicCrmBundle -> PLUGIN

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ $# -lt 2 ]]; then
    echo "Usage: $0 MAUTIC_PATH PLUGIN_PATH"
    echo ""
    echo "  MAUTIC_PATH  Path to your Mautic 7 installation"
    echo "  PLUGIN_PATH  Path to the mautic-crm-bundle repo checkout"
    echo ""
    echo "Example:"
    echo "  $0 /path/to/mautic-001 /path/to/mautic-crm-bundle"
    exit 1
fi

MAUTIC_PATH="$(cd "$1" && pwd)"
PLUGIN_PATH="$(cd "$2" && pwd)"
SYMLINK_TARGET="${MAUTIC_PATH}/plugins/MautomicCrmBundle"

echo "=== MautomicCrmBundle Setup ==="
echo "Mautic:  ${MAUTIC_PATH}"
echo "Plugin:  ${PLUGIN_PATH}"
echo "Symlink: ${SYMLINK_TARGET}"
echo ""

# Verify Mautic installation
if [[ ! -f "${MAUTIC_PATH}/bin/console" ]]; then
    echo "ERROR: ${MAUTIC_PATH} does not appear to be a Mautic installation (bin/console not found)."
    exit 1
fi

# Verify plugin repo
if [[ ! -f "${PLUGIN_PATH}/MautomicCrmBundle.php" ]]; then
    echo "ERROR: ${PLUGIN_PATH} does not appear to be the MautomicCrmBundle repo (MautomicCrmBundle.php not found)."
    exit 1
fi

# Create or update symlink
if [[ -L "${SYMLINK_TARGET}" ]]; then
    echo "Updating existing symlink..."
    rm "${SYMLINK_TARGET}"
elif [[ -d "${SYMLINK_TARGET}" ]]; then
    echo "ERROR: ${SYMLINK_TARGET} exists as a directory (not a symlink). Remove it manually first."
    exit 1
fi

ln -s "${PLUGIN_PATH}" "${SYMLINK_TARGET}"
echo "Symlink created: ${SYMLINK_TARGET} -> ${PLUGIN_PATH}"

# Clear Mautic cache
echo ""
echo "Clearing Mautic cache..."
cd "${MAUTIC_PATH}"
php bin/console cache:clear --no-warmup 2>/dev/null || true
echo ""
echo "Setup complete. Install/update the plugin via:"
echo "  cd ${MAUTIC_PATH} && php bin/console mautic:plugins:reload"
