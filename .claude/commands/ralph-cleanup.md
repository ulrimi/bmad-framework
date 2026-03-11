# Ralph Worktree Cleanup

**Trigger**: `/ralph-cleanup $ARGUMENTS`

Clean up Ralph worktrees after loops complete.

## Parse Arguments

| Input | Action |
|-------|--------|
| `<name>` | Remove specific worktree (e.g., `exception-hardening`) |
| `--all` | Remove ALL Ralph worktrees |
| (empty) | Interactive: list worktrees and ask which to remove |

## Steps

### Establish repo root

```bash
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
PROJECT_NAME=$(basename "$REPO_ROOT")
BASE_DIR=$(dirname "$REPO_ROOT")
# Robust default branch detection
DEFAULT_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@')
[ -z "$DEFAULT_BRANCH" ] && git remote set-head origin --auto 2>/dev/null && DEFAULT_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@')
DEFAULT_BRANCH="${DEFAULT_BRANCH:-main}"
```

### List Ralph worktrees first

```bash
cd "$REPO_ROOT"
git worktree list
```

Filter to show only worktrees on `ralph/*` branches.

### For each worktree to remove

1. **Check for unpushed work**:
```bash
git -C "$WORKTREE" log --oneline "origin/$DEFAULT_BRANCH..ralph/$NAME" 2>/dev/null
```

2. **Check for uncommitted changes**:
```bash
git -C "$WORKTREE" status --short
```

3. **Warn the user** if there's unpushed or uncommitted work. Ask for confirmation before proceeding.

4. **Remove the worktree**:
```bash
cd "$REPO_ROOT"
WORKTREE="$BASE_DIR/$PROJECT_NAME-ralph-$NAME"
git worktree remove "$WORKTREE" --force
```

5. **Optionally delete the branch** (ask user):
```bash
git branch -D "ralph/$NAME"
```

## Report

After cleanup, show:
- Which worktrees were removed
- Which branches were deleted
- Any remaining Ralph worktrees
