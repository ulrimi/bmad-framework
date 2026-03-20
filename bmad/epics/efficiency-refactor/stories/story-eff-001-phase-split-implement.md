---
id: eff-001
epic: efficiency-refactor
specialist: backend
status: ✅ Complete
scope: [.claude/commands/implement.md, .claude/commands/implement/]
depends_on: []
---

# Story: Phase-Split /implement into Modular Phases

**Story ID**: EFF-001
**Epic**: efficiency-refactor
**Priority**: Critical
**Estimated Effort**: Large
**Status**: ✅ Complete
**Completed**: 2026-03-20
**Assigned to**: backend-specialist
**Created**: 2026-03-20

## User Story

**As a** BMAD framework user
**I want** the `/implement` command to load only the current phase's instructions
**So that** each invocation uses ~100 lines of context upfront instead of 1,055

## Business Context

**Problem Statement**: `/implement` is the most-used BMAD command. Its 1,055-line monolith is loaded entirely into context on every invocation, regardless of which phase is active. At scale, this wastes ~65% of loaded tokens per run.

**Business Value**: Reduces token spend per implementation cycle by ~65%. At 20 engineers × 5 stories/sprint, this is the single highest-ROI change in the framework.

## Acceptance Criteria

### AC1: Index file replaces monolith
- **Given** the file `.claude/commands/implement.md` exists at 1,055 lines
- **When** the refactor is complete
- **Then** `implement.md` is under 120 lines, contains Step 0 (repo root) + argument parsing + story queue builder + phase dispatch table, and each phase instruction says "Read `.claude/commands/implement/phase-N-*.md`"

### AC2: Phase files are complete and self-contained
- **Given** the phase files exist in `.claude/commands/implement/`
- **When** a phase file is loaded via Read tool
- **Then** it contains all instructions needed for that phase without requiring other phase files to be loaded simultaneously

### AC3: Cross-phase references are handled
- **Given** Phase 10 (Commit) references the gate check for Phases 7 and 8
- **When** Phase 10 is loaded
- **Then** the gate check instructions are included inline in `phase-10-commit.md` (not a reference to Phase 7/8 files)

### AC4: No behavioral change
- **Given** a user runs `/implement <epic>` with the new structure
- **When** implementation proceeds through all phases
- **Then** the behavior is identical to the monolithic version — same phases, same gates, same outputs

## Technical Context

**Architecture Reference**: `.claude/commands/implement.md` — current monolithic command

**Current Phase Map** (line ranges in monolith):
- Step 0: Repo Root (11-43)
- Argument Parsing (45-99)
- Step 1-2: Queue Building + Display (100-142)
- Phase 0.5: Context Verification (171-207)
- Phase 1: Context Loading (211-227)
- Phase 2: Exploration (229-253)
- Phase 3: Planning (255-274)
- Phase 4: Execution (276-307)
- Phase 5: Testing (309-337)
- Phase 6: Validation (339-354)
- Phase 6.5: Structural Validation (356-399)
- Phase 6.75: Runtime Validation (401-485)
- Phase 7: Simplification (489-574)
- Phase 8: Review (578-687)
- Phase 9: Completion (689-736)
- Phase 9.5: Knowledge Update (738-769)
- Phase 10: Commit (771-817)
- Queue Continuation (821-835)
- Phase 11: Push & PR (839-990)
- Error Handling (993-1016)

**New File Structure**:
```
.claude/commands/
├── implement.md                      (~100 lines — index/dispatcher)
└── implement/
    ├── phase-0.5-context-verification.md
    ├── phase-1-context-loading.md
    ├── phase-2-exploration.md
    ├── phase-3-planning.md
    ├── phase-4-execution.md
    ├── phase-5-testing.md
    ├── phase-6-validation.md          (includes 6, 6.5, 6.75)
    ├── phase-7-simplification.md
    ├── phase-8-review.md
    ├── phase-9-completion.md          (includes 9, 9.5)
    ├── phase-10-commit.md
    ├── phase-11-push-pr.md
    └── queue-and-errors.md
```

