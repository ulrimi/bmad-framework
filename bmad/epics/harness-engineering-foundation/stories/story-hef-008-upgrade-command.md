# Story: init-bmad --upgrade Command

Story: Add --upgrade mode to init-bmad that detects existing BMAD setups and non-destructively adds missing harness engineering artifacts
Story ID: hef-008
Epic: harness-engineering-foundation
Priority: High
Estimated Effort: L
Status: Draft
Assigned to: backend-specialist
Created: 2026-03-13

## User Story
As an engineer with an existing BMAD project (with CLAUDE.md, agents, and tailored templates)
I want to run `init-bmad --upgrade` to detect what's missing and add new harness engineering artifacts
So that I can adopt the latest framework improvements without disrupting my working setup or re-running full bootstrap

## Business Context

### Problem Statement
`init-bmad` is designed for greenfield projects — it scaffolds everything from scratch. Existing BMAD projects (like backtester_v2 with 32 epics and 5 specialists, or quantumNotary with 7 specialists and production deployment) can't re-run it without clobbering their tailored configurations. These projects get new commands automatically via symlinks, but project-level artifacts (ARCHITECTURE.md, golden-principles.md, CLAUDE.md knowledge map, structural_validation config, living-doc sections) must be added manually. There's no guided path for upgrading.

### Business Value
A guided upgrade path eliminates the friction of adopting framework improvements. Without it, mature projects stay on the old pattern indefinitely because the migration effort feels uncertain. With it, a 5-minute interactive session brings any project up to current standards. This is critical for adoption — the framework is only as good as the projects that use it.

## Acceptance Criteria

**AC1:** Detects existing BMAD setup
- Given I run `init-bmad --upgrade` in a project with `bmad/qf-bmad/core-config.yaml`
- When the detection phase runs
- Then it identifies and reports: which BMAD artifacts exist (CLAUDE.md, core-config.yaml, agents, workflows, templates, checklists) and their locations

**AC2:** Identifies missing artifacts
- Given detection is complete
- When the gap analysis runs
- Then it reports which harness engineering artifacts are missing:
  - ARCHITECTURE.md (at repo root)
  - golden-principles.md (in bmad/qf-bmad/)
  - Knowledge Map section in CLAUDE.md
  - docs/ directory structure (design-docs, exec-plans, product-specs, references, generated)
  - core-beliefs.md (in docs/design-docs/ if docs/ exists)
  - QUALITY_SCORE.md (in docs/ if docs/ exists)
  - structural_validation section in core-config.yaml
  - tech-debt-tracker.md (in docs/exec-plans/ if docs/ exists)
  - Living-document sections in epic template

**AC3:** Non-destructive — never overwrites
- Given I run `init-bmad --upgrade` in a project with existing CLAUDE.md and core-config.yaml
- When upgrades are applied
- Then NO existing files are overwritten or modified without explicit confirmation, and all modifications are appended/inserted rather than replaced

**AC4:** Interactive selection
- Given missing artifacts are identified
- When the upgrade menu is presented
- Then I can choose: apply all, select individually, or dry-run (show what would be created)

**AC5:** CLAUDE.md Knowledge Map insertion
- Given CLAUDE.md exists and lacks a Knowledge Map section
- When I choose to add it
- Then a Knowledge Map table is inserted near the top of CLAUDE.md (after the first heading) pointing to all discovered and newly created artifacts, without modifying any other content

**AC6:** core-config.yaml augmentation
- Given core-config.yaml exists and lacks structural_validation
- When I choose to add it
- Then a `structural_validation` section is appended (disabled by default) without modifying existing config

**AC7:** Handles missing docs/ gracefully
- Given a project has no docs/ directory
- When I choose to add docs-layer artifacts (core-beliefs, QUALITY_SCORE, tech-debt-tracker)
- Then the script offers to create the docs/ structure first, or skips those artifacts if declined

**AC8:** Reports what was done
- Given upgrades are applied
- When the script completes
- Then it prints a summary of: files created, files modified, and recommended next steps (e.g., "Edit ARCHITECTURE.md to describe your system" or "Customize golden-principles.md for your project's taste")

**AC9:** Dry-run mode
- Given I run `init-bmad --upgrade --dry-run`
- When the script completes
- Then it shows exactly what would be created/modified without making any changes

**AC10:** Refuses to run on non-BMAD projects
- Given I run `init-bmad --upgrade` in a directory without `bmad/qf-bmad/core-config.yaml`
- When the pre-flight check runs
- Then it exits with: "No existing BMAD setup detected. Use `init-bmad` (without --upgrade) to bootstrap a new project."

## Technical Context

### Architecture Reference
This story extends the init-bmad script at `.claude/scripts/init-bmad`.

