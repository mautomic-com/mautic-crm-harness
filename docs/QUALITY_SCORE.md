# Quality Score

Grades each domain and layer. Updated after each phase completion.

## Grading Scale

- **A**: Complete, tested, documented, reviewed
- **B**: Complete and tested, minor gaps
- **C**: Functional but incomplete tests or docs
- **D**: Partially implemented
- **F**: Not started

## Domain Scores

| Domain     | Entity | Repository | Model | Controller | API | Form | Views | Tests | Overall |
|------------|--------|------------|-------|------------|-----|------|-------|-------|---------|
| Pipeline   | F      | F          | F     | F          | F   | F    | F     | F     | **F**   |
| Stage      | F      | F          | F     | -          | -   | F    | -     | F     | **F**   |
| Deal       | F      | F          | F     | F          | F   | F    | F     | F     | **F**   |
| Task       | F      | F          | F     | F          | F   | F    | F     | F     | **F**   |
| Note       | F      | F          | F     | F          | F   | F    | F     | F     | **F**   |

## Infrastructure Scores

| Component          | Score | Notes                  |
|--------------------|-------|------------------------|
| Config/config.php  | F     | Not started            |
| Config/services.php| F     | Not started            |
| Permissions        | F     | Not started            |
| Translations       | F     | Not started            |
| Menu items         | F     | Not started            |
| CI pipeline        | F     | Not started            |

## Tech Debt

See [exec-plans/tech-debt-tracker.md](exec-plans/tech-debt-tracker.md).
