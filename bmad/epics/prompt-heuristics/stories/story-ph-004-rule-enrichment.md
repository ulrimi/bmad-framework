---
id: ph-004
epic: prompt-heuristics
specialist: framework
status: Draft
scope: [.claude/commands/implement/phase-4-execution.md, .claude/commands/implement/phase-8-review.md, .claude/commands/implement/queue-and-errors.md, .claude/bmad-template/templates/golden-principles.md]
depends_on: [ph-001]
---

# Story: Rule+Why+Consequence Enrichment

**Status**: Draft
**Priority**: MEDIUM
**Effort**: M (multiple files, surgical additions per rule)

## User Story

As a developer reading BMAD's phase instructions, I want every behavioral rule to include *why* it exists and *what goes wrong* if violated so that I (and the model executing these instructions) comply reliably based on understanding, not just obedience.

## Background

Report 01 Section 3 demonstrates that Anthropic follows a consistent pattern: `[RULE]. [WHY it exists]. [CONSEQUENCE if violated].` Agent audit confirmed that 68% of Tier 1 rules have WHY+CONSEQUENCE, but the remaining 32% — and most Tier 3 guidance — lack context. Note: some target rules already have partial WHY clauses (e.g., Phase 8 "Do NOT fix nits" has "they add churn without meaningful value"; Rule 12 has "that's testing the mock, not the code"). These should be expanded, not replaced. Models comply better when they understand the reasoning behind rules, and the consequence framing makes abstract harms concrete.

**Pattern:** `[RULE]. [WHY]. [CONSEQUENCE IF VIOLATED.]`

Example from Anthropic's prompt:
```
"NEVER commit changes unless the user explicitly asks you to. It is VERY IMPORTANT
to only commit when explicitly asked, otherwise the user will feel that you are
being too proactive"
```

## Acceptance Criteria

- [ ] AC1: Phase 4 "ONE file at a time" rule includes why (merge conflicts, impossible to identify which change broke tests)
- [ ] AC2: Phase 4 "If stuck > 5 min" rule includes why (prevents silent time waste, context window consumption)
- [ ] AC3: ~~REMOVED — Deferred to Story ph-005 which adds the complete circuit breaker with user escalation dialog. Duplicating here would cause merge conflicts.~~
- [ ] AC4: Queue-and-errors "Never guess on business logic" includes consequence (incorrect guesses ship silently, cost more to fix than asking)
- [ ] AC5: Phase 8 "Do NOT fix nits" expanded — currently has partial WHY ("they add churn without meaningful value"), add: "increases diff size, obscures real changes in review"
- [ ] AC6: Golden Principles rules 1, 2, 3, 8, 11, 12, 13, 15 — each has a WHY sentence (rules 4-7, 9-10, 14 already have good rationale)
- [ ] AC7: All additions are parenthetical or single-sentence — no rule grows by more than 2 lines

## Technical Context

**Files and specific rules to enrich:**

### `.claude/commands/implement/phase-4-execution.md`

```
Current: "ONE file at a time (no parallel file edits)"
Add:     "— parallel edits risk merge conflicts in the working tree and make it
          impossible to identify which change broke tests."

Current: "If stuck > 5 min on a file, ask user for guidance"
Add:     "— silent struggle wastes context window tokens and delays the entire
          queue without producing progress."
```

### `.claude/commands/implement/phase-5-testing.md`

**REMOVED** — Circuit breaker addition deferred to Story ph-005, which adds the complete version with user escalation dialog (`[R]etry, [S]kip, [A]sk for help, [Q]uit`). Note: `queue-and-errors.md` line 26 already has `"Attempt auto-fix (up to 3 attempts)"` for test failures, so ph-005 will formalize this in phase-5 itself.

### `.claude/commands/implement/queue-and-errors.md`

```
Current: "Never guess on business logic"
Add:     "— an incorrect guess ships silently and costs 10x more to fix in
          production than asking the user now."
```

### `.claude/bmad-template/templates/golden-principles.md`

Rules needing WHY additions:

```
Rule 1:  "Keep functions under 50 lines."
Add:     "Long functions accumulate hidden state and multiple responsibilities.
          When a test fails, smaller functions isolate the failure to a single concern."

Rule 2:  "One responsibility per file."
Add:     "When two concerns share a file, changes to one risk breaking the other.
          Agents read entire files — mixed concerns waste context on irrelevant code."

Rule 3:  "Validate at boundaries, trust internal data shapes."
Add:     "Internal validation creates redundant checks that rot when schemas change.
          Boundary validation catches errors once, at the point of entry."

Rule 8:  "Commands over 200 lines must use the phase-split pattern."
Add:     "Monolithic commands load all instructions upfront, consuming context
          window for phases that may never execute."

Rule 11: "Tests mirror the module structure they validate."
Add:     "Monolithic test files make it impossible to run just the tests relevant
          to a change. Mirrored structure enables targeted test runs."

Rule 12: "Mock external services, never internal modules."
Add:     "Mocking internal modules tests the mock, not the code. When the internal
          module changes, mocked tests pass while production breaks."

Rule 13: "No print-statement debugging in committed code."
Add:     "Print statements produce unstructured noise in production logs and lack
          the severity levels, timestamps, and context that structured logging provides."

Rule 15: "Configuration lives in config files, not scattered across code."
Add:     "Scattered configuration requires reading every file to understand system
          behavior. A config layer makes the system inspectable at a glance."
```

## Testing Requirements

- Read each modified file to verify additions are present and under 2 lines each
- Verify no existing WHY sentences were duplicated or contradicted

## Definition of Done

- [ ] Phase 4 and Phase 8 rules enriched with WHY + CONSEQUENCE (3 rules total)
- [ ] queue-and-errors "Never guess" rule enriched
- [ ] 8 Golden Principles rules have WHY additions
- [ ] No addition exceeds 2 lines
- [ ] Note: Phase 5 circuit breaker handled by Story ph-005
