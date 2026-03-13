# Story: ExecPlan Template and /plan Command

Story: Create ExecPlan template based on Codex ExecPlans spec and add /plan command
Story ID: hef-006
Epic: harness-engineering-foundation
Priority: Medium
Estimated Effort: M
Status: ✅ Complete
**Completed**: 2026-03-13
Assigned to: backend-specialist
Created: 2026-03-13

## User Story
As an engineer tackling complex multi-story work with significant unknowns
I want to create an ExecPlan — a living design document that guides an agent through research, prototyping, and implementation
So that complex work is systematically de-risked and all decisions, discoveries, and progress are captured in a self-contained document

## Business Context

### Problem Statement
BMAD stories work well for well-understood work with clear acceptance criteria. But complex initiatives — architectural migrations, research spikes, multi-phase rollouts — need a higher-level planning artifact. The Codex ExecPlans spec provides this: a living document that combines design rationale, concrete steps, progress tracking, and retrospective analysis. Currently BMAD has no equivalent.

### Business Value
ExecPlans fill the gap between "epic overview" (strategic) and "story" (tactical). They're the operating document for complex work that spans multiple stories and involves significant unknowns. Without them, the context from research and prototyping phases gets lost between agent sessions.

## Acceptance Criteria

**AC1:** ExecPlan template exists
- Given I look at `.claude/bmad-template/templates/exec-plan-template.md`
- When I read it
- Then it contains all sections from the ExecPlans spec: Purpose/Big Picture, Progress, Surprises & Discoveries, Decision Log, Outcomes & Retrospective, Context and Orientation, Plan of Work, Concrete Steps, Validation and Acceptance, Idempotence and Recovery, Interfaces and Dependencies

**AC2:** Template enforces self-containment
- Given I read the template
- When I look at the authoring guidance
- Then it explicitly states: "This plan must be implementable by an agent with no prior context — only the working tree and this plan. Do not point to external docs; embed all required knowledge."

**AC3:** /plan command creates ExecPlans
- Given I run `/plan auth-migration`
- When the command completes
- Then a file exists at `docs/exec-plans/active/auth-migration.md` (or `bmad/epics/[current-epic]/auth-migration-plan.md` if no docs/ directory) with the template content and the title filled in

**AC4:** Template includes prototyping milestones section
- Given I read the Plan of Work section
- When I review the guidance
- Then it includes instructions for adding explicit proof-of-concept milestones to de-risk unknowns

**AC5:** Progress section uses timestamps
- Given I look at the Progress section
- When I review the format
- Then it uses ISO-format timestamps (e.g., `- [x] (2026-03-10 14:00Z) Completed step`)

## Technical Context

### Architecture Reference
ExecPlan specification: Section 5 of 01-harness-engineering-guide.md

### Existing Patterns to Follow
- Command files live in `.claude/commands/`
- Template files live in `.claude/bmad-template/templates/`
- The `/epic` command shows how to create files with templates

### Dependencies
- Story hef-005 (docs scaffold) — for the `docs/exec-plans/active/` directory
- But the command should gracefully handle missing docs/ directory by falling back to bmad/epics/

## Implementation Guidance

### Files to Create
- `.claude/bmad-template/templates/exec-plan-template.md` — The ExecPlan template
- `.claude/commands/plan.md` — The /plan command definition

### Key Design Decisions
- ExecPlans live in docs/exec-plans/active/ when the docs/ layer exists, or alongside epics when it doesn't
- When an ExecPlan is completed, it moves to docs/exec-plans/completed/
- The /plan command should gather context (similar to /epic) before populating the template
- Write in prose (per the spec) — checklists only in the Progress section

## Testing Requirements

### Manual Testing
- Run `/plan test-migration` and verify file creation
- Verify all template sections are present
- Verify self-containment guidance is prominent

## Definition of Done
- [x] exec-plan-template.md created with all spec sections
- [x] /plan command created and functional
- [x] Template enforces self-containment principle
- [x] Graceful fallback when docs/ directory doesn't exist
- [x] Story status updated

## Completion Notes

**Implemented**: 2026-03-13
**Commit**: e0607ee

### Files Changed
- `.claude/bmad-template/templates/exec-plan-template.md` — New ExecPlan template with all 11 spec sections
- `.claude/commands/plan.md` — New /plan command with context-gathering agents and docs/ fallback

### Simplification Results
- Files reviewed: 2
- Issues found: 0
- Issues fixed: 0
- Lines removed: 0
- Status: No issues found

### CodeRabbit Review Results
- Skipped per user request

### Notes
- Template self-containment principle is a blockquote at document top for maximum visibility
- /plan command follows the /epic command pattern (parallel Explore + Plan agents)
- Progress section uses ISO timestamps with `HH:MMZ` granularity per spec
