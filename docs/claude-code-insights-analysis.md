# Claude Code Internals: Insights Analysis for BMAD Framework

> Cross-referencing 7 extraction reports from Anthropic's Claude Code codebase against the BMAD
> orchestration framework. Validated findings, actionable recommendations, and implementation priorities.
>
> **Date**: 2026-03-31
> **Source Reports**: `~/Desktop/claudeCLI/reports/01-07`
> **BMAD Version Analyzed**: Current main branch (commit ca67836)

---

## Executive Summary

The Claude Code extraction reports reveal that Anthropic's internal development builds include **behavioral prompt instructions** that dramatically improve output quality — and most of these are fully replicable via CLAUDE.md and skill files. BMAD already implements several of these patterns (phase-split commands, specialist agents, quality gates, multi-agent review), but there are 6 high-impact gaps where adopting Claude Code's internal patterns would measurably improve BMAD's accuracy, efficiency, and consistency.

**Top 3 findings:**

1. BMAD's CLAUDE.md template lacks the 6 behavioral instructions that Anthropic gives its internal developers — adding these would be the single highest-leverage improvement.
2. BMAD's `/bmad` coordinator prompt doesn't enforce anti-lazy-delegation, which means subagent prompts sometimes produce vague results.
3. BMAD's Phase 8 (review) implements self-verification but not the formal independent verification contract with PASS/FAIL/PARTIAL verdicts that Anthropic uses internally.

---

## Part 1: Validated Strengths — Where BMAD Already Aligns

These patterns from the reports are already well-implemented in BMAD. No action needed.

### 1.1 Phase-Split Command Pattern (Report 05, Pattern 8)

**What the report says:** "Commands over 200 lines must use the phase-split pattern. Index file for argument parsing + dispatch; phase files for self-contained instructions."

**BMAD's implementation:** `/implement` uses exactly this pattern — `implement.md` handles argument resolution and queue building, then dispatches to 12 phase files (`phase-0.5` through `phase-11`) loaded on demand. Golden Principles rule #7 explicitly codifies this: "Load context incrementally. A phase transition is the permission to load the next phase file."

**Validation:** BMAD independently discovered the same pattern Anthropic uses internally. The key insight from both systems is that lazy-loading phase files prevents context bloat in long-running operations.

**Status:** Fully aligned. No changes needed.

### 1.2 Specialist Agent Routing (Report 02, Section 4)

**What the report says:** Coordinator should "direct workers to research, implement and verify" and route work to specialists by domain.

**BMAD's implementation:** `/implement` Phase 1 matches story domains to specialist agent files in `bmad/config/agents/active/`. `/epic` deploys parallel Explore + Plan agents. `/bmad` runs 3-4 parallel agents for intelligence gathering.

**Status:** Well-aligned. The agent routing is solid.

### 1.3 Quality Gate Enforcement (Report 01, Section 15)

**What the report says:** Internal builds enforce verification before reporting completion. "Must verify work actually runs before reporting done."

**BMAD's implementation:** Phase 5 (testing), Phase 6 (validation + structural + runtime), Phase 7 (simplification), Phase 8 (review) form a 4-layer quality gate. Phase 10 has a mandatory gate check that blocks commit if Phase 7 or 8 evidence is missing.

**Status:** Strong implementation. BMAD's quality gate chain is more rigorous than Claude Code's single verification step.

### 1.4 Negative List Technique in Review (Report 01, Section 4)

**What the report says:** "Instead of saying 'write minimal code,' list specific anti-patterns."

**BMAD's implementation:** `/review` includes an "Anti-Hallucination Checklist" with 4 explicit checks. Phase 7 (simplification) lists 8 specific over-engineering patterns to check against. Golden Principles lists 15 concrete rules.

**Status:** Well-aligned. BMAD uses explicit negative lists where it matters most.

### 1.5 Evidence-Based Review (Report 01, Section 14)

**What the report says:** "Report outcomes faithfully. Never claim 'all tests pass' when output shows failures."

**BMAD's implementation:** `/review` has "GROUNDING RULES (CRITICAL - NON-NEGOTIABLE)" requiring file:line references and confidence prefixes (Definite/Likely/Possible). Empty sections must say "None identified" rather than inventing issues.

