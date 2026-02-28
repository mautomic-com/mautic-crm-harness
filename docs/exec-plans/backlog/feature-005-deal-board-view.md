# Feature: Pipeline Board View (Kanban)

## Status: Backlog

## Branch: `feature/005-deal-board-view`

## Summary

Add a Kanban-style board view for deals within a pipeline, showing deals as
cards in columns organized by stage. This is the primary visual interface for
sales pipeline management.

## Acceptance Criteria

- [ ] AC-1: Pipeline detail page has a "Board View" tab/toggle alongside the stages table
- [ ] AC-2: Board shows columns for each stage, ordered by stage order
- [ ] AC-3: Each deal card shows: name, amount, contact name, owner avatar/initials
- [ ] AC-4: Won column has green header, Lost column has red header
- [ ] AC-5: Clicking a deal card opens the deal detail page
- [ ] AC-6: Pipeline selector at top to switch between pipelines
- [ ] AC-7: Deal count and total amount shown per column header

## Browser Smoke Tests

1. Navigate to CRM → Pipelines. Open a pipeline with stages and deals.
2. Click "Board View". Verify columns for each stage.
3. Verify deals appear in correct stage columns.
4. Verify won/lost columns have colored headers.
5. Click a deal card. Verify navigates to deal detail.
6. Switch pipeline via selector. Verify board updates.

## Technical Notes

- This is a read-only view initially (drag-and-drop can come later)
- Needs a new controller action `boardAction()` or a separate route
- Template uses CSS grid/flexbox for the Kanban layout
- Query: `DealRepository::findByPipelineGroupedByStage()`
- Consider Mautic's existing JS patterns for tab switching

## Tests Required

- [ ] Functional test: board route returns 200
- [ ] Functional test: board shows deals in correct columns

## Done Definition

- [ ] All acceptance criteria verified
- [ ] `harness/lint-local.sh` passes
- [ ] `harness/test-local.sh` passes
- [ ] Browser smoke tests verified manually
- [ ] PR created with summary

## Decision Log

| Decision | Rationale |
|----------|-----------|
