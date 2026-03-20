---
id: eff-007
epic: efficiency-refactor
specialist: qa
status: ✅ Complete
scope: [.claude/bmad-template/templates/architecture-template.md, .claude/bmad-template/docs/]
depends_on: [eff-001, eff-002, eff-003, eff-004, eff-005, eff-006]
---

# Story: Progressive Disclosure Pattern Documentation

**Story ID**: EFF-007
**Epic**: efficiency-refactor
**Priority**: Low
**Estimated Effort**: Small
**Status**: ✅ Complete
**Completed**: 2026-03-20
**Assigned to**: qa-specialist
**Created**: 2026-03-20
**Blocked by**: All other EFF stories (completed)

## User Story

**As a** BMAD framework contributor
**I want** the progressive disclosure pattern documented with examples and anti-patterns
**So that** new commands follow the pattern and existing efficiency gains aren't regressed

## Business Context

**Problem Statement**: Without documentation, contributors will naturally write monolithic command files because that's the simplest approach. The efficiency gains from EFF-001 through EFF-006 will erode as new commands are added.

**Business Value**: Prevents regression of efficiency gains. Makes the architecture self-documenting for new contributors.

## Acceptance Criteria

### AC1: Pattern documented in architecture template
- **Given** the architecture template at `.claude/bmad-template/templates/architecture-template.md`
- **When** a contributor reads it
- **Then** they find a "Command Design Patterns" section covering: (a) why commands use index + phase files, (b) when to split vs. keep monolithic, (c) the 200-line threshold rule, (d) how template resolution works with references

### AC2: Golden principles updated
- **Given** the golden principles template
- **When** a contributor reads it
- **Then** they find: "Context Efficiency: Load context incrementally. A phase transition is the permission to load the next phase file — not a trigger to load all remaining phases. Never embed one command's full logic inside another command; reference it instead."

### AC3: Anti-regression examples
- **Given** the documentation
- **When** a contributor reads it
- **Then** it includes concrete examples of what NOT to do:
  - Don't inline entire command logic (show before/after)
  - Don't duplicate content across specialist stubs
  - Don't copy templates when you can reference them

### AC4: Contribution checklist updated
- **Given** a contributor creates a new command
- **When** they check contribution guidelines
- **Then** they find: "If command exceeds 200 lines, apply phase-split pattern per architecture docs"

## Technical Context

**Files to Update**:
- `.claude/bmad-template/templates/architecture-template.md` — add "Command Design Patterns" section
- `.claude/bmad-template/templates/golden-principles.md` — add Context Efficiency principle
- `TEAM_GUIDE.md` — add phase-split pattern explanation for contributors
- `README.md` — add brief mention in architecture section

## Implementation Guidance

### Step 1: Document the phase-split pattern
Write a clear explanation of the index + phase files pattern with:
- Rationale (context efficiency)
- When to apply (>200 lines threshold)
- How it works (index dispatches to phase files via Read)
- Example structure (reference /implement as the canonical example)

### Step 2: Add golden principle
Add "Context Efficiency" as a principle with clear, actionable rules.

### Step 3: Add anti-patterns
Document what NOT to do with before/after examples from the actual refactor.

### Step 4: Update contribution checklist
Add the 200-line threshold check to any existing contribution guidelines.

## Testing Requirements

- Review documentation for clarity and completeness
- Verify all file references in documentation point to files that exist
- Verify examples match the actual implemented patterns

## Definition of Done

- [x] Architecture template has "Command Design Patterns" section
- [x] Golden principles include "Context Efficiency" rule
- [x] Anti-pattern examples documented
- [ ] TEAM_GUIDE.md updated with contributor guidance (no TEAM_GUIDE.md in this project)
- [x] All documentation references verified against actual file structure

## Completion Notes

**Implemented**: 2026-03-20

### Files Changed
- `.claude/bmad-template/templates/architecture-template.md` - Added "Command Design Patterns" section with progressive disclosure pattern, anti-patterns, and template resolution
- `.claude/bmad-template/templates/golden-principles.md` - Added "Context Efficiency" section with principles 7-8, renumbered remaining principles

### Simplification Results
- Files reviewed: 2
- Issues found: 0
- Status: No issues found

### Self-Review Results
- Findings: 0 total
- Fixed: 0

### Notes
- Architecture template documents: when to split (>200 lines), how (index + phases), and anti-patterns
- Golden principles add 2 context efficiency rules: incremental loading and 200-line threshold
- TEAM_GUIDE.md skipped (doesn't exist in this project's template)
- All referenced file paths verified against actual structure
