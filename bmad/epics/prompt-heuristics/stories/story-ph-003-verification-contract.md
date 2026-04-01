---
id: ph-003
epic: prompt-heuristics
specialist: framework
status: ✅ Complete
scope: [.claude/commands/implement/phase-8-review.md, .claude/commands/implement/phase-9-completion.md]
depends_on: [ph-002]
---

# Story: Independent Verification Contract in Phase 8

**Status**: ✅ Complete
**Completed**: 2026-04-01
**Priority**: HIGH
**Effort**: S (add one section to one file)

## User Story

As a developer running `/implement`, I want non-trivial implementations to be independently verified by a fresh agent that proves the code works (not just reviews code quality) so that the verification contract catches runtime failures, edge cases, and integration issues that self-review misses.

## Background

Report 01 Section 15 and Report 07 describe Anthropic's internal "Verification Agent Contract" — a formal protocol where a fresh agent (not the implementer) independently proves the code works. The key insight: "Verification means proving the code works, not confirming it exists." BMAD's Phase 8 currently has self-review (8.1-8.3) and specialist code review (8.4-8.6), but no independent functional verification. The specialists review code quality from their domain perspective; nobody independently runs the tests and edge cases from scratch.

## Acceptance Criteria

- [ ] AC1: Phase 8 contains a new section "8.6b Independent Verification" positioned between current 8.6 (merge findings) and 8.7 (re-validate)
- [ ] AC2: The verification step has an explicit trigger condition: "3+ files changed, OR story touches API/data/auth code"
- [ ] AC3: Single-file or documentation-only stories skip verification with a logged message
- [ ] AC4: The verifier is spawned as a FRESH general-purpose agent (not the implementer, not a reviewer)
- [ ] AC5: The verifier prompt includes: skeptical framing ("You did NOT write this code"), evidence requirements ("Every PASS must have a Command block with real output"), and verdict types (PASS/FAIL/PARTIAL)
- [ ] AC6: On FAIL: fix-and-re-verify loop with max 3 cycles
- [ ] AC7: On PASS: spot-check 2 commands from the verifier's report
- [ ] AC8: On PARTIAL: log what passed and what couldn't be verified, continue
- [ ] AC9: The context isolation warning from Story ph-002 is included in the verifier prompt
- [ ] AC10: Results are logged in the story completion notes (Phase 9) under a "### Verification Results" subsection

## Technical Context

**File to modify:** `.claude/commands/implement/phase-8-review.md`

**Insertion point:** After current section 8.6 (merge/address findings), before current section 8.7 (re-validate). The new section 8.6b runs between code review and final validation.

**Why 8.6b (between 8.6 and 8.7), not 8.9:** The verification should run before the final re-validation (8.7) so that any fixes from verification failures get caught by the final test/lint pass.

**Also update:** `.claude/commands/implement/phase-9-completion.md` — Add "### Verification Results" to the completion notes template, after the Multi-Agent Review Results section.

**Verifier prompt structure (from Report 07):**

```yaml
Agent:
  subagent_type: general-purpose
  description: "Independent verification"
  prompt: |
    You are an independent verifier. You did NOT write this code. Approach it skeptically.

    Workers cannot see your conversation. This prompt is your complete context.

    Changes to verify:
    [list each file changed with one-line description of the change]

    Story acceptance criteria:
    [paste acceptance criteria from story file]

    Rules:
    - Run tests WITH the feature enabled — not just "tests pass"
    - Run typechecks and INVESTIGATE errors — don't dismiss as "unrelated"
    - Try at least one edge case or error path
    - If something looks off, dig in before assigning PASS

    For each verification item:
    - **Check**: What you verified
    - **Command**: Exact command you ran
    - **Output**: Actual output (not summarized)
    - **Verdict**: PASS / FAIL / PARTIAL

    Final Verdict — assign exactly one:
    - **PASS**: All checks passed with evidence
    - **FAIL**: One or more checks failed (list which)
    - **PARTIAL**: Some passed, some could not be verified (list both)

    Every PASS must have a Command block with real output.
    A PASS without evidence is a FAIL.
```

## Testing Requirements

- Verify the trigger condition correctly identifies 3+ file changes
- Verify the skip condition logs appropriately for small changes
- Verify the verifier prompt includes context isolation warning

## Definition of Done

- [x] Phase 8 contains section 8.6b with full verification contract
- [x] Trigger condition: 3+ files OR API/data/auth scope
- [x] Skip condition logged for small changes
- [x] Verifier uses PASS/FAIL/PARTIAL verdicts with evidence requirements
- [x] Fix-and-re-verify loop with max 3 cycles
- [x] Spot-check on PASS
- [x] Phase 9 completion notes template includes verification results

## Completion Notes

**Implemented**: 2026-04-01

### Files Changed
- `.claude/commands/implement/phase-8-review.md` - Added section 8.6b Independent Verification between 8.6 and 8.7
- `.claude/commands/implement/phase-9-completion.md` - Added "### Verification Results" subsection to completion notes template

### Simplification Results
- Files reviewed: 2
- Issues found: 0
- Status: No issues found

### Self-Review Results
- Findings: 0 total (0 critical/high, 0 medium, 0 nits)
- Fixed: 0
- Skipped: 0 nits

### Verification Results
- Verdict: Skipped
- Notes: 2 files changed, no API/data/auth scope — below trigger threshold

### Notes
- Positioned 8.6b before 8.7 so verification fixes get caught by final re-validation pass
- Context isolation warning from ph-002 included verbatim in verifier prompt template
