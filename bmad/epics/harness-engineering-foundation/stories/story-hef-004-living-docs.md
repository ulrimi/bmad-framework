# Story: Living Document Sections in Epic Template

Story: Add Progress, Surprises, Decision Log, and Retrospective sections to epic template
Story ID: hef-004
Epic: harness-engineering-foundation
Priority: Medium
Estimated Effort: S
Status: ✅ Complete
**Completed**: 2026-03-13
Assigned to: backend-specialist
Created: 2026-03-13

## User Story
As an engineer managing a complex epic
I want the epic template to include living-document sections
So that architectural decisions, surprising discoveries, and progress are captured as the work happens rather than lost between agent sessions

## Business Context

### Problem Statement
Current epic-overview.md files are static planning documents. Once stories are created, the epic file doesn't evolve. This means discoveries made during implementation (performance gotchas, API quirks, design pivots) are only captured in individual story completion notes — if at all. The ExecPlans spec emphasizes that plans must be living documents updated at every stopping point.

### Business Value
Living-document sections turn the epic from a static plan into a knowledge accumulator. Future agent sessions working on later stories in the epic can read the Decision Log and Surprises sections to avoid repeating mistakes and understand why earlier choices were made.

## Acceptance Criteria

**AC1:** Epic template has four new sections
- Given I read `.claude/bmad-template/templates/epic-template.md`
- When I review the sections
- Then it includes: Progress, Surprises & Discoveries, Decision Log, and Outcomes & Retrospective

**AC2:** Progress section uses timestamped checklist
- Given I look at the Progress section template
- When I read the format guidance
- Then it shows a granular checklist with ISO timestamp format (e.g., `- [x] (2026-03-10) Completed step`)

**AC3:** Decision Log captures rationale
- Given I look at the Decision Log section template
- When I read the format guidance
- Then each entry has: date, decision, rationale, and alternatives considered

**AC4:** Sections are placed after static planning sections
- Given I read the full template
- When I review section ordering
- Then the living-document sections appear after the static planning sections (Scope, Story Breakdown, etc.) and before any footer

## Technical Context

### Existing Patterns to Follow
- The epic template is at `.claude/bmad-template/templates/epic-template.md`
- The story template already has completion notes sections that get filled during implementation
- The ExecPlan spec (01-harness-engineering-guide.md Section 5.2) defines the four sections we're adding

### Dependencies
None.

## Implementation Guidance

### Files to Modify
- `.claude/bmad-template/templates/epic-template.md` — Add four new sections

### Section Templates

**Progress:**
```markdown
## Progress
<!-- Updated at every major milestone. Use ISO dates. -->
- [ ] Epic created and stories defined
- [ ] Story 001 complete
```

**Surprises & Discoveries:**
```markdown
## Surprises & Discoveries
<!-- Unexpected behaviors, performance tradeoffs, or bugs discovered during implementation. -->
_None yet._
```

**Decision Log:**
```markdown
## Decision Log
<!-- Every significant design decision with rationale. -->
| Date | Decision | Rationale | Alternatives Considered |
|------|----------|-----------|------------------------|
| | | | |
```

**Outcomes & Retrospective:**
```markdown
## Outcomes & Retrospective
<!-- Summary at major milestones or epic completion. Compare result against original business value. -->
_To be filled at epic completion._
```

## Testing Requirements

### Manual Testing
- Verify template renders correctly in markdown
- Verify `/epic` command creates epics with the new sections

## Definition of Done
- [x] Four living-document sections added to epic-template.md
- [x] Sections have clear format guidance and examples
- [x] Sections appear in logical order (after planning, before footer)
- [x] Story status updated

## Completion Notes

**Implemented**: 2026-03-13
**Commit**: 4cbccb5

### Files Changed
- `.claude/bmad-template/templates/epic-template.md` — Added Progress, Surprises & Discoveries, Decision Log, Outcomes & Retrospective sections

### Simplification Results
- Files reviewed: 1
- Issues found: 0
- Status: No issues found

### Self-Review Results
- Findings: 0
- All acceptance criteria verified