**Status:** BMAD's review grounding rules are a strong implementation of epistemic honesty for code review specifically. But this principle should be broader — see Recommendation 1.

### 1.6 Tiered Review Depth (Report 04, Section 6)

**What the report says:** Different execution contexts should get different tool sets and depth levels.

**BMAD's implementation:** `/review` auto-detects tier (quick/standard/deep) based on file count, line count, and risk paths (auth, billing, migrations). Each tier has different context gathering and output formats.

**Status:** Excellent alignment. BMAD's auto-detection logic is well-designed.

---

## Part 2: High-Impact Gaps — What BMAD Should Adopt

These patterns from the reports are missing or underimplemented in BMAD. Each recommendation includes the specific BMAD file to modify.

### Gap 1: CLAUDE.md Template Missing Internal Behavioral Instructions

**Priority: CRITICAL** | **Report source:** Report 07 (full section), Report 01 Sections 6, 14 | **Effort: Small**

**The gap:** Anthropic's internal builds inject 6 behavioral paragraphs into the system prompt that external users don't get. Report 07 calls this "the biggest quality gap between internal and external Claude Code." BMAD's CLAUDE.md template (`.claude/bmad-template/CLAUDE.md.template`) contains workflow instructions and command references, but none of the behavioral shaping that controls *how* the model approaches work.

**The 6 missing behaviors:**

| Behavior | What It Does | BMAD Impact |
|----------|-------------|-------------|
| Proactive Collaboration | Model flags bugs and misconceptions, not just executes | Catches issues during `/implement` Phase 4 |
| Comment Discipline | Default to no comments, only WHY | Cleaner code output from all implementation |
| Epistemic Honesty | Prevents false positives AND false negatives | More accurate Phase 5/6 reporting |
| Verification Before Completion | Must run the test, not just claim success | Strengthens Phase 5-8 quality gates |
| Numeric Length Anchors | <=25 words between tool calls, <=100 words final | Reduces context waste across all commands |
| Communication Style | Prose, not fragments; lead with action | Better user experience in all phases |

**Recommendation:** Add a "Code Quality & QA Standards" section to `.claude/bmad-template/CLAUDE.md.template`. The verbatim block from Report 07 is ready to use. This is the single highest-leverage change — it improves every command without modifying any command files.

**Validation:** I verified that BMAD's current CLAUDE.md template has a `## Code Style & Testing` section with `<!-- TODO: Run /configure -->` placeholders, but no behavioral instructions. The template focuses on *what tools to use* and *what workflow to follow*, not *how to behave while using them*. The Report 07 block fills this gap directly.

---

### Gap 2: Anti-Lazy-Delegation in Coordinator Prompts

**Priority: HIGH** | **Report source:** Report 01 Section 11, Report 02 Section 4 | **Effort: Small**

**The gap:** Report 01 reveals that Anthropic's coordinator prompt includes anti-lazy-delegation language **repeated 3 times in different contexts**: "Never write 'based on your findings' or 'based on the research.' These phrases delegate understanding to the worker instead of doing it yourself."

BMAD's `/bmad` command (`.claude/commands/bmad.md`) dispatches to a skill file and describes 5 phases, but the prompts for spawned agents don't enforce synthesized handoffs. The `/epic` command spawns parallel agents with reasonably specific prompts, but there's no explicit prohibition against vague delegation.

**Evidence from the reports:**

```
// Bad - lazy delegation (what can happen now):
Agent({ prompt: "Based on your findings, fix the auth bug" })

// Good - synthesized spec (what the anti-delegation rule enforces):
Agent({ prompt: "Fix the null pointer in src/auth/validate.ts:42. The user field
on Session (src/auth/types.ts:15) is undefined when sessions expire. Add a null
check before user.id access — if null, return 401 with 'Session expired'." })
```

**Recommendation:** Add anti-lazy-delegation rules to:
1. `.claude/commands/bmad.md` — in the Phase 2 synthesis instructions
2. `.claude/commands/epic.md` — in Step 2 where agent outputs are consumed
3. `.claude/commands/implement/phase-2-exploration.md` — in the subagent prompt template
4. `.claude/commands/implement/phase-8-review.md` — in the specialist review subagent prompts

