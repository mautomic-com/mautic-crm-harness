# AGENTS.md — MautomicCrmBundle Development Harness

This is the **agent-first development harness** for the MautomicCrmBundle Mautic plugin.
It is the map — not the manual. Start here, then follow pointers to deeper docs.

## Quick Reference

| What                  | Where                                      |
|-----------------------|--------------------------------------------|
| Architecture overview | [ARCHITECTURE.md](ARCHITECTURE.md)         |
| Product specs         | [docs/product-specs/](docs/product-specs/) |
| Design docs           | [docs/design-docs/](docs/design-docs/)     |
| Feature backlog       | [docs/exec-plans/backlog/](docs/exec-plans/backlog/) |
| Feature template      | [docs/exec-plans/templates/FEATURE_TEMPLATE.md](docs/exec-plans/templates/FEATURE_TEMPLATE.md) |
| Completed features    | [docs/exec-plans/done/](docs/exec-plans/done/) |
| Coding standards      | [docs/CODING_STANDARDS.md](docs/CODING_STANDARDS.md) |
| Testing strategy      | [docs/TESTING.md](docs/TESTING.md)         |
| Mautic references     | [docs/references/](docs/references/)       |

## Repositories

| Repo | GitHub | Purpose |
|------|--------|---------|
| mautic-crm-bundle | [mautomic-com/mautic-crm-bundle](https://github.com/mautomic-com/mautic-crm-bundle) | The actual plugin code |
| mautic-crm-harness | [mautomic-com/mautic-crm-harness](https://github.com/mautomic-com/mautic-crm-harness) | Development infrastructure, specs, backlog |
| mautic-001 | Local only (Mautic fork) | Mautic 7 installation for local dev |

### Local Layout

```
/Users/maciejlukianski/projects/mautic/
├── mautic-crm-harness/     # This repo (specs, backlog, harness scripts)
└── mautic-001/              # Mautic 7 installation (DO NOT MODIFY)
    └── plugins/
        └── MautomicCrmBundle/  # Plugin code — its own git repo → mautomic-com/mautic-crm-bundle
```

The plugin directory inside Mautic is a separate git repo.
This is the **workspace** the agent opens in Cursor.

## Golden Rule

**Do NOT modify any files in the Mautic installation.** The Mautic repo is upstream.
Only modify files inside `plugins/MautomicCrmBundle/` — that is the plugin repo workspace.
The plugin repo has its own `AGENTS.md` and `CLAUDE.md` as entry points.

When the agent works on a feature:
- Workspace = `mautic-001/plugins/MautomicCrmBundle/` (the plugin git repo)
- Mautic is infrastructure only — cloned by CI from `https://github.com/mautic/mautic.git` branch `7.x`
- No custom config, no custom AGENTS.md, no patches to Mautic — everything self-contained in the plugin

## CI Architecture

GitHub Actions in the plugin repo (`.github/workflows/pr-validate.yml`) runs 4 jobs:

1. **Lint (PHPStan + CS)** — clones Mautic, symlinks plugin, builds test cache, runs phpstan level 6 + cs-fixer
2. **Unit Tests** — clones Mautic, symlinks plugin, runs `bin/phpunit` on Unit tests
3. **Functional Tests** — same + MySQL 8.4 service, runs functional tests with MauticMysqlTestCase
4. **Architecture Validation** — standalone checks on plugin structure

Key CI details matching Mautic's own CI:
- PHPStan needs `var/cache/test/AppKernelTestDebugContainer.xml` — built by `APP_ENV=test bin/console`
- Uses `bin/phpstan` and `bin/php-cs-fixer` (not vendor/bin/)
- Functional tests use `.env.test` from Mautic + dynamic `DB_PORT` from service
- No `mautic:install` needed — test framework handles DB setup

Branch protection on `main` requires all 4 CI jobs to pass before merging.

## Core Beliefs

Read [docs/design-docs/core-beliefs.md](docs/design-docs/core-beliefs.md) before starting any work.

Summary:
1. Every quality rule must be mechanically enforced, not just documented.
2. Tests are mandatory — no PR merges without passing tests.
3. Follow Mautic 7 patterns exactly — don't invent new conventions.
4. Entities use `loadMetadata()` with `ClassMetadataBuilder`, not annotations/attributes.
5. Controllers extend `AbstractStandardFormController` for CRUD.
6. Models extend `FormModel` for entity business logic.
7. All strings go through translations (`messages.ini`), never hardcoded.
8. **Every bug found becomes a test** — regressions are unacceptable.
9. **Never modify upstream Mautic files** — the plugin must be self-contained.

---

## Agent Workflow: Feature Implementation

**This is the mandatory workflow for every feature. Do not skip steps.**

### Step 1: Read the Feature Spec

```
Read docs/exec-plans/backlog/feature-NNN-*.md
```

Understand all acceptance criteria, browser smoke tests, and technical notes.
If anything is unclear, ask before starting.

### Step 2: Create a Feature Branch

```bash
cd /path/to/mautic-001/plugins/MautomicCrmBundle
git checkout main && git pull
git checkout -b feature/NNN-short-name
```

### Step 3: Build the Feature

Write the code following Mautic patterns. Reference `docs/references/` if needed.

### Step 4: Run Automated Checks (ALL must pass)

```bash
# From Mautic root
../mautic-crm-harness/harness/test-local.sh .      # Unit + Functional tests
../mautic-crm-harness/harness/lint-local.sh .       # PHPStan + CS Fixer
```

If tests fail, fix them. If PHPStan reports errors, fix them.
**Do NOT proceed until all checks pass.**

### Step 5: Browser Smoke Tests (MANDATORY)

Open the Mautic UI at `https://mautic-001.ddev.site` using the browser tools
(Cursor IDE browser MCP or browser-use subagent).

Execute **every** browser smoke test listed in the feature spec.
For each test:
1. Navigate to the specified URL
2. Perform the specified actions
3. Verify the expected result
4. If it fails → fix the code → re-run automated checks → retry

**You must verify EVERY smoke test passes before proceeding.**

Login credentials: `admin` / `Maut1cR0cks!`

### Step 6: Push and Create PR

```bash
git add -A
git commit -m "feat: [description of what was built]"
git push -u origin feature/NNN-short-name
gh pr create --title "Feature NNN: [title]" --body "..."
```

The PR body must include:
- Summary of changes
- Test results (number of tests, all passing)
- Browser smoke test results (each test listed with PASS)
- Any decisions made (add to feature spec decision log)

### Step 7: Wait for CI

GitHub Actions will run automatically on the PR:
- PHPStan level 6
- Coding Standards
- Unit Tests
- Functional Tests
- Architecture Validation

**If CI fails, fix the issue and push again. Do NOT report back until CI is green.**

### Step 8: Report Back

Only after ALL of the following are true:
- [ ] All automated checks pass locally
- [ ] All browser smoke tests pass
- [ ] PR is created
- [ ] CI is green

Report back with:
1. PR URL
2. Summary of what was built
3. Any decisions or trade-offs made
4. Updated feature spec (move to `docs/exec-plans/done/` if complete)

---

## Plugin Structure

```
MautomicCrmBundle/
├── .github/workflows/     # CI pipeline
├── Config/                # Bundle config + services
├── Controller/            # CRUD + API controllers
├── Entity/                # Doctrine entities + repositories
├── Event/                 # Custom events
├── Form/Type/             # Symfony form types
├── Model/                 # Business logic (FormModel)
├── Resources/views/       # Twig templates
├── Security/Permissions/  # Permission definitions
├── Tests/
│   ├── Unit/              # PHPUnit unit tests
│   └── Functional/        # PHPUnit functional tests
└── Translations/en_US/    # Translation strings
```

## Key Entities

| Entity   | Table              | Purpose                                     |
|----------|--------------------|---------------------------------------------|
| Pipeline | mautomic_pipelines | Named sales pipeline (e.g., "Enterprise")   |
| Stage    | mautomic_stages    | Ordered step within a pipeline              |
| Deal     | mautomic_deals     | Revenue opportunity linked to contact/company|
| Task     | mautomic_tasks     | Action item with due date and assignee       |
| Note     | mautomic_notes     | Text record on a deal or contact             |

## Known Patterns & Pitfalls

Lessons learned from Phase 1. **Read these before coding.**

| Pattern | What to do |
|---------|------------|
| Detail view buttons | Split `page_actions` into `preHeader` block (close) and `actions` block (edit/delete). Never put `close` with edit/delete in same include. |
| `UserListType` on entities | Use `IdToEntityModelTransformer` + `multiple: false`. Never use raw UserListType — it returns an array, entity setters expect User object. |
| Route naming | Routes must use `mautic_mautomic_crm_{entity}` prefix. `routeBase` = `mautomic_crm_{entity}`. |
| API controllers | Use constructor injection, not `initialize()`. Set model via `ModelFactory`. |
| `entityNameMulti` in API | Must match the `name` in config.php `api_routes` (e.g., `mautomic_pipelines` not `pipelines`). |
| Entity nullable ints | If a form field can submit empty, setter should accept `?int` with `??= 0` fallback. |
| Pipeline/Stage required on Deal | DB columns are NOT NULL. Default pipeline+stage in `DealModel::getEntity()` and enforce in `saveEntity()`. |
| Mautic cache | After entity changes, clear test cache: `ddev exec rm -rf var/cache/test` |
| Functional tests | Must use `-c app/phpunit.xml.dist` flag for `KERNEL_CLASS` env var. |

## Commands

All scoped to the plugin only — never the full Mautic codebase.

```bash
# Local / DDEV (recommended)
../mautic-crm-harness/harness/test-local.sh .       # Unit + Functional tests
../mautic-crm-harness/harness/lint-local.sh .        # PHPStan + CS
../mautic-crm-harness/harness/lint-local.sh . --fix  # Auto-fix CS

# Quick DDEV one-liners (from Mautic root)
ddev exec php bin/phpunit plugins/MautomicCrmBundle/Tests/Unit/ --testdox
ddev exec php bin/phpunit -c app/phpunit.xml.dist plugins/MautomicCrmBundle/Tests/Functional/ --testdox
ddev exec php bin/phpstan analyse plugins/MautomicCrmBundle/ --level 6
ddev exec bin/php-cs-fixer fix plugins/MautomicCrmBundle/ --dry-run --diff --config=.php-cs-fixer.php
```

## Feature Backlog

| # | Feature | Status | Spec |
|---|---------|--------|------|
| 001 | Phase 1 Bug Fixes & Polish | Backlog | [feature-001](docs/exec-plans/backlog/feature-001-phase1-bugfixes.md) |
| 002 | Task-Deal Linking | Backlog | [feature-002](docs/exec-plans/backlog/feature-002-task-deal-linking.md) |
| 003 | Notes & Activity Timeline | Backlog | [feature-003](docs/exec-plans/backlog/feature-003-notes-timeline.md) |
| 004 | Deal Stage Movement & History | Backlog | [feature-004](docs/exec-plans/backlog/feature-004-deal-stage-moves.md) |
| 005 | Pipeline Board View (Kanban) | Backlog | [feature-005](docs/exec-plans/backlog/feature-005-deal-board-view.md) |
| 006 | Campaign Triggers & Actions | Backlog | [feature-006](docs/exec-plans/backlog/feature-006-campaign-triggers.md) |
| 007 | Custom Deal Fields | Backlog | [feature-007](docs/exec-plans/backlog/feature-007-custom-deal-fields.md) |
