# Epic: BMAD Framework Efficiency Refactor

## Overview

**Epic ID**: efficiency-refactor
**Created**: 2026-03-20
**Status**: Draft
**Goal**: Reduce context window waste by 50-65% through progressive disclosure — loading only the instructions Claude needs at each moment

## Problem Statement

Every BMAD command loads its entire file into context upfront. `/implement` alone is 1,055 lines — loaded whether you're running Phase 1 or Phase 11. At scale (20 engineers × 5 stories/sprint × 1,055 lines), this creates enormous redundant token spend per sprint cycle.

The fix is architectural: shift from "load everything, execute what's relevant" to "load only what the current phase needs."

## Architecture Decision

Claude Code resolves `/command` to `.claude/commands/command.md` — it does **not** support directory-based command resolution. The phase-split pattern works by:

1. **Index file** (`command.md`) stays as the entry point but shrinks to ~80-100 lines containing argument parsing and phase dispatch
2. **Phase files** live in `.claude/commands/command/` subdirectory
3. Index instructs Claude to use `Read` tool to load phase-specific files on demand
4. Each phase file is self-contained — all instructions needed for that phase without requiring other phase files

## Stories

| Story | Title | Effort | Risk | Dependencies | Status |
|-------|-------|--------|------|-------------|--------|
| EFF-001 | Phase-Split /implement into modular phases | L | Medium | None | ✅ Complete |
| EFF-002 | Story YAML frontmatter for routing | S | Low | EFF-001 | 📋 Ready |
| EFF-003 | Parameterized specialist template | M | Low | None | ✅ Complete |
| EFF-004 | Lazy module loading for specialists | S | Low | EFF-003 | Blocked |
| EFF-005 | Eliminate init-bmad template duplication | L | High | None | 📋 Ready |
| EFF-006 | Phase-Split /configure into modular phases | S | Low | EFF-001 | 📋 Ready |
| EFF-007 | Progressive disclosure documentation | S | None | All above | Blocked |

## Execution Order

```
Sprint 1 (Foundation):
  1. EFF-001 — Phase-Split /implement       [L] [CRITICAL PATH]
  2. EFF-002 — Story YAML Frontmatter       [S] [depends on EFF-001]

Sprint 2 (Parallel — 3 tracks):
  Track A: EFF-003 — Parameterized Template [M]
  Track B: EFF-005 — init-bmad Dedup        [L]
  Track C: EFF-006 — Phase-Split /configure [S]

Sprint 3 (Follow-up):
  EFF-004 — Lazy Module Loading             [S] [depends on EFF-003]

Sprint 4 (Close-out):
  EFF-007 — Progressive Disclosure Docs     [S] [depends on all]
```

## Dependency Graph

```
EFF-001 (Phase-Split /implement)
    │
    ├──→ EFF-002 (Story YAML Frontmatter)
    │
    └──→ EFF-006 (Phase-Split /configure)

EFF-003 (Parameterized Specialist Template)
    │
    └──→ EFF-004 (Lazy Module Loading)

EFF-005 (init-bmad Dedup) — independent track

EFF-007 (Documentation) — depends on ALL above
```

## Context Savings Estimate

| Story | Lines Removed from Upfront Load | Notes |
|-------|-------------------------------|-------|
| EFF-001 | ~955 lines | 1,055 → ~100 index; phases loaded on demand |
| EFF-002 | ~50 lines per story routing | Avoid loading full story body for queue building |
| EFF-003 | ~260 lines | 5 × 65-line stubs → 1 template + config |
| EFF-005 | ~500+ lines | Reference files instead of inline heredocs |
| EFF-006 | ~313 lines | 373 → ~60 index; phases loaded on demand |
| **Total** | **~2,000+ lines** | **~50-65% reduction in framework context overhead** |

## Risk Mitigations

- **EFF-001/006**: Keep original monolithic files as `.backup` during development. Revert is single-file restore.
- **EFF-002**: YAML frontmatter is additive — bold metadata remains as fallback.
- **EFF-003**: Individual stub files remain in git history for instant revert.
- **EFF-005**: Highest risk — provide `--portable` flag for full-copy fallback mode.
- **All**: Each story is independently revertible without affecting others.
