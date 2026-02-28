# Coding Standards

MautomicCrmBundle follows Mautic 7's coding standards exactly.

## PHP

- **PHP 8.2+** with `declare(strict_types=1)` in every file
- **PSR-12 / Symfony** coding style
- 4-space indentation, no tabs
- Short array syntax `[]`
- Ordered `use` statements (alphabetical)
- One class per file
- Explicit type hints on all parameters and return types
- Nullable hints with `?Type` syntax
- No unnecessary DocBlocks — only for complex types, `@throws`, or non-obvious behavior

## Naming

- Classes: `PascalCase`
- Methods/functions: `camelCase`
- Properties: `camelCase`
- Constants: `UPPER_SNAKE_CASE`
- Database tables: `mautomic_{entity_plural}` (e.g., `mautomic_deals`)
- Database columns: `snake_case`
- Routes: `mautomic_crm_{entity}_{action}` (e.g., `mautomic_crm_deal_index`)
- Translation keys: `mautomic_crm.{entity}.{key}` (e.g., `mautomic_crm.deal.name`)
- Service aliases: `mautomic_crm.model.{entity}` (e.g., `mautomic_crm.model.deal`)
- Permission names: `mautomic_crm:{group}:{action}` (e.g., `mautomic_crm:deals:view`)

## Entity Pattern

```php
<?php

declare(strict_types=1);

namespace MauticPlugin\MautomicCrmBundle\Entity;

use Doctrine\ORM\Mapping as ORM;
use Mautic\CoreBundle\Doctrine\Mapping\ClassMetadataBuilder;
use Mautic\CoreBundle\Entity\FormEntity;

class Example extends FormEntity
{
    private ?int $id = null;
    private ?string $name = null;

    public static function loadMetadata(ORM\ClassMetadata $metadata): void
    {
        $builder = new ClassMetadataBuilder($metadata);
        $builder->setTable('mautomic_examples')
            ->setCustomRepositoryClass(ExampleRepository::class);
        $builder->addIdColumns();
        // ... field definitions
    }

    // Getters and setters with $this->isChanged() calls
}
```

## Controller Pattern

```php
class ExampleController extends AbstractStandardFormController
{
    protected function getTemplateBase(): string
    {
        return '@MautomicCrm/Example';
    }

    protected function getModelName(): string
    {
        return 'mautomic_crm.deal'; // service alias
    }

    public function indexAction(Request $request, int $page = 1): Response
    {
        return parent::indexStandard($request, $page);
    }
    // ... other standard actions
}
```

## Model Pattern

```php
class ExampleModel extends FormModel
{
    public function getActionRouteBase(): string
    {
        return 'mautomic_crm_example';
    }

    public function getPermissionBase(): string
    {
        return 'mautomic_crm:examples';
    }

    public function getRepository(): ExampleRepository
    {
        return $this->em->getRepository(Example::class);
    }
    // ...
}
```

## Validation

Run these before every PR:

```bash
composer cs          # PHP CS Fixer check (dry-run)
composer phpstan     # PHPStan level 6
bin/phpunit          # All tests pass
```

Equivalent harness commands:

```bash
./harness/lint.sh /path/to/mautic
./harness/test.sh /path/to/mautic
```
