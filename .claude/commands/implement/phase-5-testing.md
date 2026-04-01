# Phase 5: Testing

```yaml
5.1 Run Existing Tests (ensure no regression):
    Use the test command from CLAUDE.md. Use Bash timeout=180000.
    If failures: FIX THEM before proceeding.
    Max 3 fix attempts per failing test. If still failing after 3 cycles:
    - Show failure details with exact error output
    - Ask: "Tests failing after 3 fix attempts. [R]etry, [S]kip, [A]sk for help, [Q]uit"
    - Do not retry silently — escalate to user.
    If Bash times out: run only the test files relevant to your changes.

    TIMEOUT CAVEAT (prevents test-loop time sink):
    If the output shows tests running with 0 failures and only pass/skip
    results, ACCEPT THAT AS A PASS even if the summary line is cut off.
    Do NOT re-run tests just to "get the summary line".

    LARGE OUTPUT CAVEAT:
    If test output exceeds 200 lines, do NOT paste the full output into context.
    Focus on: (1) the first failing test's error message, (2) the summary line
    showing pass/fail counts. Read the full output from the persisted file if needed.

5.2 Write New Tests (per story requirements):
    - Unit tests for new functions
    - Integration tests for new endpoints
    - Follow existing test patterns in tests/

5.3 Run New Tests:
    ```bash
    pytest tests/test_[new].py -v
    ```
    If failures: FIX THEM before proceeding

5.4 Coverage Check (if specified in story):
    ```bash
    pytest --cov=app/[module] tests/
    ```
```

## Next Phase

Read `.claude/commands/implement/phase-6-validation.md` to proceed.
