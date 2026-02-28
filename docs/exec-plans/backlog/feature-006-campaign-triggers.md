# Feature: Campaign Triggers & Actions for Deals

## Status: Backlog

## Branch: `feature/006-campaign-triggers`

## Summary

Integrate deals with Mautic's campaign builder. Add campaign triggers that fire
when deal stages change, and campaign actions that can update deal stages. Also
add segment filters based on deal properties.

## Acceptance Criteria

- [ ] AC-1: Campaign trigger "Deal stage changed" available in campaign builder
- [ ] AC-2: Trigger can filter by pipeline and specific from/to stages
- [ ] AC-3: Campaign action "Update deal stage" available in campaign builder
- [ ] AC-4: Action can specify target pipeline and stage
- [ ] AC-5: Segment filter "Has deal in pipeline" works
- [ ] AC-6: Segment filter "Has deal at stage" works
- [ ] AC-7: Segment filter "Deal amount greater than" works

## Browser Smoke Tests

1. Create a campaign. Add "Deal stage changed" trigger. Verify filter options.
2. Add "Update deal stage" action. Verify pipeline/stage selectors.
3. Create a segment with "Has deal in pipeline X". Verify it filters contacts.
4. Move a deal to a new stage. Verify campaign trigger fires.

## Technical Notes

- Follows Mautic's campaign event subscriber pattern
- Trigger: EventListener subscribing to `CampaignEvents::CAMPAIGN_ON_BUILD`
- Action: `AbstractCondition` or `AbstractAction` with form type
- Segments: custom `QueryBuilder` filter in segment subscriber
- Requires understanding of Mautic's campaign execution engine

## Tests Required

- [ ] Unit test: campaign event subscriber registration
- [ ] Functional test: trigger fires on stage change
- [ ] Functional test: action updates deal stage
- [ ] Functional test: segment filter includes correct contacts

## Done Definition

- [ ] All acceptance criteria verified
- [ ] `harness/lint-local.sh` passes
- [ ] `harness/test-local.sh` passes
- [ ] Browser smoke tests verified manually
- [ ] PR created with summary

## Decision Log

| Decision | Rationale |
|----------|-----------|