Specific text to add: "When sending work to a subagent, include specific file paths, line numbers, and exact changes. Never write 'based on your findings' or 'implement as needed' — these phrases delegate understanding. You must demonstrate that you understood the research by including concrete details in every subagent prompt."

**Validation:** I read all subagent prompt templates in the BMAD commands. `/epic` Step 2 says "With agent outputs, execute: create-epic.md" without specifying that the coordinator must synthesize findings into specific details. `/implement` Phase 2 has a reasonable prompt template but doesn't prohibit vague delegation in the synthesis step. Phase 8.5 says "Provide the subagent with: The diff of all changes" which is better, but could still benefit from the anti-delegation rule.

---

### Gap 3: Formal Independent Verification Contract

**Priority: HIGH** | **Report source:** Report 01 Section 15, Report 07 Section "Verification Agent" | **Effort: Medium**

**The gap:** Anthropic's internal builds include a formal "Verification Agent Contract" with specific trigger conditions, roles, verdict types, and escalation paths:

- **Trigger:** 3+ file edits, backend/API changes, or infrastructure changes
- **Rule:** Implementer's own checks do NOT substitute for independent verification
- **Verdicts:** PASS (with evidence), FAIL (fix and re-verify), PARTIAL (report gaps)
- **Gate:** "You cannot self-assign PARTIAL" — only the verifier assigns verdicts
- **Spot-check:** On PASS, re-run 2-3 commands from the verifier's report

BMAD's Phase 8 has self-review (8.1-8.3) and multi-agent review (8.4-8.6), which is structurally similar. But it conflates the implementer's self-review with independent verification. The implementer runs `/review` on their own changes, then spawns specialists — but the specialists are reviewing code quality, not *proving the code works*. There's no requirement that a fresh agent runs the tests independently and reports verdicts.

**Recommendation:** Add a Phase 8.5b "Independent Verification" step between the current 8.6 and 8.7, or restructure Phase 8 to separate code review (quality) from verification (functionality):

```
8.5b Independent Verification (for non-trivial implementations):
    Trigger: 3+ files changed, or story touches API/data/auth
    
    Spawn a FRESH agent (not the implementer, not a reviewer):
    Agent:
      subagent_type: general-purpose
      prompt: |
        You are an independent verifier. You did NOT write this code.
        Prove it works — don't just confirm it exists.
        
        Run tests WITH the feature. Try edge cases.
        Investigate type errors — don't dismiss as "unrelated."
        
        For each check:
        - Check: What you verified
        - Command: Exact command run
        - Output: Actual output (not summarized)
        - Verdict: PASS / FAIL / PARTIAL
        
        Every PASS must have a Command block with output.
        A PASS without evidence is a FAIL.
```

**Validation:** I verified that Phase 8 currently spawns specialist review agents but not a verification agent. The specialists check code quality from their domain perspective. Nobody independently runs the tests and edge cases from scratch.

---

### Gap 4: Three-Tier Severity Vocabulary

**Priority: MEDIUM** | **Report source:** Report 01 Section 2 | **Effort: Medium**

**The gap:** Anthropic uses a deliberate three-tier severity vocabulary in their prompts:

| Tier | Style | Usage |
|------|-------|-------|
| Tier 1 | ALL CAPS: CRITICAL, NEVER | Absolute prohibitions that must not be violated |
| Tier 2 | Mixed case: Do NOT, ALWAYS, BLOCKING | Strong constraints with some nuance |
| Tier 3 | Lowercase: don't, prefer, avoid | Guidance with room for judgment |

BMAD uses severity language inconsistently across its command files:

- `implement.md` uses "MANDATORY" and "CRITICAL" appropriately
- `phase-7-simplification.md` uses "> **CRITICAL**: This phase runs on EVERY implementation. It is NOT optional." (good)
- `review.md` uses "### GROUNDING RULES (CRITICAL - NON-NEGOTIABLE)" (good)
- But `phase-4-execution.md` uses "CRITICAL" for todo tracking, which is a lower-severity concern
- `explore.md` doesn't use severity language at all for its mandatory steps
- `phase-2-exploration.md` and `phase-3-planning.md` have no severity markers

