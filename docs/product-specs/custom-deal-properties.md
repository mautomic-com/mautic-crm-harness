# Product Spec: Custom Deal Properties (Phase 3)

## Goal

Allow admins to define custom fields on deals, similar to Mautic's custom fields
on contacts — enabling deal data to match any sales methodology.

## User Stories

- As an admin, I can create custom fields for deals (text, number, select, date, etc.).
- As an admin, I can organize custom fields into groups.
- As an admin, I can set fields as required or optional.
- As a sales user, I can fill in custom fields when creating/editing a deal.
- As a developer, I can read/write custom fields via the API.

## Design Notes

This should mirror how `LeadBundle` handles custom fields via `LeadField` entities.
The plugin needs its own `DealField` and `DealFieldValue` entities, with a similar
field type system (text, textarea, select, multiselect, date, datetime, number, boolean, url, email, phone).

## Acceptance Criteria

1. Admin can CRUD custom deal fields from the UI.
2. Custom fields appear on the deal create/edit form.
3. Custom field values are stored and retrievable via API.
4. Field validation (required, type) works correctly.
5. Full test coverage.
