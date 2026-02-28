# Feature: Task-Deal Linking & Task on Deal Detail

## Status: Backlog

## Branch: `feature/002-task-deal-linking`

## Summary

Link tasks to deals and display them on the deal detail page. Tasks should be
assignable to a specific deal when creating/editing, and the deal detail page
should show a list of related tasks with status indicators.

## Acceptance Criteria

- [ ] AC-1: Task form has a "Deal" dropdown to link a task to a deal
- [ ] AC-2: Task form has a "Contact" dropdown to link a task to a contact
- [ ] AC-3: Deal detail page shows a "Tasks" section with linked tasks
- [ ] AC-4: Task list on deal shows: title, status, priority, due date, assignee
- [ ] AC-5: Overdue tasks highlighted visually (red text or badge)
- [ ] AC-6: Task owner defaults to current user for new tasks
- [ ] AC-7: API supports setting deal and contact on tasks

## Browser Smoke Tests

1. Navigate to CRM → Deals. Open a deal. Verify "Tasks" section exists (empty state).
2. Navigate to CRM → Tasks. Click "New". Verify Deal and Contact dropdowns present.
3. Select a deal, fill title, save. Navigate to that deal. Verify task appears.
4. Create a task with a past due date. Verify it shows as overdue on the deal page.

## Technical Notes

- Task entity already has `deal` and `contact` ManyToOne relationships
- Need to add EntityType dropdowns to TaskType form (Deal, Contact)
- Deal detail template needs a tasks panel querying `TaskRepository::findByDeal()`
- Use `IdToEntityModelTransformer` pattern if needed for form fields

## Tests Required

- [ ] Functional test: create task linked to deal, verify on deal detail
- [ ] API test: create task with deal_id, verify response
- [ ] Unit test: TaskRepository::findByDeal()

## Done Definition

- [ ] All acceptance criteria verified
- [ ] `harness/lint-local.sh` passes
- [ ] `harness/test-local.sh` passes
- [ ] Browser smoke tests verified manually
- [ ] PR created with summary

## Decision Log

| Decision | Rationale |
|----------|-----------|