**Recommendation:** Audit all command files and standardize:
- **Tier 1 (CRITICAL/NEVER):** Gate checks, safety constraints, "will cause data loss" scenarios. Currently used correctly in Phase 10 gate check, Phase 7/8 mandatory markers, review grounding rules.
- **Tier 2 (Do NOT/ALWAYS):** Strong process constraints. Apply to: anti-lazy-delegation rules, specialist loading requirements, queue ordering.
- **Tier 3 (Don't/Prefer):** Guidance. Apply to: style suggestions, optional optimizations, "nice to have" patterns.

Add a comment at the top of each command file documenting which tier its key constraints belong to. This prevents severity inflation over time.

---

### Gap 5: Rule + Why + Consequence Pattern

**Priority: MEDIUM** | **Report source:** Report 01 Section 3 | **Effort: Medium**

**The gap:** Anthropic's prompts follow a consistent pattern: `[RULE]. [WHY it exists]. [CONSEQUENCE if violated].` This triple structure produces the most reliable model compliance.

BMAD's commands often state rules without explaining why:

| BMAD Rule (current) | Missing Why/Consequence |
|---------------------|------------------------|
| "ONE file at a time (no parallel file edits)" (Phase 4) | Why? What goes wrong with parallel edits? |
| "Never guess on business logic" (queue-and-errors) | What happens if the model guesses? |
| "Do NOT fix nits" (Phase 8) | Why not? What's the cost? |
| "If stuck > 5 min on a file, ask user" (Phase 4) | Why 5 minutes? What failure mode does this prevent? |

Golden Principles does this well for some rules (e.g., "Favor boring technologies. Composable, API-stable, well-represented in training data. Agents model these correctly; exotic choices cause subtle bugs.") but others lack the explanation (e.g., "Keep functions under 50 lines." — no why or consequence).

**Recommendation:** For each rule in command files, add a parenthetical or follow-on sentence explaining the consequence:

```
Before:
  "ONE file at a time (no parallel file edits)"

After:
  "ONE file at a time — parallel edits create merge conflicts in the working tree 
  and make it impossible to identify which change broke tests."
```

**Validation:** I read all 12 phase files plus the 6 main commands. Golden Principles rules 4-6 have good rationale. Rules 1-3, 7-8, and 11-15 state the rule but not the consequence. The phase files are the worst — most rules are bare imperatives without context.

---

### Gap 6: Continue vs. Spawn Fresh Decision Heuristics

**Priority: MEDIUM** | **Report source:** Report 02 Section 4 | **Effort: Small**

**The gap:** Claude Code's coordinator includes an explicit decision table for when to continue an existing agent vs. spawn a fresh one:

| Situation | Action | Reason |
|-----------|--------|--------|
| Research explored the exact files to edit | Continue (SendMessage) | Already has files in context |
| Research was broad, implementation narrow | Spawn fresh | Avoid dragging exploration noise |
| Correcting a failure | Continue | Has error context |
| Verifying another's work | Always spawn fresh | Fresh eyes, no assumptions |
| Wrong approach entirely | Spawn fresh | Clean slate avoids anchoring |

BMAD's commands always spawn fresh agents — `/epic` spawns two new agents, `/implement` Phase 2 spawns a fresh Explore agent, Phase 8 spawns fresh review agents. There's no guidance on when to continue an existing agent via SendMessage vs. spawning fresh.

**Recommendation:** Add a "Continue vs. Spawn" decision reference to `/bmad` and `/implement`. When the implementation pipeline encounters errors in Phase 5/6 (tests failing after review fixes), the queue-and-errors handler should consider continuing the existing context rather than always starting fresh.

---

### Gap 7: Hooks for Automated Quality Enforcement

**Priority: LOW** | **Report source:** Report 05 Section 7, Report 07 Section "Hooks" | **Effort: Medium**

**The gap:** Claude Code supports 16+ hook event types (PreToolUse, PostToolUse, etc.) that can enforce quality automatically. BMAD doesn't configure any hooks in its template settings.

**Recommendation:** Add a `.claude/settings.json` template to the BMAD scaffold with basic quality hooks:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Bash(git commit*)",
        "hooks": [{
          "type": "command",
          "command": "echo 'Reminder: Verify Phase 7 (simplification) and Phase 8 (review) were completed'",
          "statusMessage": "BMAD quality gate reminder"
        }]
      }
    ]
  }
}
```

This is low priority because BMAD's Phase 10 gate check already catches missing phases. But hooks would catch commits made *outside* the `/implement` pipeline (e.g., ad-hoc `git commit` commands).

---

## Part 3: Context Management Insights

Report 03 focuses on context window management — a concern that BMAD addresses indirectly through its phase-split architecture but could optimize further.

### 3.1 BMAD's Implicit Context Management (Already Good)

BMAD's phase-split pattern is an effective form of context management:

- Phase files are loaded on demand ("Read each phase file on demand — do not load all phases upfront")
- Specialist modules use deferred loading ("Note the module paths... Do NOT load modules now — load them when entering the specified phase")
- Golden Principles rule #7 explicitly codifies incremental loading

This aligns with Report 03's "delta-based context injection" pattern — BMAD only injects what's needed for the current phase.

### 3.2 Circuit Breaker Pattern (Partially Implemented)

Report 03 reveals that Anthropic discovered a production bug where sessions made 50+ consecutive failed compaction attempts, costing 250K wasted API calls/day. Their fix: a circuit breaker that stops after 3 consecutive failures.

BMAD has retry limits in some places:
- Phase 6.5 structural validation: "max 3 cycles per check"
- Phase 6.75 runtime validation: "max 3 cycles"
- Queue-and-errors: "Attempt auto-fix (up to 3 attempts)"
- Phase 8: "max 3 cycles" for review re-runs

But these are scattered and inconsistent. Some phases (Phase 5 testing) don't specify a retry limit at all.

**Recommendation:** Standardize on "max 3 retry attempts" across all phases and add it to Phase 5 testing explicitly. Document the circuit breaker pattern in Golden Principles.

### 3.3 Large Result Handling (Not Addressed)

Report 03 describes persisting tool results >50K characters to disk with a 2KB preview. BMAD commands don't address what happens when tool results (e.g., large test output, repomix context) exceed context limits.

**Recommendation:** Add a note to the `/explore` command and Phase 5 (testing) about handling oversized outputs: "If test output exceeds 200 lines, truncate to the first 50 lines of failures plus the summary line. If repomix output exceeds context limits, filter to the relevant module only."

---

## Part 4: Prompt Engineering Improvements

Specific prompt engineering techniques from the reports that would improve BMAD command files.

### 4.1 Analysis Scratchpad Technique

**Report source:** Report 01 Section 10

The compact prompt forces structured thinking in `<analysis>` tags that are stripped from output. Only the `<summary>` section is kept.

**BMAD application:** The `/think` command already uses sequential thinking, but `/review` could benefit from an analysis scratchpad. Before outputting the review, the model should analyze the diff in scratch tags, then produce a clean review. This would reduce false positives from rushed analysis.

### 4.2 Resume/Continuation Pattern

**Report source:** Report 01 Section 9

"Resume directly — do not acknowledge the summary, do not recap what was happening, do not preface with 'I'll continue' or similar."

**BMAD application:** When `/implement` moves between stories in a queue (queue-and-errors.md), the continuation currently says "Next: Story 002 - [title]". It should explicitly instruct: "Continue to next story without recapping. Do not summarize what was just completed — the commit message captures it."

### 4.3 Consequence Framing for Safety Operations

**Report source:** Report 01 Section 5

"The cost of pausing to confirm is low, while the cost of an unwanted action (lost work, unintended messages sent, deleted branches) can be very high."

**BMAD application:** Phase 11 (push & PR) pushes to remote and creates a PR automatically. While there's a safety check for default branch, there's no consequence framing for the push itself. Add: "Pushing to remote is visible to the entire team and triggers CI. If the branch has failing tests, the push will notify reviewers of broken code."

---

## Part 5: Feature Comparison Matrix

How BMAD compares to Claude Code's internal capabilities after applying recommendations:

| Capability | Claude Code Internal | BMAD Current | BMAD After Recs | Gap Closure |
|---|---|---|---|---|
| Proactive collaboration | System prompt | Not present | CLAUDE.md template | 100% |
| Comment discipline | System prompt | Not present | CLAUDE.md template | 100% |
| Epistemic honesty | System prompt | Partial (review only) | CLAUDE.md template + all phases | 100% |
| Verification before done | System prompt | Phase 5-8 gates | + independent verifier | 95% |
| Numeric length anchors | System prompt (25/100 words) | Not present | CLAUDE.md template | 100% |
| Communication style guide | System prompt (400 words) | Not present | CLAUDE.md template | 90% |
| Anti-lazy-delegation | Coordinator prompt (3x) | Not present | Command files | 90% |
| Independent verification | Built-in subagent type | Phase 8 (review, not verify) | Phase 8.5b | 80% |
| Three-tier severity | Consistent across prompts | Inconsistent | Standardized | 85% |
| Rule+Why+Consequence | Every rule | Some rules | Expanded | 80% |
| Continue vs Spawn | Decision table | Always spawn fresh | Decision guidance | 70% |
| Phase-split commands | Commands >200 lines | Already implemented | Already implemented | 100% |
| Context-proportional loading | Dynamic budget | Phase-on-demand | Already strong | 95% |
| Circuit breakers | 3-failure limit | Partial (some phases) | Standardized | 90% |
| Quality gate chain | Single verification step | 4-layer (Phase 5-8) | + verifier = 5-layer | **BMAD exceeds** |
| Specialist routing | Domain-based | Domain-based | Already aligned | 100% |
| Hook automation | 16+ event types | Not configured | Basic hooks | 30% |
| Coordinator mode | Built-in mode | /bmad skill | + anti-delegation | 60% |

---

## Part 6: Implementation Priority Matrix

Ordered by (impact x effort):

| # | Recommendation | Impact | Effort | Files to Modify |
|---|---------------|--------|--------|-----------------|
| 1 | Add behavioral instructions to CLAUDE.md template | CRITICAL | Small | `CLAUDE.md.template` |
| 2 | Anti-lazy-delegation in coordinator prompts | HIGH | Small | `bmad.md`, `epic.md`, `phase-2-exploration.md`, `phase-8-review.md` |
| 3 | Independent verification contract (Phase 8.5b) | HIGH | Medium | `phase-8-review.md` |
| 4 | Continue vs. Spawn decision heuristics | MEDIUM | Small | `bmad.md`, `queue-and-errors.md` |
| 5 | Rule+Why+Consequence for all phase rules | MEDIUM | Medium | All phase files, `golden-principles.md` |
| 6 | Three-tier severity standardization | MEDIUM | Medium | All command files |
| 7 | Circuit breaker standardization | MEDIUM | Small | `phase-5-testing.md`, `golden-principles.md` |
| 8 | Resume/continuation pattern | LOW | Small | `queue-and-errors.md` |
| 9 | Large result handling guidance | LOW | Small | `explore.md`, `phase-5-testing.md` |
| 10 | Hook automation template | LOW | Medium | New: `settings.json` template |

---

## Part 7: Detailed Implementation Specifications

### Spec 1: Behavioral Instructions for CLAUDE.md Template

**File:** `.claude/bmad-template/CLAUDE.md.template`

**Location:** Add a new section `## Code Quality & QA Standards` between `## BMAD Workflow (MANDATORY)` and `## Quick Commands`.

