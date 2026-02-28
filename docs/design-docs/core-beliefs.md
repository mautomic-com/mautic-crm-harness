# Core Beliefs — Agent-First Development Principles

These are non-negotiable operating principles for all work on MautomicCrmBundle.

## 1. Follow Mautic Patterns Exactly

Do not invent new conventions. Mautic 7 has established patterns for everything:
- Entities use `loadMetadata()` with `ClassMetadataBuilder` (not Doctrine annotations/attributes for ORM mapping)
- API metadata uses `loadApiMetadata()` with `ApiMetadataDriver`
- Validation uses `loadValidatorMetadata()` with Symfony constraints
- Controllers extend `AbstractStandardFormController` and delegate to `indexStandard()`, `newStandard()`, `editStandard()`, `viewStandard()`, `deleteStandard()`
- Models extend `FormModel` and implement `getRepository()`, `getEntity()`, `createForm()`, `getPermissionBase()`, `dispatchEvent()`
- Permissions extend `AbstractPermissions` with `addStandardPermissions()` and `addExtendedPermissions()`
- Config lives in `Config/config.php` (routes, menu, services) and `Config/services.php` (Symfony DI)

When in doubt, look at MauticFocusBundle — it's the canonical example of a feature plugin.

## 2. Mechanical Enforcement Over Documentation

Every rule that matters must be enforced by a script, linter, or CI check.
Documentation alone drifts. If a rule can't be checked mechanically, encode it as a test.

Examples:
- Coding standards → `composer cs` (PHP CS Fixer)
- Static analysis → `composer phpstan` (level 6)
- Architecture → `harness/validate-architecture.sh`
- Tests → `bin/phpunit`

## 3. Tests Are Mandatory

No code ships without tests. Minimum requirements:
- Every entity: unit test for getters/setters and `loadMetadata()` table name
- Every model: unit test for `getPermissionBase()`, `getRepository()`
- Every controller action: functional test using `MauticMysqlTestCase`
- Every API endpoint: functional test

Test naming: `{ClassName}Test.php` in `Tests/Unit/` or `Tests/Functional/`.

## 4. Translations, Never Hardcoded Strings

All user-facing strings go through Mautic's translation system:
- `Translations/en_US/messages.ini` for labels and UI text
- `Translations/en_US/flashes.ini` for flash messages
- `Translations/en_US/validators.ini` for validation errors

Translation key pattern: `mautomic_crm.{entity}.{context}` (e.g., `mautomic_crm.deal.name`).

## 5. Progressive Disclosure

Agents start with AGENTS.md (the map) and navigate to deeper docs as needed.
Don't put everything in one file. Keep docs focused and cross-linked.

## 6. Small, Focused PRs

Each PR should do one thing well. Prefer multiple small PRs over one large one.
Every PR must pass `harness/validate-pr.sh` before merge.

## 7. Agent-Legible Error Messages

Custom linters and validation scripts must produce error messages that tell agents
exactly what's wrong and how to fix it. Example:

Bad: "Architecture violation in Deal.php"
Good: "Entity Deal.php is missing loadMetadata() static method. Add: public static function loadMetadata(ORM\\ClassMetadata $metadata): void { ... } — see docs/references/mautic-entity-patterns.md"

## 8. Database Table Prefix

All plugin tables use the `mautomic_` prefix (before Mautic's own table prefix).
This avoids any collision with core Mautic tables or other plugins.
