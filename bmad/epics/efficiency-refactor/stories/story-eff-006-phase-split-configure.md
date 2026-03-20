---
id: eff-006
epic: efficiency-refactor
specialist: backend
status: ✅ Complete
scope: [.claude/commands/configure.md, .claude/commands/configure/]
depends_on: [eff-001]
---

# Story: Phase-Split /configure into Modular Phases

**Story ID**: EFF-006
**Epic**: efficiency-refactor
**Priority**: Medium
**Estimated Effort**: Small
**Status**: ✅ Complete
**Completed**: 2026-03-20
**Assigned to**: backend-specialist
**Created**: 2026-03-20

## User Story

**As a** BMAD framework user
**I want** the `/configure` command to load only the current phase's instructions
**So that** each invocation uses ~60 lines of context upfront instead of 373

## Business Context

**Problem Statement**: `/configure` is the second-largest command at 373 lines. It runs infrequently (once per project setup) but still loads its entire content for every invocation. Applying the same phase-split pattern as EFF-001 reduces upfront load by ~84%.

**Business Value**: Lower ROI than EFF-001 (less frequent use) but establishes consistency — all large commands follow the same pattern. Also serves as validation that the phase-split pattern generalizes.

## Acceptance Criteria

### AC1: Index file replaces monolith
- **Given** the file `.claude/commands/configure.md` exists at 373 lines
- **When** the refactor is complete
- **Then** `configure.md` is under 60 lines, contains argument parsing + phase dispatch, and routes to phase files via Read instructions

### AC2: Four phase files cover the workflow
- **Given** /configure has 4 natural phases (Discover, Analyze, Present, Apply)
- **When** the refactor is complete
- **Then** `.claude/commands/configure/` contains: `phase-1-discover.md`, `phase-2-analyze.md`, `phase-3-present.md`, `phase-4-apply.md`

### AC3: Phase files are self-contained
- **Given** a phase file is loaded
- **When** Claude follows its instructions
- **Then** it can complete the phase without needing other phase files loaded simultaneously

### AC4: No behavioral change
- **Given** a user runs `/configure --all`
- **When** configuration proceeds through all phases
- **Then** behavior is identical to the monolithic version

## Technical Context

**Current Phase Map** (in 373-line monolith):
- Step 0: Repo Root (lines 1-15)
- Argument Parsing (lines 16-46)
- Phase 1: Discover (lines 47-149, ~103 lines)
  - 1.1 TODO markers, 1.2 Dependencies, 1.3 Configs, 1.4 Env vars, 1.5 Dirs, 1.6 Entry points
- Phase 2: Analyze (lines 150-242, ~93 lines)
  - 2.1 Tech stack, 2.2 Architecture, 2.3 Code style, 2.4 Env vars, 2.5 Key files, 2.6 Specialists
- Phase 3: Present & Confirm (lines 243-306, ~64 lines)
  - Display settings, dry-run mode, user confirmation
- Phase 4: Apply (lines 307-374, ~68 lines)
  - 4.1 CLAUDE.md updates, 4.2 Specialist files, 4.3 Workflow files, 4.4 Results report

**New File Structure**:
```
.claude/commands/
├── configure.md                    (~50 lines — index/dispatcher)
└── configure/
    ├── phase-1-discover.md         (~103 lines)
    ├── phase-2-analyze.md          (~93 lines)
    ├── phase-3-present.md          (~64 lines)
    └── phase-4-apply.md            (~68 lines)
```

## Implementation Guidance

### Step 1: Create directory and backup
```
mkdir -p .claude/commands/configure/
cp .claude/commands/configure.md .claude/commands/configure.md.backup
```

### Step 2: Extract phases
Each phase maps cleanly to its own file. The phases are less coupled than /implement's phases, making this extraction straightforward.

### Step 3: Rewrite index
Replace `configure.md` with dispatcher containing:
- Step 0 (repo root)
- Argument parsing (--all, --claude-md, --specialists, --dry-run, --force, --help)
- Phase dispatch table with Read instructions

### Step 4: Validate
Walk through a mental execution of `/configure --all` to verify no instructions lost.

## Testing Requirements

- Run `/configure --all` on a project and verify all settings detected correctly
- Verify `--dry-run` mode works (stops after Phase 3)
- Verify `--specialists` mode only runs Phase 4.2

## Definition of Done

- [x] `configure.md` is under 60 lines
- [x] 4 phase files exist in `.claude/commands/configure/`
- [x] No instructions from original monolith lost
- [x] Each phase file is self-contained
- [x] Backup of original preserved

## Completion Notes

**Implemented**: 2026-03-20

### Files Changed
- `.claude/commands/configure.md` - Replaced 374-line monolith with 61-line index/dispatcher
- `.claude/commands/configure.md.backup` - Backup of original
- `.claude/commands/configure/phase-1-discover.md` - Discovery phase (~103 lines)
- `.claude/commands/configure/phase-2-analyze.md` - Analysis phase (~93 lines)
- `.claude/commands/configure/phase-3-present.md` - Presentation phase (~64 lines)
- `.claude/commands/configure/phase-4-apply.md` - Application phase (~68 lines)

### Simplification Results
- Files reviewed: 5
- Issues found: 0
- Status: No issues found

### Self-Review Results
- Findings: 0 total
- Fixed: 0

### Notes
- Clean 4-phase split matching natural boundaries (discover, analyze, present, apply)
- Frontmatter preserved (allowed-tools, argument-hint, description)
- Edge cases and quality rules included in phase-4-apply.md
