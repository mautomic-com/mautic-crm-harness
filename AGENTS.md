# AGENTS.md — MautomicCrmBundle Development Harness

This is the **agent-first development harness** for the MautomicCrmBundle Mautic plugin.
It is the map — not the manual. Start here, then follow pointers to deeper docs.

## Quick Reference

| What                  | Where                                      |
|-----------------------|--------------------------------------------|
| Architecture overview | [ARCHITECTURE.md](ARCHITECTURE.md)         |
| Product specs         | [docs/product-specs/](docs/product-specs/) |
| Design docs           | [docs/design-docs/](docs/design-docs/)     |
| Execution plans       | [docs/exec-plans/](docs/exec-plans/)       |
| Coding standards      | [docs/CODING_STANDARDS.md](docs/CODING_STANDARDS.md) |
| Testing strategy      | [docs/TESTING.md](docs/TESTING.md)         |
| Quality scores        | [docs/QUALITY_SCORE.md](docs/QUALITY_SCORE.md) |
| Mautic references     | [docs/references/](docs/references/)       |

## Repository Layout

```
mautic-crm-harness/          # This repo — development infrastructure
mautic-crm-bundle/           # Sibling repo — the actual plugin code
mautic-001/                   # Sibling — Mautic 7 installation
```

## Core Beliefs

Read [docs/design-docs/core-beliefs.md](docs/design-docs/core-beliefs.md) before starting any work.

Summary:
1. Every quality rule must be mechanically enforced, not just documented.
2. Tests are mandatory — no PR merges without passing tests.
3. Follow Mautic 7 patterns exactly — don't invent new conventions.
4. Entities use `loadMetadata()` with `ClassMetadataBuilder`, not annotations/attributes for ORM.
5. Controllers extend `AbstractStandardFormController` for CRUD.
6. Models extend `FormModel` for entity business logic.
7. All strings go through translations (`messages.ini`), never hardcoded.

## Working on the Plugin

### Before making changes
1. Read the relevant product spec in `docs/product-specs/`
2. Check for an active execution plan in `docs/exec-plans/active/`
3. Review `docs/CODING_STANDARDS.md` for Mautic-specific rules

### After making changes
1. Run `harness/lint.sh` — must pass PHPStan level 6 and CS check
2. Run `harness/test.sh` — all PHPUnit tests must pass
3. Run `harness/validate-architecture.sh` — structural checks must pass
4. Update `docs/QUALITY_SCORE.md` if adding a new domain or layer

### Validating a PR
Run `harness/validate-pr.sh` which executes all of the above in sequence.

## Plugin Structure (mautic-crm-bundle/)

```
MautomicCrmBundle.php          # Bundle class (extends PluginBundleBase)
composer.json                  # type: mautic-plugin, requires mautic/core-lib ^7.0
Config/
  config.php                   # Routes, menu items, categories, parameters
  services.php                 # Symfony DI (autowire, autoconfigure)
Entity/                        # Doctrine entities + repositories
Controller/                    # CRUD controllers (extend AbstractStandardFormController)
  Api/                         # API controllers
Model/                         # Business logic (extend FormModel)
Form/Type/                     # Symfony form types
Security/Permissions/          # Permission definitions
EventListener/                 # Event subscribers
Event/                         # Custom event objects
Resources/views/               # Twig templates
Translations/en_US/            # Translation strings
Tests/
  Unit/                        # PHPUnit unit tests
  Functional/                  # PHPUnit functional tests (extend MauticMysqlTestCase)
```

## Key Entities

| Entity   | Table              | Purpose                                     |
|----------|--------------------|---------------------------------------------|
| Pipeline | mautomic_pipelines | Named sales pipeline (e.g., "Enterprise")   |
| Stage    | mautomic_stages    | Ordered step within a pipeline              |
| Deal     | mautomic_deals     | Revenue opportunity linked to contact/company|
| Task     | mautomic_tasks     | Action item with due date and assignee       |
| Note     | mautomic_notes     | Text record on a deal or contact             |

## Commands

All harness commands scope PHPStan and CS Fixer to the plugin only — never the full Mautic codebase.

```bash
# Setup (from harness repo root)
./harness/setup.sh /path/to/mautic /path/to/plugin

# CI / non-DDEV (runs php directly)
./harness/lint.sh /path/to/mautic           # PHPStan + CS on plugin only
./harness/test.sh /path/to/mautic           # Unit + Functional tests on plugin only
./harness/validate-architecture.sh /path/to/plugin
./harness/validate-pr.sh /path/to/mautic /path/to/plugin  # All 3 in sequence

# Local / DDEV (runs inside ddev container)
./harness/test-local.sh /path/to/mautic     # Unit + Functional tests via ddev
./harness/lint-local.sh /path/to/mautic     # PHPStan + CS via ddev
./harness/lint-local.sh /path/to/mautic --fix  # Auto-fix CS issues
```

### Quick DDEV one-liners (from Mautic root)

```bash
# Tests
ddev exec php bin/phpunit plugins/MautomicCrmBundle/Tests/Unit/ --testdox
ddev exec php bin/phpunit -c app/phpunit.xml.dist plugins/MautomicCrmBundle/Tests/Functional/ --testdox

# PHPStan (plugin only)
ddev exec php bin/phpstan analyse plugins/MautomicCrmBundle/ --level 6

# CS check (plugin only)
ddev exec bin/php-cs-fixer fix plugins/MautomicCrmBundle/ --dry-run --diff --config=.php-cs-fixer.php

# CS auto-fix (plugin only)
ddev exec bin/php-cs-fixer fix plugins/MautomicCrmBundle/ --config=.php-cs-fixer.php
```
