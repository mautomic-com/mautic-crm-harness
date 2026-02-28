# Mautic 7 Entity Patterns Reference

## Base Class: FormEntity

Most entities extend `Mautic\CoreBundle\Entity\FormEntity` which provides:
- `id` (auto-increment)
- `isPublished` (boolean)
- `createdBy` / `createdByUser` (User reference)
- `dateAdded` (datetime)
- `modifiedBy` / `modifiedByUser` (User reference)
- `dateModified` (datetime)
- `checkedOut` / `checkedOutBy` (entity locking)
- `isChanged()` method for change tracking

## loadMetadata() Pattern

All ORM mapping is done via static `loadMetadata()` method using `ClassMetadataBuilder`:

```php
public static function loadMetadata(ORM\ClassMetadata $metadata): void
{
    $builder = new ClassMetadataBuilder($metadata);

    // Required: set table name and repository
    $builder->setTable('mautomic_deals')
        ->setCustomRepositoryClass(DealRepository::class);

    // Add standard ID + name + description columns
    $builder->addIdColumns();

    // Or add ID only (when name/description handled separately)
    $builder->addId();

    // Add named fields
    $builder->addField('amount', 'decimal', ['precision' => 15, 'scale' => 2]);
    $builder->addNullableField('currency', 'string');

    // Add named field with custom column name
    $builder->addNamedField('closeDate', 'date', 'close_date', true); // true = nullable

    // Add publish date fields
    $builder->addPublishDates();

    // Add category (FK to categories table)
    $builder->addCategory();

    // Add ManyToOne relationship
    $builder->createManyToOne('pipeline', Pipeline::class)
        ->addJoinColumn('pipeline_id', 'id', false) // false = NOT NULL
        ->build();

    // Add nullable ManyToOne
    $builder->createManyToOne('contact', \Mautic\LeadBundle\Entity\Lead::class)
        ->addJoinColumn('contact_id', 'id', true, false, 'SET NULL')
        ->build();

    // Add OneToMany
    $builder->createOneToMany('stages', Stage::class)
        ->setIndexBy('id')
        ->mappedBy('pipeline')
        ->build();

    // Add index
    $builder->addIndex(['pipeline_id', 'stage_id'], 'deal_pipeline_stage');
}
```

## loadApiMetadata() Pattern

For API serialization:

```php
public static function loadApiMetadata(ApiMetadataDriver $metadata): void
{
    $metadata->setGroupPrefix('deal')
        ->addListProperties(['id', 'name', 'amount'])
        ->addProperties(['description', 'currency', 'closeDate', 'pipeline', 'stage', 'contact', 'company', 'owner'])
        ->build();
}
```

## loadValidatorMetadata() Pattern

For validation constraints:

```php
public static function loadValidatorMetadata(ClassMetadata $metadata): void
{
    $metadata->addPropertyConstraint('name', new NotBlank([
        'message' => 'mautomic_crm.deal.name.required',
    ]));
}
```

## Repository Pattern

```php
class DealRepository extends CommonRepository
{
    public function getTableAlias(): string
    {
        return 'd';
    }

    protected function getDefaultOrder(): array
    {
        return [[$this->getTableAlias().'.dateAdded', 'DESC']];
    }

    protected function addCatchAllWhereClause($q, $filter): array
    {
        return $this->addStandardCatchAllWhereClause($q, $filter, ['d.name']);
    }

    protected function addSearchCommandWhereClause($q, $filter): array
    {
        return $this->addStandardSearchCommandWhereClause($q, $filter);
    }

    public function getSearchCommands(): array
    {
        return $this->getStandardSearchCommands();
    }
}
```

## Change Tracking

All setters must call `$this->isChanged()` to enable Mautic's audit logging:

```php
public function setName(?string $name): self
{
    $this->isChanged('name', $name);
    $this->name = $name;
    return $this;
}
```
