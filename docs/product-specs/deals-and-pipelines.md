# Product Spec: Deals & Pipelines (Phase 1)

## Goal

Enable Mautic users to manage sales deals through configurable pipelines,
giving them a lightweight CRM directly inside Mautic.

## User Stories

### Pipeline Management
- As an admin, I can create/edit/delete sales pipelines with named stages.
- As an admin, I can set one pipeline as the default.
- As an admin, I can reorder stages within a pipeline.
- As an admin, I can set a probability % on each stage.
- As an admin, I can mark stages as "open", "won", or "lost" type.

### Deal Management
- As a sales user, I can create a deal with name, amount, currency, and expected close date.
- As a sales user, I can assign a deal to a pipeline and stage.
- As a sales user, I can link a deal to a Mautic contact and/or company.
- As a sales user, I can assign a deal to myself or another user.
- As a sales user, I can move a deal between stages (dropdown select).
- As a sales user, I can view a list of all deals with filtering and sorting.
- As a sales user, I can view a deal's detail page showing all its information.
- As a sales user, I can edit and delete deals (respecting permissions).
- As a sales user, I can clone a deal.

### API
- As a developer, I can CRUD pipelines via REST API.
- As a developer, I can CRUD deals via REST API.
- As a developer, I can filter deals by pipeline, stage, owner, contact, company.

## Acceptance Criteria

1. Pipeline CRUD works from admin UI and API.
2. Stage ordering is respected in UI dropdowns and API responses.
3. Deals list view shows: name, amount, stage, owner, contact, close date.
4. Deal detail view shows all fields plus recent activity log.
5. Permissions control access (own vs others' deals).
6. All UI strings are translatable.
7. PHPUnit tests cover all CRUD operations.
8. PHPStan level 6 passes.
9. Coding standards check passes.

## Out of Scope (Phase 1)
- Kanban/board view (Phase 4)
- Custom deal properties (Phase 3)
- Campaign integration (Phase 3)
- Tasks and notes (Phase 2)
- Dashboard widgets (Phase 4)
