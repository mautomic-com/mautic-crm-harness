# Mautic 7 Plugin System Reference

## Plugin Registration

Mautic auto-discovers plugins by scanning `plugins/` for `*Bundle.php` files.
The bundle class must extend `Mautic\PluginBundle\Bundle\PluginBundleBase`.

```php
<?php
namespace MauticPlugin\MautomicCrmBundle;

use Mautic\PluginBundle\Bundle\PluginBundleBase;

class MautomicCrmBundle extends PluginBundleBase
{
}
```

## Config/config.php

Returns an array with these keys:

```php
return [
    'name'        => 'Plugin Display Name',
    'description' => 'What this plugin does',
    'version'     => '1.0.0',
    'author'      => 'Author Name',

    'routes' => [
        'main'   => [...],  // Admin routes (require auth)
        'public' => [...],  // Public routes
        'api'    => [...],  // API routes
    ],

    'menu' => [
        'main'  => [...],   // Main nav items
        'admin' => [...],   // Admin settings items
    ],

    'services' => [
        'other' => [...],   // Manual service definitions
    ],

    'categories' => [...],  // Entity categories

    'parameters' => [...],  // Default config parameters
];
```

### Route Definition

```php
'route_name' => [
    'path'       => '/crm/deals/{page}',
    'controller' => 'MauticPlugin\\MautomicCrmBundle\\Controller\\DealController::indexAction',
],
```

### API Route with Standard Entity

```php
'mautomic_api_deals' => [
    'standard_entity' => true,
    'name'            => 'mautomic_deals',
    'path'            => '/mautomic/deals',
    'controller'      => MauticPlugin\MautomicCrmBundle\Controller\Api\DealApiController::class,
],
```

This auto-generates GET (list), GET (single), POST, PUT, PATCH, DELETE routes.

### Menu Definition

```php
'menu' => [
    'main' => [
        'mautomic_crm.deals' => [
            'route'    => 'mautomic_crm_deal_index',
            'access'   => 'mautomic_crm:deals:view',
            'parent'   => 'mautomic_crm.crm',
            'priority' => 10,
        ],
    ],
],
```

## Config/services.php

Standard Symfony DI with autowiring:

```php
<?php
declare(strict_types=1);

use Mautic\CoreBundle\DependencyInjection\MauticCoreExtension;
use Symfony\Component\DependencyInjection\Loader\Configurator\ContainerConfigurator;

return function (ContainerConfigurator $configurator): void {
    $services = $configurator->services()
        ->defaults()
        ->autowire()
        ->autoconfigure()
        ->public();

    $services->load('MauticPlugin\\MautomicCrmBundle\\', '../')
        ->exclude('../{'.implode(',', array_merge(
            MauticCoreExtension::DEFAULT_EXCLUDES, []
        )).'}');

    // Register repositories
    $services->load('MauticPlugin\\MautomicCrmBundle\\Entity\\', '../Entity/*Repository.php')
        ->tag(Doctrine\Bundle\DoctrineBundle\DependencyInjection\Compiler\ServiceRepositoryCompilerPass::REPOSITORY_SERVICE_TAG);

    // Model aliases (needed for getModel('alias') calls)
    $services->alias('mautomic_crm.model.pipeline', MauticPlugin\MautomicCrmBundle\Model\PipelineModel::class);
    $services->alias('mautomic_crm.model.deal', MauticPlugin\MautomicCrmBundle\Model\DealModel::class);
    $services->alias('mautomic_crm.model.task', MauticPlugin\MautomicCrmBundle\Model\TaskModel::class);
    $services->alias('mautomic_crm.model.note', MauticPlugin\MautomicCrmBundle\Model\NoteModel::class);
};
```

## Database Schema

Mautic creates tables from entity `loadMetadata()` definitions during plugin installation.
Tables are automatically prefixed with the Mautic instance's configured table prefix.

Use `$builder->setTable('mautomic_deals')` — Mautic adds its own prefix on top.