**Content:** The verbatim block from Report 07 (lines 40-68), adapted with one BMAD-specific addition:

```markdown
## Code Quality & QA Standards

### Proactive Collaboration
If you notice the user's request is based on a misconception, or spot a bug adjacent to what
they asked about, say so. You're a collaborator, not just an executor — users benefit from
your judgment, not just your compliance.

### Comment Discipline
Default to writing no comments. Only add one when the WHY is non-obvious: a hidden constraint,
a subtle invariant, a workaround for a specific bug, behavior that would surprise a reader.
If removing the comment wouldn't confuse a future reader, don't write it.

Don't explain WHAT the code does — well-named identifiers already do that. Don't reference the
current task, fix, or callers — those belong in the PR description and rot as the codebase evolves.

Don't remove existing comments unless you're removing the code they describe or you know they're wrong.

### Epistemic Honesty
Report outcomes faithfully: if tests fail, say so with the relevant output; if you did not run
a verification step, say that rather than implying it succeeded. Never claim "all tests pass"
when output shows failures, never suppress or simplify failing checks to manufacture a green
result, and never characterize incomplete or broken work as done. Equally, when a check did pass
or a task is complete, state it plainly — do not hedge confirmed results with unnecessary
disclaimers. The goal is an accurate report, not a defensive one.

### Verification Before Completion
Before reporting a task complete, verify it actually works: run the test, execute the script,
check the output. If you can't verify (no test exists, can't run the code), say so explicitly
rather than claiming success.

### Output Efficiency
Keep text between tool calls to 25 words or fewer. Keep final responses to 100 words unless
the task requires more detail. Lead with the action, not the reasoning.

### Communication Style
Write for a person, not logging to a console. Before your first tool call, briefly state what
you're about to do. While working, give short updates at key moments: when you find something
load-bearing, when changing direction, when you've made progress without an update. Write in
flowing prose. Avoid fragments and excessive em dashes. Match responses to the task: a simple
question gets a direct prose answer, not headers and numbered sections.
```

