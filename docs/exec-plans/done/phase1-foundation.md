# Execution Plan: Phase 1 — Foundation (Pipelines + Deals)

## Status: Complete

## Goal

Deliver the complete plugin scaffold and working Pipeline + Deal CRUD
with UI, API, permissions, and full test coverage.

## Steps

### 1. Plugin Scaffold
- [x] MautomicCrmBundle.php (bundle class)
- [x] composer.json
- [x] Config/config.php (routes, menu, categories)
- [x] Config/services.php (Symfony DI)
- [x] DependencyInjection/MautomicCrmExtension.php (loads services.php)
- [x] Security/Permissions/MautomicCrmPermissions.php
- [x] MautomicCrmEvents.php (event constants)
- [x] Translations/en_US/messages.ini
- [x] Translations/en_US/flashes.ini
- [x] Translations/en_US/validators.ini

### 2. Pipeline + Stage Entities
- [x] Entity/Pipeline.php (loadMetadata, loadApiMetadata, loadValidatorMetadata)
- [x] Entity/PipelineRepository.php
- [x] Entity/Stage.php (loadMetadata, loadApiMetadata)
- [x] Entity/StageRepository.php

### 3. Deal Entity
- [x] Entity/Deal.php (loadMetadata, loadApiMetadata, loadValidatorMetadata)
- [x] Entity/DealRepository.php
- [x] Event/DealEvent.php

### 4. Models
- [x] Model/PipelineModel.php
- [x] Model/DealModel.php

### 5. Forms
- [x] Form/Type/PipelineType.php (includes inline stages CollectionType with add/remove JS)
- [x] Form/Type/StageType.php
- [x] Form/Type/DealType.php (includes pipeline/stage EntityType dropdowns)

### 6. Controllers
- [x] Controller/PipelineController.php
- [x] Controller/DealController.php
- [x] Controller/Api/PipelineApiController.php (constructor injection, matches Mautic pattern)
- [x] Controller/Api/DealApiController.php (constructor injection, owner handled via preSaveEntity)

### 7. Views
- [x] Resources/views/Pipeline/list.html.twig
- [x] Resources/views/Pipeline/_list.html.twig
- [x] Resources/views/Pipeline/form.html.twig (inline stage editor with add/remove)
- [x] Resources/views/Pipeline/details.html.twig
- [x] Resources/views/Deal/list.html.twig
- [x] Resources/views/Deal/_list.html.twig (pipeline, stage, owner, contact columns)
- [x] Resources/views/Deal/form.html.twig (pipeline/stage dropdowns, owner, category)
- [x] Resources/views/Deal/details.html.twig (linked contact/company with navigation links)

### 8. Tests
- [x] Tests/Unit/Entity/PipelineTest.php (+ PipelineAdvancedTest.php)
- [x] Tests/Unit/Entity/StageTest.php (+ StageAdvancedTest.php)
- [x] Tests/Unit/Entity/DealTest.php (+ DealAdvancedTest.php)
- [x] Tests/Unit/Event/DealEventTest.php
- [x] Tests/Functional/Controller/PipelineControllerTest.php
- [x] Tests/Functional/Controller/DealControllerTest.php
- [x] Tests/Functional/Entity/PipelinePersistenceTest.php
- [x] Tests/Functional/Api/PipelineApiControllerTest.php (CRUD + list)
- [x] Tests/Functional/Api/DealApiControllerTest.php (CRUD + list)

### 9. Validation
- [x] PHPStan level 6 passes (0 errors)
- [x] Coding standards check passes (0 issues)
- [x] All tests pass (74 unit + 32 functional = 106 tests)

## Test Summary

| Suite       | Tests | Assertions | Status |
|-------------|-------|------------|--------|
| Unit        | 74    | 133        | PASS   |
| Functional  | 32    | 92         | PASS   |
| **Total**   | **106** | **225**  | **PASS** |

## Acceptance Criteria

See [docs/product-specs/deals-and-pipelines.md](../../product-specs/deals-and-pipelines.md).

| Criteria | Status |
|----------|--------|
| Pipeline CRUD from admin UI and API | ✅ |
| Stage ordering respected in UI | ✅ |
| Deals list shows: name, amount, pipeline, stage, owner, contact, ID | ✅ |
| Deal detail view shows all fields plus activity log | ✅ |
| Permissions control access | ✅ |
| All UI strings translatable | ✅ |
| PHPUnit tests cover CRUD operations | ✅ |
| PHPStan level 6 passes | ✅ |
| Coding standards check passes | ✅ |

## Decision Log

| Date | Decision | Rationale |
|------|----------|-----------|
| 2026-02-28 | Use `mautomic_` table prefix | Avoids collision with core Mautic tables and other plugins |
| 2026-02-28 | Stage `order` maps to `stage_order` column | `order` is SQL reserved word |
| 2026-02-28 | Extend FormEntity for all entities | Gives us publish/unpublish, audit logging, created/modified tracking for free |
| 2026-02-28 | Route names use `mautic_mautomic_crm_` prefix | Required by Mautic core templates (page_actions, list_toolbar construct route names from routeBase) |
| 2026-02-28 | Task entity uses `title` not `name` | Override `getDefaultOrderColumn()` in controller since Mautic defaults to `name` |
| 2026-02-28 | Service aliases use `mautic.` prefix | ModelFactory resolves services as `mautic.{bundle}.model.{entity}` |
| 2026-02-28 | API controllers use constructor injection | Mautic 7 pattern - `initialize()` method doesn't exist in API controllers |
| 2026-02-28 | API `entityNameMulti` matches config `name` | Route name generation: `mautic_api_{name}_getone` must match `entityNameMulti` |
| 2026-02-28 | DealApiController removes owner from form | `UserListType` incompatible with API form submission; owner set via `preSaveEntity` |
| 2026-02-28 | Pipeline stages use CollectionType + prototype JS | Simpler than session-based AJAX for lightweight child entities |
| 2026-02-28 | Pipeline OneToMany has cascadePersist + orphanRemoval | Stages saved/deleted automatically with pipeline |
