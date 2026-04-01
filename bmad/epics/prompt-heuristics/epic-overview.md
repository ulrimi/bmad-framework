# Epic: Prompt Heuristics — Claude Code Internal Patterns for BMAD

## Goal

Apply validated patterns from Anthropic's Claude Code internal behavioral instructions to BMAD's command files and templates. Close 7 identified gaps to achieve measurably more accurate, consistent, and context-efficient execution across all BMAD commands.

## Background

Analysis of 7 extraction reports from Claude Code's codebase (documented in `docs/claude-code-insights-analysis.md`) identified that Anthropic's internal developer builds include behavioral prompt instructions that dramatically improve output quality. Most are fully replicable via CLAUDE.md and skill file edits. BMAD already implements several patterns well (phase-split, specialist routing, quality gates, evidence-based review) but has specific gaps in behavioral shaping, delegation discipline, and verification rigor.

## Scope

**In scope:**
- CLAUDE.md template behavioral instructions (6 paragraphs)
- Anti-lazy-delegation rules + context isolation warnings in all subagent prompts
- Independent verification contract in Phase 8
- Rule+Why+Consequence enrichment across phase files and golden-principles
- Continue vs. Spawn decision heuristics
- Circuit breaker standardization
- Resume/continuation pattern improvement
- Consequence framing for push/PR operations
- Large result handling guidance

**Out of scope:**
- Runtime features (fork model, mailbox protocol, header latching)
- Hook automation (low priority, separate initiative)
- New commands or phases (only modifying existing ones)
- Changing BMAD's architecture or phase ordering

## Stories

| # | Story | Priority | Effort | Specialist | Status |
|---|-------|----------|--------|------------|--------|
| 1 | Behavioral Instructions for CLAUDE.md Template | CRITICAL | S | Framework | Draft |
| 2 | Anti-Lazy-Delegation + Context Isolation | HIGH | S | Framework | Draft |
| 3 | Independent Verification Contract | HIGH | S | Framework | Draft |
| 4 | Rule+Why+Consequence Enrichment | MEDIUM | M | Framework | Draft |
| 5 | Operational Heuristics (Spawn/Circuit/Resume) | MEDIUM | S | Framework | Draft |
| 6 | Safety Framing + Large Result Handling | LOW | S | Framework | Draft |

## Dependency Graph

```
Story 1 (CLAUDE.md template) — no dependencies, foundational
Story 2 (anti-delegation) — no dependencies
Story 3 (verification) — depends on Story 2 (uses context isolation warning)
Story 4 (rule enrichment) — depends on Story 1 (template sets tone); phase-5 circuit breaker deferred to Story 5
Story 5 (operational heuristics) — no dependencies
Story 6 (safety framing) — no dependencies
```

Stories 1, 2, 5, and 6 are independent. Story 3 depends on Story 2 (AC9 includes the context isolation warning from ph-002). Story 4 depends on Story 1 (template sets behavioral tone). Stories 4 and 5 both touch `queue-and-errors.md` but in different sections (no conflict).

## Risk Mitigations

| Risk | Mitigation |
|------|-----------|
| Over-verbose rules slow down context loading | Keep additions under 10 lines per file. Phase-split pattern already manages context. |
| Behavioral instructions conflict with existing style | Verified that CLAUDE.md template has a gap (TODO placeholder) exactly where the block goes. |
| Anti-delegation rules too prescriptive for creative tasks | Rules apply to synthesis step only, not the initial research prompts. |
| Independent verifier adds latency to implementation | Trigger only fires on 3+ file changes. Single-file stories skip it. |

## Success Criteria

1. All 6 behavioral instructions present in CLAUDE.md template
2. All 11 subagent prompts include context isolation warnings
3. Phase 8 includes independent verification (section 8.6b) with PASS/FAIL/PARTIAL verdicts
4. 100% of Tier 1 rules across all phase files have WHY + CONSEQUENCE
5. Continue vs. Spawn decision table available in `/bmad` and queue-and-errors
6. Circuit breaker limit (3 retries) standardized across all phases with retry loops

## Decision Log

| Date | Decision | Rationale |
|------|----------|-----------|
| 2026-03-31 | Use verbatim Report 07 behavioral block as starting point | Extracted from Anthropic's production system prompt; proven effective at scale |
| 2026-03-31 | Trigger verification on 3+ files, not every story | Balances rigor with speed; single-file changes have minimal risk |
| 2026-03-31 | Don't add hooks (Gap 7) in this epic | Lower priority; Phase 10 gate check already catches missing phases; hooks would be a separate initiative |
| 2026-03-31 | Severity vocabulary doesn't need major overhaul | Agent audit confirmed no inflation; focus on adding WHY/CONSEQUENCE to the 32% that lack it |
| 2026-04-01 | Refinement: bmad.md is a thin dispatcher — add content as standalone sections | `.claude/skills/bmad/SKILL.md` doesn't exist; Stories 2+5 now add synthesis rule and decision table before the `## Execution` dispatch in `bmad.md` itself |
| 2026-04-01 | Refinement: Deduplicate phase-5 circuit breaker — remove from Story 4, keep in Story 5 | Story 5 has the complete version with user escalation dialog; Story 4's version was a subset that would cause merge conflicts |
| 2026-04-01 | Refinement: Story 3 depends on Story 2 | AC9 references the context isolation warning from ph-002; was missing from depends_on |
| 2026-04-01 | Refinement: Rename verification section 8.5b → 8.6b | Section is inserted between 8.6 and 8.7, so 8.6b is the correct label |
| 2026-04-01 | Refinement: Subagent count is 11 not 10 | Recount found phase-8-review.md specialist dispatch was not included in original audit |
| 2026-04-01 | Refinement: Story 4 scope corrected | Removed phase-3-planning.md (no changes specified), removed phase-5-testing.md (deferred to ph-005), added phase-8-review.md (AC5 targets it) |
