# Implement Command - Story-Driven Development Execution

**Trigger**: `/implement $ARGUMENTS`

Execute full implementation for: **$ARGUMENTS**

---

## Step 0: Establish Repository Root (MANDATORY — RUN FIRST)

```bash
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd) && \
echo "=== REPO_ROOT: $REPO_ROOT ===" && \
echo "=== Branch: $(git branch --show-current) ===" && \
echo "=== Worktree: $(if [ "$(git rev-parse --git-common-dir 2>/dev/null)" != "$(git rev-parse --git-dir 2>/dev/null)" ]; then echo "YES"; else echo "NO (main repo)"; fi) ===" && \
echo "=== Available epics ===" && \
ls "$REPO_ROOT/bmad/epics/" 2>/dev/null || echo "ERROR: No bmad/epics/ directory at $REPO_ROOT"
```

All paths use `$REPO_ROOT` as prefix. If in main repo (not worktree) and implementing a full epic, warn user to consider `/feature` first.

---

## Argument Resolution (first match wins)

1. **Direct epic-overview.md path** — arg ends with `epic-overview.md` and file exists → Epic Mode
2. **Direct epic directory** — arg is directory containing `epic-overview.md` → Epic Mode
3. **Direct story path** — arg ends with `.md` and file exists → Story Mode
4. **Epic name shorthand** — no `/` in arg → Glob `$REPO_ROOT/bmad/epics/{arg}/epic-overview.md` → Epic Mode
5. **Epic/story shorthand** — one `/` → split `{epic}/{story}`:
   - First try exact basename match: `stories/{story}.md`
   - Then glob: `stories/*{story}*.md`
   - If multiple matches found, prompt user to select rather than picking first
   → Story Mode
6. **Multiple story files** — multiple `.md` args → Multi-Story Mode

If none match: show error with available epics from `$REPO_ROOT/bmad/epics/`.

---

## Build Story Queue

For each story file, extract routing metadata using **frontmatter-first parsing**:

1. Read the story file starting from line 1
2. If `---` fence detected on line 1, read until the closing `---` fence (or EOF) and parse the full YAML block for `status`, `specialist`, `depends_on`, `runtime_validation`, etc.
3. If no frontmatter fence on line 1, fall back to parsing bold metadata lines (`**Status**:`, `**Assigned to**:`)

```python
story_queue = []
for arg in ARGUMENTS:
    resolved = resolve(arg)  # Uses resolution order above
    if EPIC_MODE:
        stories = glob(f"{epic_dir}/stories/story-*.md")
        for story in sorted(stories):
            metadata = parse_frontmatter_or_bold(story)  # frontmatter-first
            if metadata.status not in ['Complete', 'Archived', '✅ Complete']:
                story_queue.append(story)
    elif STORY_MODE:
        story_queue.append(resolved_story_path)
if not story_queue:
    error("No incomplete stories found")
```

## Display Work Plan

| # | Story | Status | Specialist |
|---|-------|--------|------------|
| 1 | story-001-*.md | Ready | [from frontmatter `specialist:` or bold `**Assigned to**:`] |

Show estimated scope, branch name. Ask: **Proceed? [Y/n]**

---

## Phase Dispatch

For EACH story in queue, execute phases in order. **Read each phase file on demand** — do not load all phases upfront.

| Phase | File to Read | Description |
|-------|-------------|-------------|
| 0.5 | `.claude/commands/implement/phase-0.5-context-verification.md` | Verify ARCHITECTURE.md/CLAUDE.md freshness (once, not per-story) |
| 1 | `.claude/commands/implement/phase-1-context-loading.md` | Read story, verify prereqs, load specialist |
| 2 | `.claude/commands/implement/phase-2-exploration.md` | Scan codebase, identify change scope |
| 3 | `.claude/commands/implement/phase-3-planning.md` | Sequence changes, get user approval |
| 4 | `.claude/commands/implement/phase-4-execution.md` | Write code file by file |
| 5 | `.claude/commands/implement/phase-5-testing.md` | Run tests, write new tests |
| 6 | `.claude/commands/implement/phase-6-validation.md` | Lint, acceptance criteria, structural + runtime validation |
| **7** | **`.claude/commands/implement/phase-7-simplification.md`** | **MANDATORY — Boy Scout Rule simplification** |
| **8** | **`.claude/commands/implement/phase-8-review.md`** | **MANDATORY — Self-review + multi-agent review** |
| 9 | `.claude/commands/implement/phase-9-completion.md` | Update story file + optional knowledge update |
| 10 | `.claude/commands/implement/phase-10-commit.md` | Gate check for 7 & 8, then commit |

After each story: Read `.claude/commands/implement/queue-and-errors.md` for continuation logic.

After ALL stories complete: Read `.claude/commands/implement/phase-11-push-pr.md` to push and create PR.

---

## Quick Reference

```bash
/implement bmad/epics/data-layer/epic-overview.md   # Direct epic path
/implement bmad/epics/data-layer                     # Direct epic directory
/implement data-layer                                # Epic name shorthand
/implement data-layer/parquet-store                  # Epic/story shorthand
/implement story-dl-001.md story-dl-002.md           # Multiple stories
```

---

Begin implementation of: **$ARGUMENTS**
