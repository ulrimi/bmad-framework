# Phase 10: Commit

## Gate Check (MANDATORY — verify before committing)

BEFORE committing, verify BOTH mandatory phases completed:

**Phase 7 (Simplification) evidence** — at least one:
- Simplification report was output (even if "0 issues found")
- Sequential thinking tool was invoked for complexity scan
- Explicit "Simplification skipped per --no-simplify flag" log

**Phase 8 (Self-Review + Multi-Agent Review) evidence** — at least one:
- /review was run and findings were processed
- Self-review results logged (even if "0 findings")
- Multi-agent review results logged (or "No specialist agents configured" skip logged)

**If either is missing: STOP and run the missing phase before proceeding.**

---

## Commit Steps

```yaml
10.1 Stage All Changes:
    ```bash
    git add [implementation files, story file, any docs updated in Phase 9.5]
    ```

10.2 Create Story-Scoped Commit:
    ```bash
    git commit -m "$(cat <<'EOF'
    feat(epic-name): Implement story-001 - [brief description]

    - [Key change 1]
    - [Key change 2]
    - [Key change 3]

    Story: bmad/epics/[epic]/stories/story-001-*.md

    🤖 Generated with [Claude Code](https://claude.com/claude-code)

    Co-Authored-By: Claude <noreply@anthropic.com>
    EOF
    )"
    ```

10.3 Verify Commit:
    ```bash
    git log -1 --oneline
    git status  # Should be clean
    ```
```

## Next Phase

Read `.claude/commands/implement/queue-and-errors.md` for queue continuation logic.
If this is the last story, read `.claude/commands/implement/phase-11-push-pr.md` to push and create PR.
