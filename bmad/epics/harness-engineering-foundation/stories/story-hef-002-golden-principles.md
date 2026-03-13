# Story: Golden Principles Template

Story: Create golden-principles.md template for encoding project taste invariants
Story ID: hef-002
Epic: harness-engineering-foundation
Priority: High
Estimated Effort: S
Status: ✅ Complete
**Completed**: 2026-03-13
Assigned to: backend-specialist
Created: 2026-03-13

## User Story
As an engineer setting up a BMAD project
I want a golden-principles.md template that captures opinionated code quality rules
So that agents consistently produce code that matches the team's taste without requiring repeated human correction

## Business Context

### Problem Statement
The harness engineering report found that agents replicate patterns that already exist in the repo — including suboptimal ones. Without a documented set of "golden principles" (opinionated, mechanical rules about code quality), agents drift toward inconsistency. Human taste gets captured once through this document and enforced continuously.

### Business Value
Reduces the "Friday cleanup" problem (the OpenAI team spent 20% of their week cleaning up agent code) by making taste explicit and discoverable. Every agent session reads the same rules, producing consistent output from the start.

## Acceptance Criteria

**AC1:** Template exists with sensible defaults
- Given I look at `.claude/bmad-template/templates/golden-principles.md`
- When I read it
- Then it contains 10-15 opinionated rules organized by category (code style, dependencies, error handling, testing, documentation) with brief rationale for each

**AC2:** Template is stack-aware
- Given I read the template
- When I review the rules
- Then each rule is written generically enough to apply across stacks, with `<!-- TODO: ... -->` markers for stack-specific customization

**AC3:** init-bmad scaffolds golden-principles.md
- Given I run `init-bmad` in a new project
- When the script completes
- Then `bmad/qf-bmad/golden-principles.md` exists with the template content

**AC4:** CLAUDE.md references golden principles
- Given the project has a golden-principles.md
- When I read CLAUDE.md
- Then it contains a pointer to `bmad/qf-bmad/golden-principles.md` as a key reference

## Technical Context

### Existing Patterns to Follow
- Template files in `.claude/bmad-template/` are copied by init-bmad
- The checklists directory already has quality gate documents (pre-work.md, post-work.md)
- Golden principles complement but don't replace checklists — checklists are procedural, principles are philosophical

### Dependencies
None.

## Implementation Guidance

### Files to Create
- `.claude/bmad-template/templates/golden-principles.md` — Template with default principles (init-bmad copies to `bmad/qf-bmad/golden-principles.md`)

### Files to Modify
- `.claude/scripts/init-bmad` — Copy golden-principles.md to `bmad/qf-bmad/golden-principles.md`
- `.claude/bmad-template/CLAUDE.md.template` — Add reference to golden-principles.md in Key References section

### Starter Principles (customize per project)
1. Prefer shared utility packages over hand-rolled helpers
2. Validate at boundaries, trust internal data shapes
3. Favor boring technologies well-represented in training data
4. Keep functions under 50 lines; extract when logic is reusable
5. Error messages should contain remediation instructions
6. No print-statement debugging in committed code
7. One responsibility per file; split when concerns diverge
8. Tests mirror the module structure they validate
9. External API calls are wrapped in a single integration module
10. Configuration lives in config files, not scattered across code

## Testing Requirements

### Manual Testing
- Run `init-bmad` and verify golden-principles.md is scaffolded
- Verify CLAUDE.md template references golden-principles.md

## Definition of Done
- [x] golden-principles.md template created
- [x] init-bmad copies it to bmad/qf-bmad/
- [x] CLAUDE.md template references it
- [x] Principles are generic enough for any stack
- [x] Story status updated

## Completion Notes

**Implemented**: 2026-03-13
**Commit**: 4cbccb5

### Files Changed
- `.claude/bmad-template/templates/golden-principles.md` — Created (13 rules across 5 categories)
- `.claude/bmad-template/CLAUDE.md.template` — Added golden-principles.md to Key References table
- `.claude/scripts/init-bmad` — Added golden-principles copy logic

### Simplification Results
- Files reviewed: 3
- Issues found: 0
- Status: No issues found

### Self-Review Results
- Findings: 0
- All acceptance criteria verified
