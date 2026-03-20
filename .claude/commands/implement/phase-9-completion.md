# Phase 9: Story Completion

This phase includes story file updates (9) and optional knowledge updates (9.5).

---

## 9.0 Update Story File

```yaml
9.1 Update Story File:
    Edit the story .md file:

    - Change Status: `📋 Ready` → `✅ Complete`
    - Add: `**Completed**: [TODAY'S DATE]`
    - Mark Definition of Done checkboxes: `[x]`
    - Add Completion Notes section:

    ```markdown
    ## Completion Notes

    **Implemented**: [DATE]

    ### Files Changed
    - `path/to/file1.py` - [what changed]
    - `path/to/file2.py` - [what changed]

    ### Tests Added
    - `tests/test_feature.py` - [N] test cases

    ### Simplification Results (REQUIRED)
    - Files reviewed: [N]
    - Issues found: [M]
    - Issues fixed: [X]
    - Lines removed: [Y]
    - Status: [Completed | Skipped (--no-simplify) | No issues found]

    ### Self-Review Results (REQUIRED)
    - Findings: [N] total ([X] critical/high, [Y] medium, [Z] nits)
    - Fixed: [N] (medium+)
    - Skipped: [N] nits

    ### Multi-Agent Review Results (if specialists available)
    - Specialists consulted: [list]
    - Findings: [N] total
    - Fixed: [N]
    - Escalated: [N]

    ### Notes
    - [Any implementation decisions or deviations]
    ```

9.2 Update Epic Overview:
    If epic has a status table, update the story's row to Complete
```

---

## 9.5 Knowledge Update (Lightweight, Optional)

**Purpose**: Capture architectural decisions and new patterns discovered during implementation so future agent sessions benefit. All updates are included in the story commit (Phase 10).

> This phase is lightweight — quick prompts and optional writes. Skip if no architectural decisions were made.

```yaml
9.5.1 Check for Architectural Decisions:
    Reflect: Did this implementation involve any of the following?
    - New architectural patterns or conventions
    - Decisions about module structure, boundaries, or data flow
    - Deviations from the planned architecture
    - Discovery of undocumented conventions

    If none: Log "No architectural decisions to record — skipping Phase 9.5"
             Proceed to Phase 10.

9.5.2 Update Decision Log (if applicable):
    If the epic has a Decision Log section in epic-overview.md:
      Prompt: "Log these decisions in the epic Decision Log? [Y/n]"
      If yes: Append decision entries with date, context, and rationale

9.5.3 Update Architecture Docs (if applicable):
    If new patterns were established that future stories should follow:
      Prompt: "Update ARCHITECTURE.md or golden-principles.md? [Y/n]"
      If yes: Make targeted updates to the relevant doc

9.5.4 Note Quality Impact (if applicable):
    If QUALITY_SCORE.md exists:
      Note whether quality likely improved or degraded in the affected domain
      (Do NOT re-run /score — just leave a brief note for the next /score run)
```

## Next Phase

Read `.claude/commands/implement/phase-10-commit.md` to proceed.
