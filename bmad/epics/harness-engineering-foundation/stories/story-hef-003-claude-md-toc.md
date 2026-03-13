# Story: Restructure CLAUDE.md as Table of Contents

Story: Restructure CLAUDE.md.template as a ~100-line table of contents with pointers to deeper docs
Story ID: hef-003
Epic: harness-engineering-foundation
Priority: High
Estimated Effort: M
Status: Draft
Assigned to: backend-specialist
Created: 2026-03-13

## User Story
As a coding agent starting a new task
I want CLAUDE.md to be a short, stable map pointing to deeper sources of truth
So that I get oriented quickly without being overwhelmed by a monolithic instruction file that crowds out task context

## Business Context

### Problem Statement
The harness engineering report identifies monolithic instruction files as a predictable failure mode: they crowd out task context, create a false sense of guidance where nothing stands out, rot as the codebase evolves, and resist mechanical verification. The current CLAUDE.md.template embeds all instructions inline — style mandates, commands, testing standards, security guidelines — creating exactly this problem.

### Business Value
A table-of-contents CLAUDE.md enables progressive disclosure: agents start with a small, stable entry point and navigate to deeper context only when relevant. This preserves context window for actual task work and makes each pointer independently verifiable and updateable.

## Acceptance Criteria

**AC1:** CLAUDE.md template is under 120 lines
- Given I count lines in the new `.claude/bmad-template/CLAUDE.md.template`
- When I exclude blank lines and comments
- Then substantive content is under 120 lines

**AC2:** Template uses pointer format
- Given I read the template
- When I look at each section
- Then detailed content is referenced by file path (e.g., "See `bmad/qf-bmad/golden-principles.md`") rather than embedded inline

**AC3:** Critical commands remain inline
- Given I read the template
- When I look for development commands (test, lint, launch)
- Then they are still directly in CLAUDE.md (these are high-frequency lookups that shouldn't require navigation)

**AC4:** Backward compatible
- Given a project bootstrapped before this change (no docs/ directory)
- When the agent reads the new CLAUDE.md format
- Then pointers to non-existent files gracefully indicate "create this if needed" rather than breaking

**AC5:** Key references table includes all knowledge sources
- Given I read the Key References section
- When I review the table
- Then it includes pointers to: ARCHITECTURE.md, golden-principles.md, core-beliefs.md (if docs/ exists), core-config.yaml, specialist agents directory, epic directory, and docs/ subdirectories

## Technical Context

### Existing Patterns to Follow
- Current CLAUDE.md.template is at `.claude/bmad-template/CLAUDE.md.template`
- It uses `{{PLACEHOLDER}}` format for auto-detection values
- The `/configure` command fills these placeholders

### Dependencies
- Story hef-001 (architecture template) — need to know the path to reference
- Story hef-002 (golden principles) — need to know the path to reference
- Story hef-007 (core beliefs) — need to know the path to reference

## Implementation Guidance

### Files to Modify
- `.claude/bmad-template/CLAUDE.md.template` — Restructure to table-of-contents format

### Design Principles
- The top of CLAUDE.md should have: project name, one-line description, and the BMAD workflow mandate
- Then a "Quick Commands" section with the commands table (high-frequency, stays inline)
- Then a "Development Commands" section with test/lint/launch commands (high-frequency, stays inline)
- Then a "Key References" table pointing to deeper docs
- Detailed sections (Code Style, Testing Standards, Security) move to referenced docs or remain as 2-3 line summaries with pointers
- The file should feel like a README table of contents, not an instruction manual

## Testing Requirements

### Manual Testing
- Run `init-bmad` and verify new CLAUDE.md is under 120 lines
- Verify all pointer targets match actual scaffold paths
- Verify development commands are still inline

## Definition of Done
- [ ] CLAUDE.md.template restructured as table of contents
- [ ] Under 120 lines of substantive content
- [ ] All detailed sections either moved to referenced files or summarized with pointers
- [ ] Development commands remain inline
- [ ] Key References table is complete
- [ ] Backward compatible with projects that don't have docs/
- [ ] Story status updated
