#!/usr/bin/env bash
set -euo pipefail

# Architecture validation: checks plugin structure follows Mautic patterns.
#
# Usage: ./harness/validate-architecture.sh /path/to/plugin

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ $# -lt 1 ]]; then
    echo "Usage: $0 PLUGIN_PATH"
    exit 1
fi

PLUGIN_PATH="$(cd "$1" && pwd)"
EXIT_CODE=0

echo "=== Architecture Validation ==="
echo "Plugin: ${PLUGIN_PATH}"
echo ""

# Check bundle class exists
echo -n "Bundle class (MautomicCrmBundle.php)... "
if [[ -f "${PLUGIN_PATH}/MautomicCrmBundle.php" ]]; then
    if grep -q 'extends PluginBundleBase' "${PLUGIN_PATH}/MautomicCrmBundle.php"; then
        echo "OK"
    else
        echo "FAIL — must extend PluginBundleBase"
        EXIT_CODE=1
    fi
else
    echo "FAIL — file not found. Create MautomicCrmBundle.php extending Mautic\\PluginBundle\\Bundle\\PluginBundleBase"
    EXIT_CODE=1
fi

# Check composer.json
echo -n "composer.json... "
if [[ -f "${PLUGIN_PATH}/composer.json" ]]; then
    if grep -q '"type": "mautic-plugin"' "${PLUGIN_PATH}/composer.json"; then
        echo "OK"
    else
        echo "FAIL — type must be 'mautic-plugin'"
        EXIT_CODE=1
    fi
else
    echo "FAIL — file not found"
    EXIT_CODE=1
fi

# Check config files
echo -n "Config/config.php... "
if [[ -f "${PLUGIN_PATH}/Config/config.php" ]]; then
    echo "OK"
else
    echo "FAIL — Config/config.php not found. This file defines routes, menu items, and services."
    EXIT_CODE=1
fi

echo -n "Config/services.php... "
if [[ -f "${PLUGIN_PATH}/Config/services.php" ]]; then
    echo "OK"
else
    echo "FAIL — Config/services.php not found. This file configures Symfony DI autowiring."
    EXIT_CODE=1
fi

# Check entities have loadMetadata
echo ""
echo "--- Entity Checks ---"
for entity_file in "${PLUGIN_PATH}"/Entity/*.php; do
    [[ -f "${entity_file}" ]] || continue
    filename=$(basename "${entity_file}")

    # Skip repositories
    if [[ "${filename}" == *Repository.php ]]; then
        continue
    fi

    echo -n "Entity ${filename}: loadMetadata()... "
    if grep -q 'function loadMetadata' "${entity_file}"; then
        echo "OK"
    else
        echo "FAIL — Entity must have: public static function loadMetadata(ORM\\ClassMetadata \$metadata): void"
        EXIT_CODE=1
    fi

    echo -n "Entity ${filename}: setTable()... "
    if grep -q "setTable(" "${entity_file}"; then
        echo "OK"
    else
        echo "FAIL — loadMetadata() must call \$builder->setTable('mautomic_...')"
        EXIT_CODE=1
    fi
done

# Check repositories extend CommonRepository
echo ""
echo "--- Repository Checks ---"
for repo_file in "${PLUGIN_PATH}"/Entity/*Repository.php; do
    [[ -f "${repo_file}" ]] || continue
    filename=$(basename "${repo_file}")

    echo -n "Repository ${filename}: extends CommonRepository... "
    if grep -q 'extends CommonRepository' "${repo_file}"; then
        echo "OK"
    else
        echo "FAIL — Repository must extend Mautic\\CoreBundle\\Entity\\CommonRepository"
        EXIT_CODE=1
    fi

    echo -n "Repository ${filename}: getTableAlias()... "
    if grep -q 'function getTableAlias' "${repo_file}"; then
        echo "OK"
    else
        echo "FAIL — Repository must implement getTableAlias(): string"
        EXIT_CODE=1
    fi
done

# Check models extend FormModel
echo ""
echo "--- Model Checks ---"
for model_file in "${PLUGIN_PATH}"/Model/*Model.php; do
    [[ -f "${model_file}" ]] || continue
    filename=$(basename "${model_file}")

    echo -n "Model ${filename}: extends FormModel... "
    if grep -q 'extends FormModel' "${model_file}"; then
        echo "OK"
    else
        echo "FAIL — Model must extend Mautic\\CoreBundle\\Model\\FormModel"
        EXIT_CODE=1
    fi

    echo -n "Model ${filename}: getPermissionBase()... "
    if grep -q 'function getPermissionBase' "${model_file}"; then
        echo "OK"
    else
        echo "FAIL — Model must implement getPermissionBase(): string"
        EXIT_CODE=1
    fi
done

# Check permissions class
echo ""
echo "--- Permission Checks ---"
echo -n "Permissions class... "
if [[ -f "${PLUGIN_PATH}/Security/Permissions/MautomicCrmPermissions.php" ]]; then
    if grep -q 'extends AbstractPermissions' "${PLUGIN_PATH}/Security/Permissions/MautomicCrmPermissions.php"; then
        echo "OK"
    else
        echo "FAIL — must extend Mautic\\CoreBundle\\Security\\Permissions\\AbstractPermissions"
        EXIT_CODE=1
    fi
else
    echo "FAIL — Security/Permissions/MautomicCrmPermissions.php not found"
    EXIT_CODE=1
fi

# Check translations
echo ""
echo "--- Translation Checks ---"
echo -n "Translations/en_US/messages.ini... "
if [[ -f "${PLUGIN_PATH}/Translations/en_US/messages.ini" ]]; then
    echo "OK"
else
    echo "FAIL — translations file not found"
    EXIT_CODE=1
fi

# Summary
echo ""
if [[ ${EXIT_CODE} -eq 0 ]]; then
    echo "=== All architecture checks PASSED ==="
else
    echo "=== Some architecture checks FAILED ==="
    echo "See docs/references/mautic-entity-patterns.md and docs/references/mautic-plugin-system.md for guidance."
fi

exit ${EXIT_CODE}
