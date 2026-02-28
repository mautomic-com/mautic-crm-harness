# Feature: Custom Deal Fields

## Status: Backlog

## Branch: `feature/007-custom-deal-fields`

## Summary

Allow admins to define custom fields on deals (text, number, select, date, etc.),
similar to Mautic's contact custom fields. Custom fields appear on the deal
form and are accessible via the API.

## Acceptance Criteria

- [ ] AC-1: Admin can create custom deal fields (Settings → Custom Fields → Deals)
- [ ] AC-2: Supported field types: text, textarea, number, select, date, boolean
- [ ] AC-3: Fields can be organized into groups
- [ ] AC-4: Fields can be marked as required
- [ ] AC-5: Custom fields appear on the deal create/edit form
- [ ] AC-6: Custom field values saved and displayed on deal detail view
- [ ] AC-7: Custom fields accessible via REST API
- [ ] AC-8: Custom fields searchable in deal list

## Browser Smoke Tests

1. Navigate to Settings → Custom Fields → Deals tab. Click "New Field".
2. Create a text field "Contract Number" (required). Save.
3. Create a select field "Deal Source" with options: Inbound, Outbound, Referral. Save.
4. Navigate to CRM → Deals → New. Verify both custom fields appear on form.
5. Fill the deal with custom field values. Save. Verify on detail view.
6. Edit the deal. Verify custom field values pre-filled. Change values. Save.
7. Via API, create a deal with custom field values. Verify in response.

## Technical Notes

- Mirror LeadBundle's custom field architecture: `DealField` entity + `DealFieldValue` entity
- Admin UI uses Mautic's existing custom field management pattern
- Form rendering: dynamic form fields added via form event subscriber
- API: serialize/deserialize custom fields in API metadata
- This is the most complex feature — may need to be split into sub-features

## Tests Required

- [ ] Unit test: DealField entity
- [ ] Functional test: create custom field via admin UI
- [ ] Functional test: deal form includes custom fields
- [ ] API test: custom field values in deal CRUD

## Done Definition

- [ ] All acceptance criteria verified
- [ ] `harness/lint-local.sh` passes
- [ ] `harness/test-local.sh` passes
- [ ] Browser smoke tests verified manually
- [ ] PR created with summary

## Decision Log

| Decision | Rationale |
|----------|-----------|