### Spec 2: Anti-Lazy-Delegation Block

**Add to:** `.claude/commands/bmad.md` (in Phase 2 description), `.claude/commands/epic.md` (in Step 2), `.claude/commands/implement/phase-2-exploration.md` (after the agent prompt), `.claude/commands/implement/phase-8-review.md` (before 8.5)

**Content:**

```markdown
## Synthesis Rule (CRITICAL)

When consuming agent outputs and sending work to subagents, you MUST synthesize findings into
specific details. Never write "based on your findings" or "implement as needed" — these phrases
delegate understanding to the worker instead of doing it yourself.

Bad: "Based on exploration results, create stories for the data pipeline."
Good: "Create 3 stories: (1) Add Parquet writer to src/data/writer.py that accepts DataFrame
and writes to data/cache/ with date-partitioned paths, (2) Add cache invalidation to
src/data/cache.py:45 where the TTL check currently hardcodes 3600s, (3) Add retry logic
to src/data/polygon.py:fetch_bars() which currently fails silently on 429 responses."

Workers can't see your conversation. Every prompt must be self-contained.
```

### Spec 3: Independent Verification Contract

**File:** `.claude/commands/implement/phase-8-review.md`

**Location:** Add as section 8.5b between current 8.6 and 8.7 (or restructure)

