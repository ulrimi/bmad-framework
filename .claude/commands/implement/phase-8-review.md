# Phase 8: Self-Review + Multi-Agent Review (MANDATORY)

**Purpose**: Run `/review` on your own changes, then route reviews to domain-specialist agents for deeper analysis. Fix meaningful issues before committing.

> **CRITICAL**: This phase runs on EVERY implementation. It is NOT optional.
> Multi-agent review runs when specialist agents are available in `bmad/config/agents/active/`.

```yaml
8.1 Run /review on Uncommitted Changes:
    Execute the /review command against the current uncommitted diff.
    This performs a structured code review covering:
    - Correctness and logic errors
    - Security issues (injection, secrets, input validation)
    - Performance concerns
    - Style and consistency with CLAUDE.md conventions
    - Test coverage gaps

8.2 Process Self-Review Findings:
    Automatically fix medium-severity and above. Nits are informational only.

    | Priority | Action |
    |----------|--------|
    | Critical (bugs, security) | Fix immediately |
    | High (correctness, performance) | Fix immediately |
    | Medium (improvements, consistency) | Fix |
    | Nits (style, naming, minor) | Skip — log but do not fix |

8.3 Apply Self-Review Fixes:
    For each medium+ finding:
    a) Read the affected file
    b) Apply the fix
    c) If the fix is ambiguous, use best judgment aligned with CLAUDE.md style

    Do NOT fix nits — they add churn without meaningful value.

8.4 Multi-Agent Review — Determine Specialist Domains:
    Analyze which files were changed and map to specialist agents:

    a) List all files modified in this story implementation
    b) Match file paths/modules to specialist domains:
       - auth, security, crypto files → security-perspective review
       - API routes, endpoints → backend-specialist review
       - UI components, templates → frontend-specialist review
       - Database, data layer, caching → data-specialist review
       - Infrastructure, CI/CD, deploy → infra-specialist review
       - Tests, fixtures, QA → qa-specialist review
    c) Load matching specialist agent files from bmad/config/agents/active/

    If no specialist agents exist in the project:
      Log: "No specialist agents configured — skipping multi-agent review"
      Proceed to 8.7

8.5 Multi-Agent Review — Specialist Reviews:
    For each relevant specialist:

    a) Spawn a review subagent (Agent tool) with the specialist persona loaded
    b) Provide the subagent with:
       - The diff of all changes
       - The story's acceptance criteria
       - Instruction: "Review from [specialist] perspective. Output findings
         with severity (critical/high/medium/nit) and specialist attribution."
    c) Collect findings with specialist attribution:
       - Format: "[Specialist] Finding description" (e.g., "[Security] API key exposed in error response")

    Run specialist reviews in parallel where possible.

8.6 Multi-Agent Review — Merge and Address Findings:
    a) Merge all specialist findings with self-review findings
    b) Deduplicate (same issue found by multiple reviewers)
    c) Sort by severity (critical → high → medium → nit)
    d) Address medium+ findings (apply fixes)
    e) If >10 lines changed in fixes, re-run specialist reviews (max 3 cycles)

    Escalation Rules — flag for human review instead of resolving autonomously:
    - Conflicting guidance between specialists (e.g., security says add validation,
      performance says remove it)
    - Architectural boundary violation that needs design discussion
    - Security-critical finding with unclear remediation
    - Any finding where the correct fix is ambiguous across domains

    If escalation triggered:
      "⚠️ Escalation: [description]. Requires human judgment.
       [C]ontinue with best guess, [A]sk for guidance, [S]kip this finding"

8.7 Re-Validate After All Fixes:
    MUST re-run tests and linting after any review fixes:

    # Re-run tests (use Bash timeout=180000)
    # Re-run linting (use lint commands from CLAUDE.md)

    If failures:
      - Identify which fix broke things
      - Adjust the fix to maintain correctness
      - Re-validate until green

8.8 Log Review Outcome:
    Record in story completion notes:

    ### Self-Review Results
    - Findings: [N] total ([X] critical/high, [Y] medium, [Z] nits)
    - Fixed: [N] (medium+)
    - Skipped: [N] nits

    ### Multi-Agent Review Results
    - Specialists consulted: [list, e.g., security, backend, data]
    - Findings: [N] total ([X] critical/high, [Y] medium, [Z] nits)
    - Fixed: [N]
    - Escalated: [N] (with reasons)
    - Review cycles: [N]
```

## Next Phase

Read `.claude/commands/implement/phase-9-completion.md` to proceed.
