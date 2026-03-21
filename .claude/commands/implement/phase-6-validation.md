# Phase 6: Validation & Linting

This phase includes core validation (6), structural validation (6.5), and runtime validation (6.75).

---

## 6.0 Core Validation

```yaml
6.1 Linting:
    Run the lint and format-check commands from CLAUDE.md.
    If failures: auto-fix where possible, manual edits otherwise.

6.2 Acceptance Criteria Verification:
    Go through EACH acceptance criterion in the story:

    - [ ] AC1: [description] - VERIFIED by [how]
    - [ ] AC2: [description] - VERIFIED by [how]
    - [ ] AC3: [description] - VERIFIED by [how]

    If ANY AC is not met: implement missing functionality
```

---

## 6.5 Structural Validation (Configurable)

**Purpose**: Enforce architectural invariants mechanically — catch code that works but violates structural boundaries.

> This phase runs only when `structural_validation.enabled: true` in the project's `core-config.yaml`.
> If not configured, it logs a skip message and proceeds to Phase 7.

```yaml
6.5.1 Check Configuration:
    Read core-config.yaml and look for structural_validation section.

    If structural_validation.enabled is false or missing:
      Log: "No structural validation configured — skipping Phase 6.5"
      Proceed to Phase 7.

6.5.2 Run Configured Checks:
    For each entry in structural_validation.checks:
      ```bash
      # Run the configured check command
      $CHECK_COMMAND
      ```
      - If check passes: log success, continue to next check
      - If check fails: proceed to 6.5.3

6.5.3 Fix-Retry Loop (max 3 cycles per check):
    For each failed check:
      a) Read the error output (check scripts should include remediation hints)
      b) Attempt to fix the violation
      c) Re-run the failed check
      d) If fixed: log fix and continue
      e) If still failing after 3 cycles:
         - If the violation requires architectural discussion → flag for human review
         - Ask: "Structural check '[name]' failing after 3 fix attempts.
                 [S]kip check, [A]sk for help, [Q]uit"

6.5.4 Log Results:
    Record in story completion notes:

    ### Structural Validation Results
    - Checks configured: [N]
    - Checks passed: [X]
    - Checks fixed: [Y] (with retry)
    - Checks skipped: [Z]
```

---

## 6.75 Runtime Validation (Configurable)

**Purpose**: Launch the application and verify acceptance criteria against the running system — catching configuration errors, integration mismatches, and runtime issues that unit tests miss.

> This phase runs only when the story file contains a `runtime_validation` section with checks configured.
> If no `runtime_validation` section exists, it logs a skip message and proceeds to Phase 7.

```yaml
6.75.1 Check Story for Runtime Validation:
    Parse the current story file for a runtime_validation section.

    If no runtime_validation section or it is commented out:
      Log: "No runtime_validation configured in story — skipping Phase 6.75"
      Proceed to Phase 7.

6.75.2 Launch Application:
    Read launch_command from the story's runtime_validation section.
    If launch_command is not set, fall back to core-config.yaml commands.app_launch.

    ```bash
    # Start the application in the background
    $LAUNCH_COMMAND &
    APP_PID=$!

    # Wait for application to be ready (up to 30 seconds)
    for i in $(seq 1 30); do
      if kill -0 $APP_PID 2>/dev/null; then
        # App process is running, try health check if configured
        break
      fi
      sleep 1
    done
    ```

    If the application fails to start:
      Log: "Application failed to start — skipping runtime validation"
      Proceed to Phase 7 (do not block on startup failures)

6.75.3 Run Acceptance Checks:
    For each entry in runtime_validation.acceptance_checks:

      ```bash
      # Run the check command
      RESULT=$($CHECK_COMMAND)
      ```

      Compare RESULT to the expected value:
      - If match: log "✅ [description]: passed"
      - If no match: log "❌ [description]: expected [$expected], got [$RESULT]"
        Mark as failed

    If any check fails:
      Proceed to 6.75.4

    If all checks pass:
      Log: "All runtime validation checks passed"
      Proceed to 6.75.5

6.75.4 Fix-Retry Loop (max 3 cycles):
    For each failed check:
      a) Analyze the failure output
      b) Attempt to fix the underlying issue in code
      c) Restart the application if needed
      d) Re-run the failed check
      e) If fixed: log fix and continue
      f) If still failing after 3 cycles:
         Ask: "Runtime check '[description]' failing after 3 attempts.
               [S]kip check, [A]sk for help, [Q]uit"

6.75.5 Cleanup:
    ```bash
    # Stop the application
    kill $APP_PID 2>/dev/null
    wait $APP_PID 2>/dev/null
    ```

6.75.6 Log Results:
    Record in story completion notes:

    ### Runtime Validation Results
    - Checks configured: [N]
    - Checks passed: [X]
    - Checks fixed: [Y] (with retry)
    - Checks skipped: [Z]
```

## Next Phase

Read `.claude/commands/implement/phase-7-simplification.md` to proceed.
