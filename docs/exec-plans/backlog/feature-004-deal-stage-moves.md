# Feature: Deal Stage Movement & History

## Status: Backlog

## Branch: `feature/004-deal-stage-moves`

## Summary

Track deal stage changes with timestamps, enable drag-style stage progression
from the deal detail page, and log stage history in the activity timeline.

## Acceptance Criteria

- [ ] AC-1: Deal detail page shows current pipeline and stage prominently
- [ ] AC-2: Stage can be changed from deal detail page via dropdown or buttons (without full edit form)
- [ ] AC-3: Stage changes are logged in the audit log / activity timeline
- [ ] AC-4: Stage change log shows: from-stage, to-stage, timestamp, user who changed
- [ ] AC-5: When stage changes to "won" type, deal is visually marked as won
- [ ] AC-6: When stage changes to "lost" type, deal is visually marked as lost
- [ ] AC-7: Pipeline change on deal resets stage to first stage of new pipeline

## Browser Smoke Tests

1. Open a deal. Verify current pipeline/stage shown prominently.
2. Change stage using the quick-change control. Verify stage updates without full page reload.
3. Check activity timeline. Verify stage change logged with from/to.
4. Change to a "won" stage. Verify visual indicator.
5. Edit deal, change pipeline. Verify stage resets to first of new pipeline.

## Technical Notes

- May need a `DealStageLog` entity or use Mautic's audit log system
- Quick stage change could use AJAX endpoint
- Consider EventListener on `DEAL_PRE_SAVE` to detect stage changes
- Won/lost visual treatment: badge or status indicator on detail view

## Tests Required

- [ ] Unit test: stage change detection
- [ ] Functional test: change stage via API, verify log
- [ ] Functional test: pipeline change resets stage

## Done Definition

- [ ] All acceptance criteria verified
- [ ] `harness/lint-local.sh` passes
- [ ] `harness/test-local.sh` passes
- [ ] Browser smoke tests verified manually
- [ ] PR created with summary

## Decision Log

| Decision | Rationale |
|----------|-----------|