### Existing Patterns to Follow
- init-bmad already has extensive flag parsing (--name, --stack, --specialists, --full, --gitignore, --non-interactive)
- init-bmad uses colored output with helper functions (print_header, print_success, print_warning)
- Template files live in `.claude/bmad-template/` and are copied with placeholder substitution
- Placeholder sweep converts unfilled `{{PLACEHOLDER}}` to `<!-- TODO: ... -->` markers
- The script uses `sed -i.bak` for macOS-compatible in-place editing

### Key Projects for Testing
- `/Users/michaelulrich/Documents/pythonProjects/backtester_v2` — 482-line CLAUDE.md, 5 specialists, no ARCHITECTURE.md, organic docs/
- `/Users/michaelulrich/qfProjects/quantumNotary` — 767-line CLAUDE.md, 7+4 specialists, has docs/Architecture.md (not at root), extensive docs/

### Dependencies
- Story hef-001 (architecture template) — template must exist to offer it
- Story hef-002 (golden principles) — template must exist to offer it
- Story hef-004 (living docs) — epic template must have sections to compare against
- Story hef-005 (docs scaffold) — docs/ structure templates must exist
- Story hef-007 (core-beliefs) — template must exist to offer it

This story should be implemented LAST in Epic 1 since it uses all the templates created by other stories.

## Implementation Guidance

### Files to Modify
- `.claude/scripts/init-bmad` — Add `--upgrade` and `--dry-run` flag handling, detection logic, and upgrade functions

### Key Design Decisions

**Detection logic** — check for existence of:
```bash
# Core BMAD (must exist for --upgrade)
bmad/qf-bmad/core-config.yaml

# Harness engineering artifacts (check each)
ARCHITECTURE.md
bmad/qf-bmad/golden-principles.md
docs/                              # directory exists?
docs/design-docs/core-beliefs.md
docs/QUALITY_SCORE.md
docs/exec-plans/tech-debt-tracker.md
```

**CLAUDE.md Knowledge Map detection** — grep for `## Knowledge Map` in CLAUDE.md. If not found, offer to insert.

**Knowledge Map insertion** — insert after the first `#` heading line:
```bash
# Find line number of first heading, insert Knowledge Map after it
```

**core-config.yaml augmentation** — append new sections only if the key doesn't already exist:
```bash
grep -q "structural_validation:" bmad/qf-bmad/core-config.yaml || cat >> ...
```

**Interactive menu**:
```
init-bmad --upgrade

╔══════════════════════════════════════════╗
║       BMAD Upgrade — Gap Analysis        ║
╚══════════════════════════════════════════╝

Existing setup detected:
  ✓ CLAUDE.md (482 lines)
  ✓ core-config.yaml
  ✓ 5 specialist agents
  ✓ Workflows, tasks, templates, checklists

Missing harness engineering artifacts:
  [1] ARCHITECTURE.md — System map with codemap, invariants, boundaries
  [2] golden-principles.md — Code taste rules for this project
  [3] Knowledge Map in CLAUDE.md — Pointers to deeper docs
  [4] docs/ knowledge structure — Design docs, exec-plans, references
  [5] structural_validation in core-config.yaml — Mechanical enforcement hooks

Options:
  a) Apply all    s) Select individually    d) Dry-run    q) Quit
```

**Template substitution** — reuse existing project info from core-config.yaml:
```bash
PROJECT_NAME=$(grep "name:" bmad/qf-bmad/core-config.yaml | head -1 | ...)
PROJECT_LANG=$(grep "language:" bmad/qf-bmad/core-config.yaml | ...)
```

### Non-destructive guarantees
- NEVER use `>` to write existing files — always `>>` (append) or insert-at-line
- ALWAYS check existence before creating: `[ -f "$file" ] && skip || create`
- For CLAUDE.md modification: create backup first (`cp CLAUDE.md CLAUDE.md.bak`)
- For core-config.yaml modification: create backup first

## Testing Requirements

### Manual Testing
- Run `init-bmad --upgrade --dry-run` in backtester_v2 — verify detection and gap report
- Run `init-bmad --upgrade --dry-run` in quantumNotary — verify it detects existing docs/Architecture.md
- Run `init-bmad --upgrade` in a test copy of backtester_v2 — verify files created, nothing overwritten
- Run `init-bmad --upgrade` in a non-BMAD directory — verify refusal message
- Run `init-bmad --upgrade` twice — verify idempotent (second run reports nothing missing)

## Definition of Done
- [ ] `--upgrade` flag added to init-bmad
- [ ] `--dry-run` flag added to init-bmad
- [ ] Detection identifies all harness engineering artifacts
- [ ] Interactive menu with apply-all/select/dry-run/quit options
- [ ] Non-destructive: no existing files overwritten
- [ ] CLAUDE.md Knowledge Map inserted without modifying existing content
- [ ] core-config.yaml augmented without modifying existing config
- [ ] Summary printed with next steps
- [ ] Idempotent: running twice produces no changes on second run
- [ ] Refuses non-BMAD directories with helpful message
- [ ] Story status updated
