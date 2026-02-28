# Architecture — MautomicCrmBundle

## Overview

MautomicCrmBundle is a Mautic 7 plugin that adds CRM deal management.
It follows Mautic's bundle-based architecture exactly — no custom patterns.

## Domain Model

```
Pipeline 1──* Stage
Deal *──1 Pipeline
Deal *──1 Stage
Deal *──1 Lead (Contact)
Deal *──1 Company
Deal *──1 User (Owner)
Task *──1 Deal (optional)
Task *──1 Lead (optional)
Task *──1 User (Owner)
Note *──1 Deal (optional)
Note *──1 Lead (optional)
```

### Pipeline
A named container for stages. Examples: "Enterprise Sales", "SMB", "Partnerships".
Has a boolean `isDefault` flag — exactly one pipeline is the default.

### Stage
An ordered step within a pipeline. Each stage has:
- `order` (integer) — display/sort position
- `probability` (integer 0-100) — likelihood of closing at this stage
- `type` — one of: `open`, `won`, `lost`

Won/lost stages are terminal — deals in these stages are considered closed.

### Deal
The core CRM record. Tracks a revenue opportunity through pipeline stages.
- Linked to exactly one Pipeline + Stage
- Optionally linked to a Contact (Lead) and Company
- Assigned to a User (owner)
- Has amount, currency, close date, probability

### Task
An action item. Can be standalone or linked to a Deal and/or Contact.
- Has due date, priority (low/normal/high), status (open/completed)
- Assigned to a User

### Note
A text record attached to a Deal and/or Contact.
- Has a type: general, call, meeting, email
- Tracks who created it and when

## Layer Architecture

Each entity follows this layering (same as all Mautic bundles):

```
Entity (Doctrine ORM)
  → Repository (data access)
    → Model (business logic, extends FormModel)
      → Controller (HTTP, extends AbstractStandardFormController)
        → Form/Type (Symfony forms)
          → Views (Twig templates)
```

Dependencies flow downward only. Controllers depend on Models, Models depend on Repositories.

## Integration Points

### With Mautic Core
- **LeadBundle**: Deal links to Lead (contact) and Company entities
- **UserBundle**: Deal and Task ownership via User entity
- **CategoryBundle**: Deals support categories
- **CoreBundle**: Base classes (FormEntity, FormModel, AbstractStandardFormController)

### With Mautic Campaigns (Phase 3)
- Campaign trigger: "Deal stage changed" fires when a deal moves between stages
- Campaign action: "Update deal stage" moves a deal to a specified stage
- Segment filter: "Has deal in stage X" filters contacts by their deal status

## Database

All tables are prefixed with `mautomic_` to avoid collision with core tables.
Table creation uses Doctrine metadata via `loadMetadata()` static methods.

## Permissions

Single permission class: `MautomicCrmPermissions` with name `mautomic_crm`.

Permission groups:
- `mautomic_crm:pipelines` — standard (view, create, edit, delete, publish)
- `mautomic_crm:deals` — extended (adds viewown, editown, deleteown)
- `mautomic_crm:tasks` — extended
- `mautomic_crm:notes` — extended

## API

REST API endpoints follow Mautic's standard entity pattern:
- `GET/POST /api/mautomic/pipelines`
- `GET/PUT/PATCH/DELETE /api/mautomic/pipelines/{id}`
- `GET/POST /api/mautomic/deals`
- `GET/PUT/PATCH/DELETE /api/mautomic/deals/{id}`
- `GET/POST /api/mautomic/tasks`
- `GET/PUT/PATCH/DELETE /api/mautomic/tasks/{id}`

## Menu Structure

Plugin adds a top-level "CRM" menu item under the main navigation:
- CRM (parent)
  - Deals
  - Pipelines
  - Tasks
