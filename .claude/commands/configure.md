---
allowed-tools: Read, Glob, Grep, Edit, Bash(ls:*), Bash(cat:*), Bash(head:*), Bash(git:*)
argument-hint: [--all | --claude-md | --specialists | --dry-run | --force]
description: Auto-detect project settings and fill TODO markers in CLAUDE.md and BMAD config files
---

# Configure Command — Auto-Detect Project Settings

**Trigger**: `/configure $ARGUMENTS`

Auto-detect and fill project settings for: **$ARGUMENTS**

This command analyzes your codebase to fill remaining `<!-- TODO: ... -->` markers in CLAUDE.md and BMAD specialist files.

---

## Argument Parsing

| Flag | Effect |
|------|--------|
| (none) or `--all` | Analyze and fill everything |
| `--claude-md` | Only update CLAUDE.md |
| `--specialists` | Only update specialist agent files |
| `--dry-run` | Show detections but don't modify files |
| `--force` | Overwrite already-filled sections (not just TODOs) |

```
MODE="all"
DRY_RUN=false
FORCE=false

for arg in $ARGUMENTS; do
  case "$arg" in
    --claude-md)    MODE="claude-md" ;;
    --specialists)  MODE="specialists" ;;
    --all)          MODE="all" ;;
    --dry-run)      DRY_RUN=true ;;
    --force)        FORCE=true ;;
  esac
done
```

---

## Phase Dispatch

Execute phases in order. **Read each phase file on demand** — do not load all phases upfront.

| Phase | File to Read | Description |
|-------|-------------|-------------|
| 1 | `.claude/commands/configure/phase-1-discover.md` | Scan TODO markers, dependencies, configs, env vars, dirs |
| 2 | `.claude/commands/configure/phase-2-analyze.md` | Synthesize into tech stack, architecture, code style, specialist settings |
| 3 | `.claude/commands/configure/phase-3-present.md` | Display settings, get user confirmation (or dry-run) |
| 4 | `.claude/commands/configure/phase-4-apply.md` | Apply changes with Edit tool, report results |

If `--specialists` mode: skip to Phase 2.6 (specialist settings) and Phase 4.2 (apply specialists).
If `--claude-md` mode: skip specialist-related steps in each phase.

---

Begin configuration: **$ARGUMENTS**
