# Phase 0.5: Context Verification (Lightweight)

**Purpose**: Verify that knowledge artifacts are current before building on them. Quick file reads only — no lengthy analysis.

> This phase runs once at the start of the story queue (not per-story).
> If docs don't exist, it proceeds without blocking.

```yaml
0.5.1 Check ARCHITECTURE.md:
    If ARCHITECTURE.md exists at $REPO_ROOT:
      Quick-scan for references to files or modules that don't exist:
      - Extract file paths and module names mentioned in the doc
      - Glob/stat to verify they exist on disk
      If stale references found:
        Warn: "ARCHITECTURE.md references [N] files/modules that no longer exist:
               - path/to/removed_module.py
               - path/to/old_service/
               Proceed with implementation anyway? [Y/update docs first]"
      If clean: Log "ARCHITECTURE.md verified — references are current"
    Else:
      Log "No ARCHITECTURE.md found — skipping verification"

0.5.2 Check CLAUDE.md Pointers:
    If CLAUDE.md exists at $REPO_ROOT:
      Verify key file references point to existing files
      (e.g., test commands reference real test directories,
       lint commands reference real config files)
      If broken pointers found:
        Warn: "CLAUDE.md references [N] paths that don't exist: [list]"
      If clean: Log "CLAUDE.md pointers verified"
    Else:
      Log "No CLAUDE.md found — skipping verification"

0.5.3 Proceed:
    Context verification complete. Proceed to Phase 1.
    Total time: <30 seconds (file reads only)
```

## Next Phase

Read `.claude/commands/implement/phase-1-context-loading.md` to proceed.
