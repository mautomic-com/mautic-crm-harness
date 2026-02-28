# Feature: [SHORT_NAME]

## Status: Backlog
<!-- Backlog → In Progress → Done -->

## Branch: `feature/NNN-short-name`

## Summary

One paragraph describing what this feature does and why it matters.

## Acceptance Criteria

Specific, testable conditions that must ALL pass before this feature is done.

- [ ] AC-1: [Description of what must work]
- [ ] AC-2: [Description of what must work]
- [ ] AC-3: [Description of what must work]

## Browser Smoke Tests

Manual UI flows the agent MUST verify in the browser before creating the PR.

1. Navigate to [URL]. Verify [expected behavior].
2. Fill [form] with [data]. Submit. Verify [result].
3. Edit the entity. Change [field]. Save. Verify [persisted correctly].
4. Delete the entity. Verify [removed from list].

## Technical Notes

Implementation hints, constraints, or references to Mautic patterns.

- Entity changes: [describe any new/modified entities]
- Form changes: [describe any new/modified forms]  
- View changes: [describe any new/modified templates]
- API changes: [describe any new/modified API endpoints]

## Tests Required

- [ ] Unit tests for new/modified entities
- [ ] Functional tests for new/modified controllers
- [ ] API tests for new/modified endpoints

## Done Definition

ALL of these must pass before creating the PR:

- [ ] All acceptance criteria verified
- [ ] `harness/lint-local.sh` passes (PHPStan level 6 + CS)
- [ ] `harness/test-local.sh` passes (all unit + functional tests)
- [ ] `harness/validate-architecture.sh` passes
- [ ] Browser smoke tests verified manually
- [ ] PR created with summary of changes and test results

## Decision Log

| Decision | Rationale |
|----------|-----------|