**Content:**

```markdown
8.5b Independent Verification (for non-trivial implementations):

    TRIGGER: This step runs when the story changed 3+ files, touched API/data/auth
    code, or modified infrastructure. Skip for documentation-only or single-file changes.

    Spawn a FRESH agent — not the implementer, not a code reviewer:

    Agent:
      subagent_type: general-purpose
      description: "Independent verification"
      prompt: |
        You are an independent verifier. You did NOT write this code. Approach skeptically.

        Changes to verify: [list files changed with brief description]
        Story acceptance criteria: [paste from story]

        Rules:
        - Run tests WITH the feature — not just "tests pass"
        - Run typechecks and INVESTIGATE errors — don't dismiss as "unrelated"
        - Try edge cases and error paths
        - If something looks off, dig in

        For each verification item:
        - Check: What you verified
        - Command: Exact command run
        - Output: Actual output (not summarized)
        - Verdict: PASS / FAIL / PARTIAL

        Final verdict: PASS (all evidence), FAIL (list failures), PARTIAL (list gaps)
        Every PASS must have a Command block with real output. A PASS without evidence is a FAIL.

    On FAIL: Fix issues, re-verify (max 3 cycles)
    On PASS: Spot-check — re-run 2 commands from the report to confirm
    On PARTIAL: Log what passed and what couldn't be verified
```

---

## Part 8: Patterns BMAD Should NOT Adopt

Not everything from the reports applies. These patterns are irrelevant or counterproductive for BMAD:

### 8.1 Fork Model with Byte-Identical Prefixes (Report 02 Section 5)
This is a runtime optimization for API cache hits. BMAD doesn't control the Claude Code runtime — it operates at the prompt level. Not applicable.

### 8.2 File-Based Mailbox Protocol (Report 02 Section 3)
BMAD uses Claude Code's built-in Agent tool for multi-agent work. Implementing a separate mailbox system would duplicate existing functionality. Not applicable.

### 8.3 Beta Header Latching (Report 03 Section 5)
Internal API optimization. Not controllable from CLAUDE.md or skills. Not applicable.

### 8.4 Token Budget Auto-Continue (Report 03 Section 11)
BMAD's phase-split pattern handles long operations better than auto-continue — each phase is a natural continuation point. Not applicable.

