# Feature: Notes & Activity Timeline on Deals

## Status: Backlog

## Branch: `feature/003-notes-timeline`

## Summary

Add notes to deals with type categorization (general, call, meeting, email) and
display them as a chronological activity timeline on the deal detail page.

## Acceptance Criteria

- [ ] AC-1: Deal detail page has an "Add Note" button/form
- [ ] AC-2: Notes can be categorized by type: general, call, meeting, email
- [ ] AC-3: Each note type has a distinct icon (ri-chat-1-line, ri-phone-line, ri-team-line, ri-mail-line)
- [ ] AC-4: Notes display in reverse chronological order on the deal detail page
- [ ] AC-5: Notes show author name and timestamp
- [ ] AC-6: Users can edit/delete their own notes
- [ ] AC-7: Notes linked to contacts also appear on the deal timeline (if deal has that contact)
- [ ] AC-8: API supports CRUD for notes with deal_id and contact_id

## Browser Smoke Tests

1. Open a deal detail page. Verify "Activity" or "Notes" section exists.
2. Click "Add Note". Select type "Call". Enter text "Discussed pricing". Save.
3. Verify note appears with phone icon, author name, and timestamp.
4. Add a second note of type "Email". Verify both notes in reverse chronological order.
5. Click edit on a note. Change text. Save. Verify update.
6. Delete a note. Verify removed from timeline.

## Technical Notes

- Note entity already exists with `text`, `type`, `deal`, `contact` fields
- NoteType form already exists with basic fields
- Need to add note creation inline on deal detail page (or via modal)
- NoteRepository needs `findByDeal()` with ordering
- Consider using Mautic's AJAX modal pattern for note creation

## Tests Required

- [ ] Functional test: create note on deal, verify timeline
- [ ] API test: CRUD for notes with deal linkage
- [ ] Unit test: NoteRepository::findByDeal()

## Done Definition

- [ ] All acceptance criteria verified
- [ ] `harness/lint-local.sh` passes
- [ ] `harness/test-local.sh` passes
- [ ] Browser smoke tests verified manually
- [ ] PR created with summary

## Decision Log

| Decision | Rationale |
|----------|-----------|
