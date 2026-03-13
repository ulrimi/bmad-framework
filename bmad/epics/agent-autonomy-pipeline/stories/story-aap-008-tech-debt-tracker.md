# Story: Tech Debt Tracker Template

Story: Create tech-debt-tracker.md template and integrate with /maintain
Story ID: aap-008
Epic: agent-autonomy-pipeline
Priority: Low
Estimated Effort: S
Status: ✅ Complete
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
- [x] tech-debt-tracker.md template created
- [x] Items table is structured and sortable
- [x] Categories are defined
- [x] Resolved items section for history
- [x] Story status updated

## Completion Notes

**Implemented**: 2026-03-13
**Commit**: 971a3bd

### Files Changed
- `.claude/bmad-template/docs/exec-plans/tech-debt-tracker.md` — Expanded template with full 8-column Active Items table, Categories section, Resolved Items table, and Last Scanned marker
- `.claude/commands/maintain.md` — Updated Step 5 format to match new table structure with categories and effort columns

### Simplification Results
- Files reviewed: 2
- Issues found: 0
- Issues fixed: 0
- Lines removed: 0
- Status: No issues found

### CodeRabbit Review Results
- Findings: 0 total (0 critical, 0 suggestions, 0 nits)
- All addressed: N/A
- Re-review cycles: 0
- Remaining items: None

### Notes
- Template already existed from HEF-005 but had a simpler 6-column format; expanded to match story AC2 requirements
- init-bmad --full already handles copying this template (no changes needed)
- /maintain already had Step 5 for tracker updates; updated format string to match new columns
