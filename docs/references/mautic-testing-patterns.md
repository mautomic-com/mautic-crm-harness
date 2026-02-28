# Mautic 7 Testing Patterns Reference

## Functional Tests

```php
<?php

declare(strict_types=1);

namespace MauticPlugin\MautomicCrmBundle\Tests\Functional\Controller;

use Mautic\CoreBundle\Test\MauticMysqlTestCase;
use MauticPlugin\MautomicCrmBundle\Entity\Deal;
use MauticPlugin\MautomicCrmBundle\Entity\Pipeline;
use MauticPlugin\MautomicCrmBundle\Entity\Stage;

class DealControllerTest extends MauticMysqlTestCase
{
    public function testDealIndexReturns200(): void
    {
        $this->client->request('GET', '/s/mautomic/deals');
        $this->assertResponseIsSuccessful();
    }

    public function testDealCreation(): void
    {
        // Create prerequisite entities
        $pipeline = new Pipeline();
        $pipeline->setName('Test Pipeline');
        $pipeline->setIsDefault(true);
        $pipeline->setIsPublished(true);
        $this->em->persist($pipeline);

        $stage = new Stage();
        $stage->setName('Qualification');
        $stage->setPipeline($pipeline);
        $stage->setOrder(1);
        $stage->setProbability(25);
        $stage->setType('open');
        $this->em->persist($stage);

        $this->em->flush();

        // Test creation via controller
        $crawler = $this->client->request('GET', '/s/mautomic/deals/new');
        $this->assertResponseIsSuccessful();

        // Submit form
        $form = $crawler->selectButton('Save')->form([
            'deal[name]'     => 'Test Deal',
            'deal[amount]'   => '10000',
            'deal[pipeline]' => $pipeline->getId(),
            'deal[stage]'    => $stage->getId(),
        ]);
        $this->client->submit($form);

        // Verify persisted
        $deal = $this->em->getRepository(Deal::class)->findOneBy(['name' => 'Test Deal']);
        $this->assertNotNull($deal);
        $this->assertEquals(10000, $deal->getAmount());
    }
}
```

## Unit Tests

```php
<?php

declare(strict_types=1);

namespace MauticPlugin\MautomicCrmBundle\Tests\Unit\Entity;

use MauticPlugin\MautomicCrmBundle\Entity\Deal;
use PHPUnit\Framework\TestCase;

class DealTest extends TestCase
{
    public function testGetSetName(): void
    {
        $deal = new Deal();
        $deal->setName('Enterprise Deal');
        $this->assertSame('Enterprise Deal', $deal->getName());
    }

    public function testGetSetAmount(): void
    {
        $deal = new Deal();
        $deal->setAmount('50000.00');
        $this->assertSame('50000.00', $deal->getAmount());
    }
}
```

## API Tests

```php
<?php

declare(strict_types=1);

namespace MauticPlugin\MautomicCrmBundle\Tests\Functional\Api;

use Mautic\CoreBundle\Test\MauticMysqlTestCase;
use MauticPlugin\MautomicCrmBundle\Entity\Pipeline;

class PipelineApiControllerTest extends MauticMysqlTestCase
{
    public function testGetPipelines(): void
    {
        $pipeline = new Pipeline();
        $pipeline->setName('API Test Pipeline');
        $pipeline->setIsDefault(true);
        $pipeline->setIsPublished(true);
        $this->em->persist($pipeline);
        $this->em->flush();

        $this->client->request('GET', '/api/mautomic/pipelines');
        $this->assertResponseIsSuccessful();

        $response = json_decode($this->client->getResponse()->getContent(), true);
        $this->assertNotEmpty($response['pipelines']);
    }
}
```

## Key Points

1. Always use `MauticMysqlTestCase` for functional tests — it handles DB setup/teardown.
2. Use `$this->em` for EntityManager, `$this->client` for HTTP requests.
3. Create prerequisite entities (Pipeline, Stage) before testing Deals.
4. Test file naming: `{ClassName}Test.php`, same directory structure as source.
5. Run with: `bin/phpunit plugins/MautomicCrmBundle/Tests/`
