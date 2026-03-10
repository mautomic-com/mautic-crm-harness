# AGENTS.md — MautomicCrmBundle Development Harness

This is the **agent-first development harness** for the MautomicCrmBundle Mautic plugin.
It is the map — not the manual. Start here, then follow pointers to deeper docs.

## Quick Reference

| What                  | Where                                      |
|-----------------------|--------------------------------------------|
| Architecture overview | [ARCHITECTURE.md](ARCHITECTURE.md)         |
| Product specs         | [docs/product-specs/](docs/product-specs/) |
| Design docs           | [docs/design-docs/](docs/design-docs/)     |
| Feature backlog       | [GitHub Issues](https://github.com/mautomic-com/mautic-crm-bundle/issues?q=is%3Aissue+is%3Aopen+label%3Aenhancement) |
| Completed features    | [GitHub Closed Issues](https://github.com/mautomic-com/mautic-crm-bundle/issues?q=is%3Aissue+is%3Aclosed) |
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

```bash
gh issue view <NUMBER> --repo mautomic-com/mautic-crm-bundle
```

Read the assigned GitHub issue. Understand all acceptance criteria, browser smoke tests, and technical notes.
If anything is unclear, ask before starting.

### Step 2: Create a Feature Branch

```bash
cd /path/to/mautic-001/plugins/MautomicCrmBundle
git checkout main && git pull
git checkout -b feature/NNN-short-name
```

### Step 3: Build the Feature

Write the code following Mautic patterns. Reference `docs/references/` if needed.

**Every feature MUST include tests.** Write tests alongside the feature code:
- **Unit tests** for pure logic (entities, repositories, services)
- **Functional tests** for controller responses, form rendering, entity persistence
- **API tests** for any new or changed API endpoints

The feature spec's "Tests Required" section lists the minimum. Add more if you see gaps.

### Step 4: Run Automated Checks (ALL must pass)

```bash
# From Mautic root
../mautic-crm-harness/harness/test-local.sh .      # Unit + Functional tests
../mautic-crm-harness/harness/lint-local.sh .       # PHPStan + CS Fixer
```

If tests fail, fix them. If PHPStan reports errors, fix them.
**Do NOT proceed until all checks pass.**

### Step 4b: Reset Local Mautic (MANDATORY before browser tests)

Wipe the database and reinstall Mautic to ensure a clean slate with no leftover data from previous features.

```bash
# From Mautic root (mautic-001/)
ddev exec php bin/console doctrine:database:drop --force
ddev exec php bin/console doctrine:database:create
ddev exec rm config/local.php
ddev exec php bin/console mautic:install https://mautic-001.ddev.site --force \
  --db_driver=pdo_mysql --db_host=db --db_port=3306 --db_name=db --db_user=db --db_password=db \
  --admin_firstname=Admin --admin_lastname=User --admin_username=admin \
  --admin_email=admin@mautic.local --admin_password='Maut1cR0cks!'
```

Then re-enable API and mailer settings (install resets config/local.php):

```bash
# Write a temp PHP script to patch config/local.php:
cat > tmp_config_fix.php << 'PHPEOF'
<?php
include 'config/local.php';
$parameters['api_enabled'] = true;
$parameters['api_enable_basic_auth'] = true;
$parameters['mailer_dsn'] = 'smtp://localhost:1025';
$parameters['mailer_from_email'] = 'mautic@ddev.local';
$parameters['mailer_from_name'] = 'DDEV';
$parameters['install_source'] = 'DDEV';
file_put_contents('config/local.php', "<?php\n\$parameters = " . var_export($parameters, true) . ";\n");
echo "Config updated\n";
PHPEOF
ddev exec php tmp_config_fix.php && rm tmp_config_fix.php
ddev exec rm -rf var/cache
```

This takes ~15 seconds. **Do not skip this step** — stale data from previous features causes flaky browser tests.

### Step 5: Browser Smoke Tests (MANDATORY)

Open the Mautic UI at `https://mautic-001.ddev.site` using the browser tools
(Cursor IDE browser MCP or browser-use subagent).

Execute **every** browser smoke test listed in the feature spec.
Login credentials: `admin` / `Maut1cR0cks!`

**Follow this exact recipe for each test to avoid retries:**

```
1. browser_navigate → direct URL (see URL list in plugin AGENTS.md)
2. browser_navigate → javascript:void(document.querySelector('.sf-toolbar')&&(document.querySelector('.sf-toolbar').style.display='none'))
3. browser_snapshot → interactive: true, compact: true
4. browser_fill / browser_click as needed
5. To save forms: browser_navigate → javascript:void(document.querySelector('form')?.submit())
6. browser_take_screenshot to verify result
```

**Critical rules (skipping these causes retries):**

| Rule | Why |
|------|-----|
| Always hide `.sf-toolbar` after navigation | Debug toolbar overlaps bottom elements, intercepting clicks |
| Navigate direct to URLs, don't click menus | Faster and avoids stale refs from AJAX page loads |
| Submit forms via JS, not Save button | Save & Close is in a dropdown whose refs go stale instantly |
| Use `interactive: true, compact: true` on snapshots | Reduces 800+ lines to ~50, faster to parse |
| Use screenshots for visual verification | Snapshot text misses table content; screenshots show everything |
| Fresh snapshot before every click | Mautic uses AJAX — refs go stale after any page change |
| `browser_resize` to 1280x1024 at start | Prevents toolbar overlap on short viewports |

**Mautic URL patterns:**
```
/s/mautomic/pipelines              — list
/s/mautomic/pipelines/view/{id}    — detail
/s/mautomic/pipelines/edit/{id}    — edit
/s/mautomic/pipelines/new          — new
/s/mautomic/deals                  — list  (same pattern for /view/ /edit/ /new)
/s/mautomic/tasks                  — list  (same pattern)
```

If a test fails → fix the code → re-run automated checks → retry the test.

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
| PHPStan needs cache | Build first: `ddev exec bash -c 'APP_ENV=test APP_DEBUG=1 php bin/console > /dev/null 2>&1'` |
| Lead entity field names | Use `firstname`, `lastname` (lowercase, not camelCase) in DQL/QueryBuilder — Lead uses custom Doctrine metadata. |
| Browser: debug toolbar | Always hide after nav: JS `document.querySelector('.sf-toolbar').style.display='none'` |
| Browser: form submit | Use JS `document.querySelector('form')?.submit()` — Save dropdown refs go stale |
| Browser: direct URLs | Navigate to `/s/mautomic/{entity}/view/{id}` directly, don't click through menus |
| Browser: snapshots | Use `interactive: true, compact: true` — reduces 800+ lines to ~50 |
| Browser: resize first | Set 1280x1024 at session start to avoid toolbar overlap on short viewports |

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

**GitHub Issues are the single source of truth for what to build.**
See: https://github.com/mautomic-com/mautic-crm-bundle/issues?q=is%3Aissue+is%3Aopen+label%3Aenhancement

Before starting work, check the open issues list for the next feature to implement.
Each issue contains the full spec: acceptance criteria, browser smoke tests, technical notes, and required tests.
