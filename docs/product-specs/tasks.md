# Product Spec: Tasks (Phase 2)

## Goal

Enable sales users to create and manage action items linked to deals and contacts.

## User Stories

- As a sales user, I can create a task with title, description, due date, and priority.
- As a sales user, I can assign a task to myself or another user.
- As a sales user, I can link a task to a deal and/or contact.
- As a sales user, I can mark a task as completed.
- As a sales user, I can view all my tasks and filter by status, priority, due date.
- As a sales user, I can see tasks on a deal's detail page.

## Acceptance Criteria

1. Task CRUD works from UI and API.
2. Tasks list view shows: title, due date, priority, status, assignee, linked deal.
3. Overdue tasks are visually distinguished.
4. Completing a task updates its status and records when it was completed.
5. Permissions control access (own vs others' tasks).
6. Full test coverage.
