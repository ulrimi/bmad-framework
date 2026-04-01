---
id: ph-002
epic: prompt-heuristics
specialist: framework
status: Complete
scope: [.claude/commands/bmad.md, .claude/commands/epic.md, .claude/commands/story.md, .claude/commands/implement/phase-2-exploration.md, .claude/commands/implement/phase-8-review.md, .claude/commands/refine.md, .claude/commands/maintain.md, .claude/commands/explore.md, .claude/commands/plan.md]
depends_on: []
---

# Story: Anti-Lazy-Delegation Rules + Context Isolation Warnings

**Status**: Complete
**Completed**: 2026-04-01
**Priority**: HIGH
**Effort**: S (add standard blocks to existing subagent prompts)

## User Story

As the BMAD coordinator orchestrating subagents, I want explicit anti-lazy-delegation rules and context isolation warnings in every subagent prompt so that spawned agents receive self-contained, specific prompts rather than vague handoffs, producing higher-quality results.

## Background

Report 01 Section 11 reveals that Anthropic's coordinator prompt includes the anti-lazy-delegation rule **repeated 3 times**: "Never write 'based on your findings' or 'based on the research.'" Agent audit found 11 subagent spawns across BMAD commands — 9 are SPECIFIC, 1 is MODERATE (`refine.md`), and 1 is VAGUE (`story.md`). Zero include context isolation warnings. Note: `bmad.md` itself contains no subagent prompts (it delegates to SKILL.md), so the synthesis rule is added as a standalone section rather than annotating an existing prompt.

## Acceptance Criteria

- [ ] AC1: A "Synthesis Rule" block exists in `/bmad` Phase 2 instructions requiring specific file paths, line numbers, and exact changes in all outgoing subagent prompts
- [ ] AC2: The same rule exists in `/epic` Step 2 (where agent outputs are consumed for story creation)
- [ ] AC3: Phase 8.5 (specialist review dispatch) includes explicit instruction to pass concrete diff content, not vague references
- [ ] AC4: All 11 subagent prompt blocks include a context isolation notice: "Workers cannot see your conversation or prior context. This prompt must be self-contained."
- [ ] AC5: The VAGUE prompt in `/story.md` (line 95) is made SPECIFIC with required output fields
- [ ] AC6: The MODERATE prompt in `/refine.md` includes explicit content passing instructions instead of `[content]` placeholders
- [ ] AC7: Good/bad examples are included in at least the `/bmad` and `/epic` synthesis rules

## Technical Context

**Files to modify (synthesis rules — 3 files):**

1. `.claude/commands/bmad.md` — Add synthesis rule as a new `## Synthesis Rule` section before the `## Execution` section (line 19). Note: `bmad.md` is a thin dispatcher to `.claude/skills/bmad/SKILL.md` (not yet created). The synthesis rule goes in `bmad.md` directly so it's visible regardless of whether the SKILL file exists. Include good/bad examples per Report 01 Section 11.
2. `.claude/commands/epic.md` — Add synthesis rule in Step 2 ("With agent outputs, execute..."). Currently no guidance on how to consume agent outputs.
3. `.claude/commands/implement/phase-8-review.md` — Add before 8.5 specialist dispatch. Currently says "Provide the subagent with: The diff of all changes" but doesn't prohibit vague framing.

**Files to modify (context isolation — 8 files, 11 prompts):**

4. `.claude/commands/explore.md` — 1 subagent prompt (line 22)
5. `.claude/commands/maintain.md` — 2 subagent prompts (lines 57, 95)
6. `.claude/commands/plan.md` — 2 subagent prompts (lines 47, 64)
7. `.claude/commands/refine.md` — 1 subagent prompt (line 44) + upgrade MODERATE→SPECIFIC
8. `.claude/commands/story.md` — 1 subagent prompt (line 95) + upgrade VAGUE→SPECIFIC
9. `.claude/commands/implement/phase-2-exploration.md` — 1 subagent prompt (line 5)
10. `.claude/commands/epic.md` — 2 subagent prompts (lines 25, 47) — already being modified for synthesis rule
11. `.claude/commands/implement/phase-8-review.md` — 1 subagent prompt (line 56, specialist dispatch) — already being modified for synthesis rule

**Standard context isolation block to add to every subagent prompt:**

```markdown
> Workers cannot see your conversation, prior agent results, or the broader plan.
> This prompt is your complete context. If critical information is missing, state what you need.
```

**Upgrade spec for `/story.md` VAGUE prompt (line 95):**

```yaml
Current (VAGUE):
  subagent_type: Explore
  thoroughness: quick
  prompt: |
    Quick exploration for story context: $ARGUMENTS

    Find:
    - Files that will be touched
    - Patterns to follow
    - Related existing code

Upgraded (SPECIFIC):
  subagent_type: Explore
  thoroughness: quick
  prompt: |
    Quick exploration for story context: $ARGUMENTS

    Workers cannot see your conversation. This prompt is your complete context.

    Identify and return:
    1. Files that will be modified or created (full paths from repo root)
    2. Patterns used in similar existing code (cite specific file:function examples)
    3. Related test files that exist for the affected modules
    4. Key imports and dependencies of the affected files

    Output format: Structured list with file paths, line counts, and pattern examples.
```

## Testing Requirements

- Read each modified file to verify the synthesis rule and context isolation blocks are present
- Verify `/story.md` subagent prompt now specifies output format
- Verify `/refine.md` subagent prompt now passes content explicitly

## Definition of Done

- [x] Synthesis rule with good/bad examples in `/bmad`, `/epic`, Phase 8
- [x] Context isolation warning in all 11 subagent prompt blocks
- [x] `/story.md` prompt upgraded from VAGUE to SPECIFIC
- [x] `/refine.md` prompt upgraded from MODERATE to SPECIFIC

## Completion Notes

- Added `## Synthesis Rule` section with good/bad examples to `bmad.md` (before `## Execution`)
- Added synthesis rule with examples at Step 2 in `epic.md`
- Added concrete diff passing instruction + context isolation to `phase-8-review.md` section 8.5
- Added context isolation notice to all 11 subagent prompts across 8 files
- Upgraded `story.md` explore prompt: replaced vague "Find:" list with structured output requirements (4 specific items + output format)
- Upgraded `refine.md` gap analysis prompt: replaced `[content]` placeholders with explicit copy-paste instructions via HTML comments
