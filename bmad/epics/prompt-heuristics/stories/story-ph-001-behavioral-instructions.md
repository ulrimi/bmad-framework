---
id: ph-001
epic: prompt-heuristics
specialist: framework
status: ✅ Complete
scope: [.claude/bmad-template/CLAUDE.md.template, .claude/bmad-template/templates/golden-principles.md]
depends_on: []
---

# Story: Add Internal Behavioral Instructions to CLAUDE.md Template

**Status**: ✅ Complete
**Completed**: 2026-04-01
**Priority**: CRITICAL
**Effort**: S (single file edit + minor golden-principles addition)

## User Story

As a developer using BMAD in a new project, I want the scaffolded CLAUDE.md to include behavioral instructions that shape how Claude approaches work (proactive collaboration, comment discipline, epistemic honesty, verification before completion, output efficiency, communication style) so that every command execution benefits from the same behavioral quality that Anthropic's internal developers get.

## Background

Report 07 ("Internal Features Replication Guide") identifies 6 behavioral paragraphs that Anthropic injects into the system prompt for internal users. These are the highest-leverage difference between internal and external Claude Code — not code features, but prompt-level behavioral shaping. BMAD's current CLAUDE.md template has a `## Code Style & Testing` section with a TODO placeholder but no behavioral instructions.

## Acceptance Criteria

- [ ] AC1: `.claude/bmad-template/CLAUDE.md.template` contains a `## Code Quality & QA Standards` section with all 6 behavioral subsections
- [ ] AC2: The section is placed between `## BMAD Workflow (MANDATORY)` and `## Quick Commands` (high in the file for prompt cache efficiency)
- [ ] AC3: Each subsection uses appropriate severity vocabulary (Tier 2 for constraints, Tier 3 for guidance)
- [ ] AC4: Numeric length anchors are included (<=25 words between tool calls, <=100 words final responses)
- [ ] AC5: Comment discipline explicitly references Golden Principles rule #14
- [ ] AC6: The global `~/.claude/CLAUDE.md` does NOT need modification (it's the framework orchestration file, not the per-project template)

## Technical Context

**File to modify:** `.claude/bmad-template/CLAUDE.md.template`

**Insertion point:** After the `---` separator at line 25 (`## BMAD Workflow (MANDATORY)` starts at line 11 and ends at line 23 with the closing `> Work is NOT complete...` line) and before `## Quick Commands` (currently at line 27). Note: the existing `## Code Style & Testing` section remains at line 74 — it is complementary (project-specific settings) while the new behavioral block is universal.

**Content source:** Report 07 lines 40-68, adapted for BMAD context. The block is ready to use with minor framing adjustments.

**Also update:** `.claude/bmad-template/templates/golden-principles.md` — add cross-reference from rule #14 (comments explain WHY not WHAT) to the new Comment Discipline section.

## Implementation Notes

- Do NOT add the behavioral block to the framework's own `.claude/CLAUDE.md` — that file controls BMAD orchestration, not per-project behavior
- The behavioral instructions must survive template variable substitution (no `{{VAR}}` tokens in the behavioral text)
- Keep the existing `## Code Style & Testing` section and its TODO — the behavioral block is complementary, not a replacement

## Testing Requirements

- Verify template renders correctly with `init-bmad` (if testable)
- Verify no `{{VAR}}` tokens appear in the behavioral block
- Verify the section order matches: Workflow → Code Quality & QA → Quick Commands → Tech Stack

## Definition of Done

- [x] CLAUDE.md template has all 6 behavioral subsections
- [x] Golden Principles cross-references comment discipline
- [x] No template variable tokens in behavioral text
- [x] Section ordering is correct for prompt cache efficiency

## Completion Notes

Implemented 2026-04-01. Added `## Code Quality & QA Standards` section with all 6 behavioral subsections to CLAUDE.md.template (lines 27-67). Constraint subsections (Comment Discipline, Epistemic Honesty, Verification) use Tier 2 severity vocabulary (Do NOT, ALWAYS). Guidance subsections (Proactive Collaboration, Output Efficiency, Communication Style) use Tier 3 (lowercase). Golden Principles rule #14 updated with cross-reference to Comment Discipline section.
