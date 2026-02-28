# Product Spec: Deal Automation (Phase 3)

## Goal

Integrate deals with Mautic's campaign builder so that deal stage changes
can trigger campaigns and campaigns can update deals.

## User Stories

### Campaign Triggers
- As a marketer, I can add a "Deal stage changed" trigger to a campaign.
- I can filter the trigger by: pipeline, from-stage, to-stage.
- The trigger fires when any deal linked to the contact changes stage.

### Campaign Actions
- As a marketer, I can add an "Update deal stage" action to a campaign.
- I can specify which pipeline and target stage.
- The action moves the contact's deal(s) to the specified stage.

### Segment Filters
- As a marketer, I can create a segment filter: "Has deal in pipeline X".
- As a marketer, I can create a segment filter: "Has deal at stage Y".
- As a marketer, I can create a segment filter: "Deal amount greater than Z".

## Acceptance Criteria

1. Campaign trigger fires correctly when a deal stage changes.
2. Campaign action moves the correct deal(s) to the specified stage.
3. Segment filters correctly include/exclude contacts.
4. All campaign events have proper descriptions and form fields.
5. Full test coverage including campaign execution tests.
