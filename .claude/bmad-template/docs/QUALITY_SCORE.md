# Quality Score — {{PROJECT_NAME}}

Track per-domain quality metrics over time. Run `/score` to evaluate and update.

## Scoring Criteria

| Criterion | Weight | How to Measure |
|-----------|--------|----------------|
| Test coverage | 20% | Coverage report percentage or test/code file ratio |
| Lint cleanliness | 15% | Zero lint warnings from configured linter |
| File size discipline | 15% | No source files over configured line limit (default: 300) |
| Documentation coverage | 15% | All public interfaces have docstrings/JSDoc |
| Dependency hygiene | 15% | No circular dependencies, clean layer boundaries |
| Error handling | 10% | Errors handled at system boundaries, not swallowed silently |
| Code freshness | 10% | No stale TODOs (>30 days), no dead/commented-out code |

## Grade Scale

| Grade | Score Range | Meaning |
|-------|-------------|---------|
| A | 90-100 | Exemplary — could serve as a reference |
| B | 75-89 | Solid — minor improvements possible |
| C | 60-74 | Adequate — known gaps need attention |
| D | 40-59 | Below standard — significant improvement needed |
| F | 0-39 | Critical — immediate action required |

## Domain Scores

<!-- Add one row per domain/module in your project -->

| Domain | Grade | Score | Trend | Last Updated | Notes |
|--------|-------|-------|-------|--------------|-------|
<!-- Example:
| auth   | B+    | 85    | ↑     | 2026-03-13   | Improved after security audit |
| api    | A-    | 90    | →     | 2026-03-10   | Stable                        |
| data   | C     | 65    | ↓     | 2026-03-08   | Needs test coverage           |
-->

## Score History

| Date | Overall | Top Improvement | Top Regression | Notes |
|------|---------|-----------------|----------------|-------|
<!-- /score appends a row here each time it runs -->

## Improvement Priorities

<!-- /score populates this based on lowest-scoring domains -->

| Priority | Domain | Current Grade | Target Grade | Key Action |
|----------|--------|---------------|--------------|------------|
<!-- Example:
| 1 | data   | C  | B  | Add integration tests for cache layer |
| 2 | auth   | B+ | A  | Document remaining public APIs         |
-->
