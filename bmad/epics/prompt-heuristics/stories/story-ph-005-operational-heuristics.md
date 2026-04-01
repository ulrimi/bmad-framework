---
id: ph-005
epic: prompt-heuristics
specialist: framework
status: Draft
scope: [.claude/commands/bmad.md, .claude/commands/implement/queue-and-errors.md, .claude/commands/implement/phase-5-testing.md, .claude/commands/implement/phase-6-validation.md]
depends_on: []
---

# Story: Operational Heuristics — Continue/Spawn, Circuit Breaker, Resume

**Status**: Draft
**Priority**: MEDIUM
**Effort**: S (3 files, small additions each)

## User Story

As the BMAD orchestration system, I want clear decision heuristics for when to continue an existing agent vs. spawn fresh, a standardized circuit breaker across all retry loops, and a clean resume pattern between stories so that execution is efficient, failures don't cascade, and story transitions don't waste tokens on recaps.

## Background

Three related gaps from the analysis report, consolidated into one story because each is a small addition:

1. **Continue vs. Spawn** (Gap 4): Report 02 Section 4 shows a decision table that prevents wasting context by spawning fresh agents when continuing would be better (error context) and prevents anchoring by continuing when fresh eyes are needed (verification).

2. **Circuit Breaker** (Gap 7): Report 03 Section 8 reveals that Anthropic discovered 250K wasted API calls/day from missing circuit breakers. BMAD has "max 3 cycles" in Phases 6.5 and 6.75 but not in Phase 5 testing. Need to standardize the pattern.

3. **Resume Pattern** (Gap 8): Report 01 Section 9 shows the "resume directly" pattern: "do not acknowledge the summary, do not recap." BMAD's queue continuation says "Next: Story 002 - [title]" but doesn't suppress the model's natural politeness patterns.

## Acceptance Criteria

### Continue vs. Spawn Decision Heuristics

- [ ] AC1: `/bmad` includes a decision reference table for when coordinator should SendMessage vs. spawn fresh
- [ ] AC2: `queue-and-errors.md` includes guidance for error recovery: continue existing error context vs. start fresh

**Decision table to add:**

```markdown
## Continue vs. Spawn Fresh

| Situation | Action | Reason |
|-----------|--------|--------|
| Research explored the exact files to edit | Continue (SendMessage) | Already has files in context |
| Research was broad, implementation narrow | Spawn fresh | Avoid dragging exploration noise |
| Correcting a failure or extending recent work | Continue | Has error context |
| Verifying another agent's work | Always spawn fresh | Fresh eyes, no assumptions |
| Wrong approach entirely | Spawn fresh | Clean slate avoids anchoring |
```

### Circuit Breaker Standardization

- [ ] AC3: Phase 5 testing has an explicit "max 3 fix attempts" limit with escalation to user (note: `queue-and-errors.md` line 26 already has `"up to 3 attempts"` — this formalizes it in phase-5 where implementers encounter it)
- [ ] AC4: The circuit breaker rationale is stated: "Repeated fix attempts beyond 3 cycles consume context without converging. Escalate to user instead."
- [ ] AC5: All retry loops across phases use the same limit (3) — verify consistency with 6.5 and 6.75

### Resume/Continuation Pattern

- [ ] AC6: `queue-and-errors.md` story transition includes explicit suppression of recap behavior
- [ ] AC7: Uses the negative list technique: "Do not summarize what was just completed. Do not recap the previous story. Do not preface with 'Moving on to...' — the commit message captures the completed work."

## Technical Context

### `.claude/commands/bmad.md`

**Add as a new `## Agent Routing Heuristics` section before the `## Execution` section (line 19):**

Note: `bmad.md` is a thin dispatcher — Phase 4 is a one-line summary, not inline content. The decision table goes as a standalone section so it's visible before the SKILL.md dispatch. This guides the coordinator when deciding how to handle specialist agent results.

### `.claude/commands/implement/queue-and-errors.md`

**Modify the Queue Continuation section (lines 7-17):**

```yaml
Current:
  "Display: '✅ Story 001 complete. Next: Story 002 - [title]'"

Updated:
  "Display story completion status line, then continue directly to next story.
   Do not summarize what was just completed — the commit message captures it.
   Do not recap the previous story's changes or findings.
   Do not preface with 'Moving on to...' or 'Now let's work on...'
   Load the next story file and begin Phase 1 immediately."
```

**Add to Error Handling section:**

```markdown
### Circuit Breaker Rule (applies to ALL retry loops)
Max 3 fix attempts for any single failing check (tests, lint, structural, runtime).
If still failing after 3 cycles, escalate to user — repeated attempts consume context
without converging. This limit applies uniformly across Phase 5 (testing), Phase 6.5
(structural), Phase 6.75 (runtime), and Phase 8 (review fixes).
```

**Add Continue vs. Spawn guidance to error recovery:**

```markdown
### Error Recovery: Continue vs. Fresh Agent
- Test failure after implementation → Continue (you have the error context)
- Lint failure after review fix → Continue (small, targeted fix)
- Architecture-level failure → Spawn fresh Plan agent (clean assessment)
- Verification failure → Continue with verifier (it has the failure context)
```

### `.claude/commands/implement/phase-5-testing.md`

**Add to section 5.1 after "FIX THEM before proceeding":**

```
Max 3 fix attempts per failing test. If still failing after 3 cycles:
- Show failure details with exact error output
- Ask: "Tests failing after 3 fix attempts. [R]etry, [S]kip, [A]sk for help, [Q]uit"
- Do not retry silently — escalate to user.
```

## Testing Requirements

- Verify queue-and-errors has resume suppression language
- Verify Phase 5 has explicit 3-retry limit
- Verify `/bmad` has decision table

## Definition of Done

- [ ] Continue vs. Spawn table in `/bmad`
- [ ] Resume suppression pattern in queue-and-errors
- [ ] Circuit breaker (3 retries) explicit in Phase 5
- [ ] Circuit breaker rule documented in queue-and-errors as universal
- [ ] Error recovery Continue/Spawn guidance in queue-and-errors