### 8.5 Output Style System (Report 05 Section 12)
BMAD's per-project CLAUDE.md already controls output style. Adding a separate output style system would add complexity without benefit. Not applicable.

### 8.6 Aggressive Numeric Length Anchors for All Context
Report 07 suggests "<=25 words between tool calls." This is appropriate for the CLAUDE.md template (where it shapes default behavior) but should NOT be added to command files — many phases require detailed output during execution. The anchor in the CLAUDE.md template is sufficient.

---

## Part 9: Validation Methodology

How I validated each finding:

1. **Read all 7 reports** — 2,800+ lines of extracted patterns
2. **Read all BMAD command files** — 12 implement phases, 6 main commands, 4 utility commands
3. **Read BMAD templates** — CLAUDE.md template, golden-principles, core-config, bmad-master agent
4. **Cross-referenced** each report pattern against BMAD's implementation
5. **Classified** as: Fully Aligned (no action), Partially Aligned (enhancement), Missing (new addition), Not Applicable (skip)
6. **Prioritized** by impact (how much quality improvement) x effort (how many files to change)

**Confidence levels:**
- Recommendations 1-3: High confidence — directly supported by Report 07's verbatim internal prompt text
- Recommendations 4-7: Medium confidence — patterns are solid but BMAD's current approach works adequately
- Recommendations 8-10: Lower confidence — marginal improvements with some implementation risk

---

## Appendix A: Report-to-BMAD Mapping

| Report | Topic | Key BMAD Touchpoints |
|--------|-------|---------------------|
| 01 | Prompt Engineering | CLAUDE.md template, all command files, golden-principles |
| 02 | Agent Coordination | /bmad, /epic, /implement Phase 2/8, queue-and-errors |
| 03 | Context Management | Phase-split pattern (already good), circuit breakers, large results |
| 04 | Tool System | allowed-tools frontmatter, Phase 4 tool usage |
| 05 | Workflow & Skills | Skill frontmatter, settings hooks, memory integration |
| 06 | Applied Patterns | Coordinator prompt (/bmad), verification (/implement Phase 8) |
| 07 | Internal Features | CLAUDE.md template (critical), verification contract, coordinator |

## Appendix B: Files Referenced

### BMAD Command Files Read
- `.claude/commands/bmad.md`
- `.claude/commands/epic.md`
- `.claude/commands/explore.md`
- `.claude/commands/implement.md`
- `.claude/commands/implement/phase-0.5-context-verification.md`
- `.claude/commands/implement/phase-1-context-loading.md`
- `.claude/commands/implement/phase-2-exploration.md`
- `.claude/commands/implement/phase-3-planning.md`
- `.claude/commands/implement/phase-4-execution.md`
- `.claude/commands/implement/phase-5-testing.md`
- `.claude/commands/implement/phase-6-validation.md`
- `.claude/commands/implement/phase-7-simplification.md`
- `.claude/commands/implement/phase-8-review.md`
- `.claude/commands/implement/phase-9-completion.md`
- `.claude/commands/implement/phase-10-commit.md`
- `.claude/commands/implement/phase-11-push-pr.md`
- `.claude/commands/implement/queue-and-errors.md`
- `.claude/commands/maintain.md`
- `.claude/commands/review.md`
- `.claude/commands/score.md`
- `.claude/commands/simplify.md`
- `.claude/commands/story.md`
- `.claude/commands/think.md`

### BMAD Template Files Read
- `.claude/bmad-template/CLAUDE.md.template`
- `.claude/bmad-template/agents/bmad-master.md`
- `.claude/bmad-template/core-config.yaml.template`
- `.claude/bmad-template/templates/golden-principles.md`
- `.claude/bmad-template/workflows/bmad-flow.md`

### Source Reports
- `01-prompt-engineering-techniques.md` (550 lines)
- `02-agent-coordination-patterns.md` (745 lines)
- `03-context-management-techniques.md` (549 lines)
- `04-tool-system-architecture.md` (607 lines)
- `05-workflow-skills-configuration.md` (546 lines)
- `06-applied-patterns-agent-systems.md` (623 lines)
- `07-internal-features-replication-guide.md` (244 lines)
