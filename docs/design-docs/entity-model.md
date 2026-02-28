# Entity Model Design

## Pipeline

| Field       | Type     | Column          | Nullable | Notes                          |
|-------------|----------|-----------------|----------|--------------------------------|
| id          | integer  | id              | no       | Auto-increment PK              |
| name        | string   | name            | no       | Pipeline name                  |
| description | text     | description     | yes      |                                |
| isDefault   | boolean  | is_default      | no       | Only one pipeline is default   |
| isPublished | boolean  | is_published    | no       | From FormEntity                |
| createdBy   | integer  | created_by      | yes      | From FormEntity (User FK)      |
| dateAdded   | datetime | date_added      | yes      | From FormEntity                |
| modifiedBy  | integer  | modified_by     | yes      | From FormEntity                |
| dateModified| datetime | date_modified   | yes      | From FormEntity                |

Table: `mautomic_pipelines`

## Stage

| Field       | Type     | Column          | Nullable | Notes                          |
|-------------|----------|-----------------|----------|--------------------------------|
| id          | integer  | id              | no       | Auto-increment PK              |
| name        | string   | name            | no       | Stage name                     |
| pipeline    | Pipeline | pipeline_id     | no       | FK to mautomic_pipelines       |
| order       | integer  | stage_order     | no       | Sort position within pipeline  |
| probability | integer  | probability     | no       | 0-100, deal close likelihood   |
| type        | string   | stage_type      | no       | open, won, or lost             |

Table: `mautomic_stages`

Note: `order` maps to column `stage_order` because `order` is a SQL reserved word.
Note: `type` maps to column `stage_type` to avoid ambiguity.

## Deal

| Field       | Type      | Column          | Nullable | Notes                          |
|-------------|-----------|-----------------|----------|--------------------------------|
| id          | integer   | id              | no       | Auto-increment PK              |
| name        | string    | name            | no       | Deal name                      |
| description | text      | description     | yes      |                                |
| amount      | decimal   | amount          | yes      | Deal value (precision 15,2)    |
| currency    | string(3) | currency        | yes      | ISO 4217 code (e.g., USD)      |
| closeDate   | date      | close_date      | yes      | Expected close date            |
| pipeline    | Pipeline  | pipeline_id     | no       | FK to mautomic_pipelines       |
| stage       | Stage     | stage_id        | no       | FK to mautomic_stages          |
| contact     | Lead      | contact_id      | yes      | FK to leads                    |
| company     | Company   | company_id      | yes      | FK to companies                |
| owner       | User      | owner_id        | yes      | FK to users (assigned to)      |
| category    | Category  | category_id     | yes      | FK to categories               |
| isPublished | boolean   | is_published    | no       | From FormEntity                |
| createdBy   | integer   | created_by      | yes      | From FormEntity                |
| dateAdded   | datetime  | date_added      | yes      | From FormEntity                |
| modifiedBy  | integer   | modified_by     | yes      | From FormEntity                |
| dateModified| datetime  | date_modified   | yes      | From FormEntity                |

Table: `mautomic_deals`

## Task

| Field       | Type     | Column          | Nullable | Notes                          |
|-------------|----------|-----------------|----------|--------------------------------|
| id          | integer  | id              | no       | Auto-increment PK              |
| title       | string   | title           | no       | Task title                     |
| description | text     | description     | yes      |                                |
| dueDate     | datetime | due_date        | yes      | When the task is due           |
| status      | string   | status          | no       | open or completed              |
| priority    | string   | priority        | no       | low, normal, or high           |
| deal        | Deal     | deal_id         | yes      | FK to mautomic_deals           |
| contact     | Lead     | contact_id      | yes      | FK to leads                    |
| owner       | User     | owner_id        | yes      | FK to users (assigned to)      |
| isPublished | boolean  | is_published    | no       | From FormEntity                |
| createdBy   | integer  | created_by      | yes      | From FormEntity                |
| dateAdded   | datetime | date_added      | yes      | From FormEntity                |
| modifiedBy  | integer  | modified_by     | yes      | From FormEntity                |
| dateModified| datetime | date_modified   | yes      | From FormEntity                |

Table: `mautomic_tasks`

## Note

| Field       | Type     | Column          | Nullable | Notes                          |
|-------------|----------|-----------------|----------|--------------------------------|
| id          | integer  | id              | no       | Auto-increment PK              |
| text        | text     | text            | no       | Note content                   |
| type        | string   | note_type       | no       | general, call, meeting, email  |
| deal        | Deal     | deal_id         | yes      | FK to mautomic_deals           |
| contact     | Lead     | contact_id      | yes      | FK to leads                    |
| createdBy   | integer  | created_by      | yes      | From FormEntity                |
| dateAdded   | datetime | date_added      | yes      | From FormEntity                |
| modifiedBy  | integer  | modified_by     | yes      | From FormEntity                |
| dateModified| datetime | date_modified   | yes      | From FormEntity                |

Table: `mautomic_notes`

## Relationships Diagram

```
Pipeline 1 ──────* Stage
    │
    │ (pipeline_id)
    ▼
  Deal *──1 Stage (stage_id)
    │
    ├──0..1 Lead     (contact_id)
    ├──0..1 Company  (company_id)
    ├──0..1 User     (owner_id)
    ├──0..1 Category (category_id)
    │
    │ (deal_id)
    ▼
  Task *──0..1 Lead (contact_id)
       *──0..1 User (owner_id)
  Note *──0..1 Lead (contact_id)
       *──0..1 Deal (deal_id)
```
