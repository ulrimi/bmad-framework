# Story: Quality Scoring Template and /score Command

Story: Create QUALITY_SCORE.md template and /score command for per-domain quality grading
Story ID: aap-002
Epic: agent-autonomy-pipeline
Priority: Medium
Estimated Effort: M
Status: ✅ Complete
**Completed**: 2026-03-13
Assigned to: backend-specialist
Created: 2026-03-13

## User Story
As an engineer managing an agent-generated codebase
I want per-domain quality scores tracked over time
So that I can identify which areas of the codebase are degrading and prioritize maintenance work

## Business Context

### Problem Statement
Without quality scoring, codebase degradation is invisible until it becomes a crisis. The harness engineering report describes quality grades per domain and architectural layer as essential for continuous garbage collection. BMAD has no equivalent — quality is checked per-story (Phase 7 simplification) but never tracked at the domain level across time.

### Business Value
Quality scores create visibility into codebase health trends. They answer "is the auth module getting better or worse?" and "which domain needs attention this sprint?" This enables proactive maintenance instead of reactive firefighting.

## Acceptance Criteria

**AC1:** QUALITY_SCORE.md template exists
- Given I look at `.claude/bmad-template/docs/QUALITY_SCORE.md`
- When I read it
- Then it contains a scoring framework with: domains/modules, scoring criteria, current scores, score history, and improvement priorities

**AC2:** Scoring criteria are concrete
- Given I read the scoring criteria
- When I evaluate them
- Then each criterion is measurable (e.g., "test coverage > 80%", "no files over 300 lines", "all public functions have docstrings") not subjective

**AC3:** /score command exists
- Given I run `/score`
- When the command completes
- Then it reads the current codebase, evaluates against QUALITY_SCORE.md criteria, and outputs a score per domain with delta from last recorded score

**AC4:** Score history is tracked
- Given I run `/score` multiple times
- When I read QUALITY_SCORE.md
- Then it contains timestamped historical scores showing trends

## Technical Context

### Existing Patterns to Follow
- Command files live in `.claude/commands/`
- The `/review` command shows how to analyze code and output structured findings
- Template files live in `.claude/bmad-template/`

### Dependencies
None.

## Implementation Guidance

### Files to Create
- `.claude/bmad-template/docs/QUALITY_SCORE.md` — Template with scoring framework
- `.claude/commands/score.md` — The /score command definition

### Scoring Framework Design
```markdown
## Scoring Criteria
| Criterion | Weight | How to Measure |
|-----------|--------|----------------|
| Test coverage | 20% | Coverage report or estimate from test/code ratio |
| Lint cleanliness | 15% | Zero lint warnings |
| File size discipline | 15% | No files over configured line limit |
| Documentation coverage | 15% | Public interfaces documented |
| Dependency hygiene | 15% | No circular deps, clean layer boundaries |
| Error handling | 10% | Errors handled at boundaries, not swallowed |
| Code freshness | 10% | No stale TODOs, no dead code |

## Domain Scores
| Domain | Score | Trend | Last Updated | Notes |
|--------|-------|-------|--------------|-------|
| auth | B+ | ↑ | 2026-03-13 | Improved after security audit story |
| api | A- | → | 2026-03-10 | Stable |
```

## Testing Requirements

### Manual Testing
- Verify template renders with clear scoring framework
- Verify /score command reads criteria and outputs assessments

## Definition of Done
- [x] QUALITY_SCORE.md template created
- [x] /score command created
- [x] Scoring criteria are measurable, not subjective
- [x] Score history section tracks trends over time
- [x] Story status updated

## Completion Notes

**Implemented**: 2026-03-13
**Commit**: bdccf97

### Files Changed
- `.claude/bmad-template/docs/QUALITY_SCORE.md` — Enhanced with per-domain scoring, grade scale, measurable criteria, history, and improvement priorities
- `.claude/commands/score.md` — New /score command with 7-step evaluation process

### Simplification Results
- Files reviewed: 2
- Issues found: 0
- Status: No issues found

### Self-Review Results
- Findings: 0
- Status: Clean