**Key Design Decisions**:
- Phases 6, 6.5, 6.75 merge into one file (tightly coupled validation pipeline)
- Phases 9, 9.5 merge (completion + optional knowledge update)
- Queue continuation + error handling get their own file
- Phase 11 (Push/PR) is standalone (runs once after all stories)

## Implementation Guidance

### Step 1: Create directory and backup
```
mkdir -p .claude/commands/implement/
cp .claude/commands/implement.md .claude/commands/implement.md.backup
```

### Step 2: Extract phases into files
For each phase group, extract the relevant lines into a standalone file. Each file must:
- Start with a `# Phase N: Name` header
- Include all instructions, examples, and error handling for that phase
- Include any cross-references needed inline (e.g., Phase 10 includes gate check logic)
- End with a "Next Phase" instruction pointing to the next file

### Step 3: Rewrite index
Replace `implement.md` with the thin dispatcher that:
- Performs Step 0 (repo root)
- Parses arguments (6-check resolution)
- Builds story queue
- Displays work plan
- Dispatches to the appropriate phase file via `Read` instruction

### Step 4: Validate
- Read each phase file and confirm it is self-contained
- Walk through a mental execution of all phases to verify no instructions were lost
- Confirm the index correctly routes to each phase

## Testing Requirements

- **Manual Test**: Run `/implement` on an existing epic and verify all phases execute correctly
- **Regression**: Verify mandatory phases 7 and 8 are still enforced in Phase 10 gate check
- **Edge Cases**: Single story mode, multi-story mode, blocked stories, error recovery

## Definition of Done

- [x] `implement.md` is under 120 lines
- [x] All 13 phase files exist in `.claude/commands/implement/`
- [x] No instructions from the original monolith were lost
- [x] Phase 10 gate check for Phases 7/8 is self-contained
- [x] Each phase file starts with clear header and ends with "Next Phase" direction
- [x] Backup of original monolith preserved

## Completion Notes

**Implemented**: 2026-03-20

### Files Changed
- `.claude/commands/implement.md` - Replaced 1,055-line monolith with 100-line index/dispatcher
- `.claude/commands/implement.md.backup` - Backup of original monolith
- `.claude/commands/implement/phase-0.5-context-verification.md` - Context verification phase
- `.claude/commands/implement/phase-1-context-loading.md` - Context loading phase
- `.claude/commands/implement/phase-2-exploration.md` - Exploration phase
- `.claude/commands/implement/phase-3-planning.md` - Planning phase
- `.claude/commands/implement/phase-4-execution.md` - Execution phase
- `.claude/commands/implement/phase-5-testing.md` - Testing phase
- `.claude/commands/implement/phase-6-validation.md` - Validation (6 + 6.5 + 6.75 merged)
- `.claude/commands/implement/phase-7-simplification.md` - Simplification phase
- `.claude/commands/implement/phase-8-review.md` - Review phase
- `.claude/commands/implement/phase-9-completion.md` - Completion (9 + 9.5 merged)
- `.claude/commands/implement/phase-10-commit.md` - Commit with gate check
- `.claude/commands/implement/phase-11-push-pr.md` - Push and PR creation
- `.claude/commands/implement/queue-and-errors.md` - Queue continuation + error handling

### Simplification Results
- Files reviewed: 14
- Issues found: 0
- Issues fixed: 0
- Lines removed: 0
- Status: No issues found

### Self-Review Results
- Findings: 0 total (0 critical/high, 0 medium, 0 nits)
- Fixed: 0
- Skipped: 0

### Notes
- Phases 6, 6.5, 6.75 merged into single phase-6-validation.md (tightly coupled validation pipeline)
- Phases 9, 9.5 merged into single phase-9-completion.md (completion + knowledge update)
- Index reduced from 1,055 lines to 100 lines (~91% reduction in upfront context load)

## Development Notes

**Key Risk**: Claude may not reliably follow "Read only this phase file" instructions. Mitigate by making dispatch instructions explicit with conditional logic keyed to story status.
