# Feature: Phase 1 Bug Fixes & Polish

## Status: Backlog

## Branch: `feature/001-phase1-bugfixes`

## Summary

Fix all bugs discovered during manual testing of Phase 1 (Pipelines + Deals).
These are issues found in the initial implementation that need to be resolved
before moving to Phase 2 features.

## Acceptance Criteria

- [ ] AC-1: Detail views (Pipeline, Deal, Task) show Edit and Delete buttons in the toolbar
- [ ] AC-2: Pipeline form saves stages inline without errors (order/probability default to 0 if empty)
- [ ] AC-3: Deal form saves with owner field without "array given" error (uses IdToEntityModelTransformer)
- [ ] AC-4: New Deal form pre-fills: owner=current user, pipeline=first published, stage=first stage, closeDate=today
- [ ] AC-5: Pipeline and stage are required on Deal form (NOT NULL in DB)
- [ ] AC-6: Stage auto-defaults to first stage of pipeline if not explicitly selected on save
- [ ] AC-7: Task form saves with owner field without errors (uses IdToEntityModelTransformer)
- [ ] AC-8: Amount, currency, description, closeDate remain nullable/optional

## Browser Smoke Tests

1. Navigate to CRM → Pipelines. Click on a pipeline name. Verify Edit/Delete buttons visible in toolbar.
2. Click Edit on pipeline. Add 2 stages (name only, leave order/probability empty). Save. Verify no errors and stages appear on detail view.
3. Navigate to CRM → Deals. Click "New". Verify form pre-fills owner, pipeline, stage, and today's date.
4. Fill deal name "Test Deal". Leave other fields default. Save. Verify deal saved successfully and appears in list.
5. Click on deal name. Verify Edit/Delete buttons visible. Click Edit. Change amount to 5000. Save. Verify updated.
6. Navigate to CRM → Tasks. Click "New". Fill title "Test Task". Save. Verify no owner-related errors.
7. Click on task name. Verify Edit/Delete buttons visible.

## Technical Notes

- Detail templates: split `page_actions` into `preHeader` block (close button) and `actions` block (edit/delete) — matches EmailBundle pattern
- `UserListType` requires `IdToEntityModelTransformer` + `multiple: false` — matches LeadBundle pattern
- Stage entity setters accept `?int` for order/probability with `??= 0` fallback
- `DealModel::getEntity()` sets defaults for new entities
- `DealModel::saveEntity()` ensures stage is set before persist

## Tests Required

- [ ] Existing unit tests still pass (no regressions)
- [ ] Existing functional tests still pass
- [ ] API tests still pass

## Done Definition

- [ ] All acceptance criteria verified
- [ ] `harness/lint-local.sh` passes
- [ ] `harness/test-local.sh` passes
- [ ] Browser smoke tests verified manually
- [ ] PR created with summary

## Decision Log

| Decision | Rationale |
|----------|-----------|
| Split page_actions into preHeader + actions blocks | Mautic's template renders ONLY close button when `close` is in templateButtons, hiding edit/delete |
| Use IdToEntityModelTransformer for UserListType | UserListType returns int ID, entity setter expects User object. Matches LeadBundle pattern |
| Default stage to first in pipeline at save time | Prevents NOT NULL constraint violation when stage not explicitly chosen |
