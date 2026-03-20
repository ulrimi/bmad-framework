# Phase 5: Testing

```yaml
5.1 Run Existing Tests (ensure no regression):
    Use the test command from CLAUDE.md. Use Bash timeout=180000.
    If failures: FIX THEM before proceeding.
    If Bash times out: run only the test files relevant to your changes.

    TIMEOUT CAVEAT (prevents test-loop time sink):
    If the output shows tests running with 0 failures and only pass/skip
    results, ACCEPT THAT AS A PASS even if the summary line is cut off.
    Do NOT re-run tests just to "get the summary line".

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
