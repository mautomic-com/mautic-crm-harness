#!/usr/bin/env bash
set -euo pipefail

# Preview a feature branch with a fresh Mautic install and test data.
#
# Usage:
#   ./harness/preview.sh MAUTIC_PATH ISSUE_OR_BRANCH
#
# Examples:
#   ./harness/preview.sh . 38
#   ./harness/preview.sh . feature/38-task-link-on-deal
#   ./harness/preview.sh . main
#
# What it does:
#   1. Checks out the specified branch in the plugin repo
#   2. Drops and recreates the Mautic database
#   3. Runs mautic:install
#   4. Patches config (API, mailer)
#   5. Seeds realistic test data (contacts, companies, pipelines, deals, tasks, notes)
#   6. Prints the URL to visit

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ $# -lt 2 ]]; then
    echo "Usage: $0 MAUTIC_PATH ISSUE_OR_BRANCH"
    echo ""
    echo "  MAUTIC_PATH       Path to Mautic DDEV project (usually .)"
    echo "  ISSUE_OR_BRANCH   GitHub issue number (e.g. 38) or full branch name"
    echo ""
    echo "Examples:"
    echo "  $0 . 38                              # looks up branch for issue #38"
    echo "  $0 . feature/38-task-link-on-deal    # explicit branch"
    echo "  $0 . main                            # preview current main"
    exit 1
fi

MAUTIC_PATH="$(cd "$1" && pwd)"
ISSUE_OR_BRANCH="$2"
PLUGIN_DIR="${MAUTIC_PATH}/plugins/MautomicCrmBundle"
SITE_URL="https://mautic-001.ddev.site"
ADMIN_USER="admin"
ADMIN_PASS="Maut1cR0cks!"

if [[ ! -d "${PLUGIN_DIR}" ]]; then
    echo "ERROR: Plugin not found at ${PLUGIN_DIR}"
    exit 1
fi

if ! command -v ddev &> /dev/null; then
    echo "ERROR: ddev not found."
    exit 1
fi

# --- Resolve branch name ---
cd "${PLUGIN_DIR}"

if [[ "${ISSUE_OR_BRANCH}" == "main" ]]; then
    BRANCH="main"
elif [[ "${ISSUE_OR_BRANCH}" =~ ^[0-9]+$ ]]; then
    # Numeric — look for a branch matching this issue number
    BRANCH=$(git branch -r | grep -E "origin/feature/${ISSUE_OR_BRANCH}-" | head -1 | sed 's|origin/||;s/^[[:space:]]*//')
    if [[ -z "${BRANCH}" ]]; then
        echo "ERROR: No branch found for issue #${ISSUE_OR_BRANCH}"
        echo "Available feature branches:"
        git branch -r | grep "origin/feature/" | sed 's|origin/||;s/^[[:space:]]*//'
        exit 1
    fi
    echo "Resolved issue #${ISSUE_OR_BRANCH} → branch: ${BRANCH}"
else
    BRANCH="${ISSUE_OR_BRANCH}"
fi

# --- Checkout branch ---
echo ""
echo "=== Step 1: Checkout branch '${BRANCH}' ==="
git fetch origin
if git show-ref --verify --quiet "refs/heads/${BRANCH}"; then
    git checkout "${BRANCH}"
    git pull origin "${BRANCH}"
else
    git checkout -b "${BRANCH}" "origin/${BRANCH}"
fi
echo "On branch: $(git branch --show-current)"

# --- Wipe and reinstall Mautic ---
cd "${MAUTIC_PATH}"

echo ""
echo "=== Step 2: Wipe database and reinstall Mautic ==="
ddev exec php bin/console doctrine:database:drop --force 2>/dev/null || true
ddev exec php bin/console doctrine:database:create
ddev exec rm -f config/local.php
ddev exec php bin/console mautic:install "${SITE_URL}" --force \
    --db_driver=pdo_mysql --db_host=db --db_port=3306 --db_name=db --db_user=db --db_password=db \
    --admin_firstname=Admin --admin_lastname=User --admin_username="${ADMIN_USER}" \
    --admin_email=admin@mautic.local --admin_password="${ADMIN_PASS}"

echo ""
echo "=== Step 3: Patch config ==="
cat > "${MAUTIC_PATH}/_preview_config_patch.php" << 'PHPEOF'
<?php
include 'config/local.php';
$parameters['api_enabled'] = true;
$parameters['api_enable_basic_auth'] = true;
$parameters['mailer_dsn'] = 'smtp://localhost:1025';
$parameters['mailer_from_email'] = 'mautic@ddev.local';
$parameters['mailer_from_name'] = 'DDEV';
$parameters['install_source'] = 'DDEV';
file_put_contents('config/local.php', "<?php\n\$parameters = " . var_export($parameters, true) . ";\n");
echo "Config patched.\n";
PHPEOF
sleep 2  # wait for DDEV/Mutagen file sync
ddev exec php _preview_config_patch.php
rm -f "${MAUTIC_PATH}/_preview_config_patch.php"

echo ""
echo "=== Step 4: Clear cache ==="
ddev exec rm -rf var/cache

echo ""
echo "=== Step 5: Seed test data ==="
ddev exec php plugins/MautomicCrmBundle/Tests/Fixtures/seed-preview-data.php

echo ""
echo "============================================"
echo "  PREVIEW READY"
echo "============================================"
echo ""
echo "  URL:      ${SITE_URL}/s/mautomic/deals"
echo "  Login:    ${ADMIN_USER} / ${ADMIN_PASS}"
echo "  Branch:   ${BRANCH}"
echo ""
echo "  Quick links:"
echo "    Deals:      ${SITE_URL}/s/mautomic/deals"
echo "    Pipelines:  ${SITE_URL}/s/mautomic/pipelines"
echo "    Tasks:      ${SITE_URL}/s/mautomic/tasks"
echo "    Dashboard:  ${SITE_URL}/s/mautomic/dashboard"
echo ""
