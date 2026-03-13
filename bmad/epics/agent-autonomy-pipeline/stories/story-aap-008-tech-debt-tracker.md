# Story: Tech Debt Tracker Template

Story: Create tech-debt-tracker.md template and integrate with /maintain
Story ID: aap-008
Epic: agent-autonomy-pipeline
Priority: Low
Estimated Effort: S
Status: Draft
Assigned to: backend-specialist
Created: 2026-03-13

## User Story
As an engineer managing technical debt in an agent-generated codebase
I want a structured tech debt tracker that gets automatically updated by /maintain
So that debt is visible, prioritized, and systematically addressed rather than accumulating invisibly

## Business Context

### Problem Statement
Technical debt in agent-generated codebases compounds faster because agents replicate existing patterns, including suboptimal ones. Without a structured tracker, debt is invisible until it causes failures. The harness engineering report recommends a tech-debt-tracker.md that is updated on a regular cadence with prioritized items.

### Business Value
A living tech debt tracker enables "garbage collection" — continuous small payments that prevent compounding. Combined with /maintain, it creates a feedback loop: scan finds debt → tracker records it → stories address it → debt shrinks.

## Acceptance Criteria

**AC1:** Template exists
- Given I look at `.claude/bmad-template/docs/exec-plans/tech-debt-tracker.md`
- When I read it
- Then it contains: categories (code quality, architecture, documentation, testing, dependencies), a prioritized items table, and a resolved items section

**AC2:** Items are structured
- Given I read the items table format
- When I review each column
- Then items have: ID, category, severity (high/medium/low), description, affected files/modules, recommended fix, effort estimate, and status

**AC3:** /maintain updates the tracker
- Given /maintain has been run (story aap-003)
- When it produces findings
- Then new items are appended to the tracker and existing items are updated with current status

**AC4:** Scaffolded with --full flag
- Given I run `init-bmad --full`
- When the script completes
- Then `docs/exec-plans/tech-debt-tracker.md` exists with the template

## Technical Context

### Existing Patterns to Follow
- docs/ scaffold (from hef-005) creates exec-plans/ directory
- Template files in `.claude/bmad-template/` are copied by init-bmad

### Dependencies
- Story aap-003 (/maintain command) — the tracker is updated by /maintain
- Story hef-005 (docs scaffold) — provides the directory structure

## Implementation Guidance

### Files to Create
- `.claude/bmad-template/docs/exec-plans/tech-debt-tracker.md` — Template

### Template Design
```markdown
# Tech Debt Tracker

## Active Items
| ID | Category | Severity | Description | Affected | Recommended Fix | Effort | Status |
|----|----------|----------|-------------|----------|-----------------|--------|--------|
| TD-001 | example | low | Example item | src/utils/ | Consolidate helpers | S | Open |

## Resolved Items
| ID | Category | Description | Resolution | Resolved Date |
|----|----------|-------------|------------|---------------|

## Categories
- **Code Quality**: Duplicated patterns, oversized files, missing validation
- **Architecture**: Layer violations, circular dependencies, boundary issues
- **Documentation**: Stale docs, missing docs, inaccurate architecture descriptions
- **Testing**: Low coverage areas, missing edge case tests, flaky tests
- **Dependencies**: Outdated packages, unnecessary dependencies, version conflicts

## Last Scanned
_Not yet scanned. Run `/maintain` to populate._
```

## Testing Requirements

### Manual Testing
- Verify template created by init-bmad --full
- Verify format is parseable by /maintain for updates

## Definition of Done
- [ ] tech-debt-tracker.md template created
- [ ] Items table is structured and sortable
- [ ] Categories are defined
- [ ] Resolved items section for history
- [ ] Story status updated
