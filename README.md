# MautomicCrmBundle Development Harness

Agent-first development infrastructure for the [MautomicCrmBundle](https://github.com/mautomic-com/mautic-crm-bundle) Mautic plugin.

## What Is This?

This repo contains everything needed to **develop, test, and validate** the MautomicCrmBundle plugin — but none of the plugin code itself. It's inspired by the [harness engineering](https://openai.com/index/harness-engineering/) approach to agent-driven development.

It provides:
- **Documentation**: Architecture, product specs, design docs, coding standards
- **Harness scripts**: Setup, lint, test, validate-architecture, validate-pr
- **CI workflows**: GitHub Actions for automated PR validation
- **Docker setup**: Spin up Mautic + MySQL for testing
- **Quality tracking**: Graded quality scores per domain and layer

## Quick Start

```bash
# 1. Clone all three repos as siblings
git clone https://github.com/mautomic-com/mautic-crm-harness.git
git clone https://github.com/mautomic-com/mautic-crm-bundle.git
git clone https://github.com/mautic/mautic.git mautic-001
cd mautic-001 && composer install && cd ..

# 2. Link the plugin into Mautic
./mautic-crm-harness/harness/setup.sh ./mautic-001 ./mautic-crm-bundle

# 3. Install the plugin
cd mautic-001 && php bin/console mautic:plugins:reload && cd ..

# 4. Validate everything
./mautic-crm-harness/harness/validate-pr.sh ./mautic-001 ./mautic-crm-bundle
```

## For AI Agents

Start by reading [AGENTS.md](AGENTS.md) — it's the map to everything in this repo.

## Repository Structure

```
AGENTS.md                 # Start here — the agent map
ARCHITECTURE.md           # Plugin architecture overview
docs/
  design-docs/            # Technical design documents
  product-specs/          # Feature specifications
  exec-plans/             # Execution plans (active + completed)
  references/             # Mautic pattern references
  CODING_STANDARDS.md     # PHP/Mautic coding rules
  TESTING.md              # Test strategy and patterns
  QUALITY_SCORE.md        # Quality grades per domain
harness/
  setup.sh                # Link plugin into Mautic
  lint.sh                 # PHPStan + CS check
  test.sh                 # PHPUnit tests
  validate-architecture.sh # Structural validation
  validate-pr.sh          # Full PR validation pipeline
ci/workflows/             # GitHub Actions workflows
docker/                   # Docker Compose for CI
```

## License

GPL-3.0-or-later (same as Mautic)
