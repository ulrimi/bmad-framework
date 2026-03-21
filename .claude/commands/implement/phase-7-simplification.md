# Phase 7: Code Simplification (MANDATORY)

**Purpose**: Apply the Boy Scout Rule - leave code cleaner than you found it.

> **CRITICAL**: This phase runs on EVERY implementation. It is NOT optional.
> Only skip if user explicitly passes `--no-simplify` flag.

```yaml
7.1 Complexity Scan:
    Use sequential thinking to review ALL changes made in this story:

    mcp__sequential-thinking__sequentialthinking:
      thought: |
        MANDATORY SIMPLIFICATION REVIEW

        Files changed in this implementation: [LIST ALL FILES]

        Checking against CLAUDE.md simplification rules:
        1. SINGLE-USE ABSTRACTIONS: Are there helpers/utilities used only once?
        2. PREMATURE ABSTRACTIONS: Anything abstracted before 3 uses?
        3. LONG FUNCTIONS: Any functions >50 lines?
        4. DEAD CODE: Unused imports, variables, or commented code?
        5. OVER-HANDLING: Error handling for impossible scenarios?
        6. BACKWARDS-COMPAT HACKS: Unused _vars, re-exports, "# removed" comments?
        7. OBVIOUS COMMENTS: Comments explaining self-evident code?
        8. FEATURE CREEP: Configurability beyond what was asked?

        For each file, analyze systematically...
      totalThoughts: 6
      nextThoughtNeeded: true

7.2 Report Findings:
    ALWAYS produce a simplification report, even if empty:

    ## Simplification Analysis

    **Files reviewed**: [N]
    **Issues found**: [M]

    If M == 0:
      "✅ No simplification opportunities found. Code is clean."

    If M > 0:
      | # | File:Line | Issue | Severity | Action |
      |---|-----------|-------|----------|--------|
      | 1 | service.py:45 | Single-use helper | MEDIUM | Inline |
      | 2 | router.py:23-89 | 66-line function | HIGH | Split into 2 |
      | 3 | models.py:12 | Unused import | LOW | Remove |

      Apply simplifications? [Y/n/select]

7.3 Apply Approved Simplifications:
    For each approved simplification:

    TodoWrite:
      - content: "Simplify [file]: [issue]"
        status: in_progress

    a) Read current file state
    b) Apply the specific change
    c) Verify syntax is valid (python -m py_compile / tsc --noEmit)
    d) Mark todo complete

7.4 Re-Validate After Simplification:
    MUST re-run validation after ANY simplification changes:

    # Re-run tests (use Bash timeout=180000)
    # Apply same TIMEOUT CAVEAT from Phase 5.1

    # Re-run linting (use lint commands from CLAUDE.md)

    If failures:
      - Identify which simplification broke things
      - Revert that specific change
      - Continue with remaining changes
      - Proceed to Phase 8 for review

7.5 Log Simplification Outcome:
    Record in story completion notes:

    ### Simplification Results
    - Files reviewed: [N]
    - Issues found: [M]
    - Issues fixed: [X]
    - Lines removed: [Y]
```

**IMPORTANT**: Never skip this phase silently. If skipping due to `--no-simplify`, explicitly log: "Simplification skipped per --no-simplify flag."

## Next Phase

Read `.claude/commands/implement/phase-8-review.md` to proceed.
