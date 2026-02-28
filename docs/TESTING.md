# Testing Strategy

## Test Types

### Unit Tests (`Tests/Unit/`)

Test individual classes in isolation. No database, no HTTP.

- **Base class**: `PHPUnit\Framework\TestCase`
- **What to test**:
  - Entity field getters/setters
  - Entity `loadMetadata()` produces correct table name
  - Model `getPermissionBase()` and `getActionRouteBase()` return correct strings
  - Event objects carry correct data
  - Any utility/helper logic

### Functional Tests (`Tests/Functional/`)

Test full request/response cycles with a real database.

- **Base class**: `Mautic\CoreBundle\Test\MauticMysqlTestCase`
- **Provides**: `$this->em` (EntityManager), `$this->client` (HTTP client)
- **What to test**:
  - Controller actions return correct HTTP status codes
  - CRUD operations persist to database
  - Permission checks deny unauthorized access
  - API endpoints return correct JSON
  - Entity relationships work correctly (e.g., Deal -> Pipeline -> Stage)

## Test Requirements Per Entity

| Layer        | Minimum Tests Required                                  |
|--------------|---------------------------------------------------------|
| Entity       | Table name, required fields, relationships              |
| Repository   | `getEntities()`, `getTableAlias()`, custom queries      |
| Model        | Permission base, route base, create/save/delete entity  |
| Controller   | Index (200), new (200), edit (200), view (200), delete  |
| API          | GET list, GET one, POST, PUT, DELETE                    |
| Form Type    | Form builds without errors, required fields validated   |
| Permissions  | Correct permission groups registered                    |

## Running Tests

```bash
# All plugin tests
bin/phpunit plugins/MautomicCrmBundle/Tests/

# Unit tests only
bin/phpunit plugins/MautomicCrmBundle/Tests/Unit/

# Functional tests only
bin/phpunit plugins/MautomicCrmBundle/Tests/Functional/

# Specific test file
bin/phpunit plugins/MautomicCrmBundle/Tests/Functional/Controller/DealControllerTest.php

# Specific test method
bin/phpunit --filter testDealCreation
```

## Test Naming Convention

```
Tests/
├── Unit/
│   ├── Entity/
│   │   ├── PipelineTest.php
│   │   ├── StageTest.php
│   │   ├── DealTest.php
│   │   ├── TaskTest.php
│   │   └── NoteTest.php
│   └── Model/
│       ├── PipelineModelTest.php
│       ├── DealModelTest.php
│       ├── TaskModelTest.php
│       └── NoteModelTest.php
└── Functional/
    ├── Controller/
    │   ├── PipelineControllerTest.php
    │   ├── DealControllerTest.php
    │   ├── TaskControllerTest.php
    │   └── NoteControllerTest.php
    └── Api/
        ├── DealApiControllerTest.php
        ├── PipelineApiControllerTest.php
        └── TaskApiControllerTest.php
```
