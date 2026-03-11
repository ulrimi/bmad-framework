# Ralph Worktree Status Dashboard

**Trigger**: `/ralph-status`

Show the status of all Ralph autonomous worktrees.

## Steps

1. **Establish repo root and list all worktrees**:

```bash
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
PROJECT_NAME=$(basename "$REPO_ROOT")
BASE_DIR=$(dirname "$REPO_ROOT")
# Robust default branch detection
DEFAULT_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@')
[ -z "$DEFAULT_BRANCH" ] && git remote set-head origin --auto 2>/dev/null && DEFAULT_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@')
DEFAULT_BRANCH="${DEFAULT_BRANCH:-main}"

cd "$REPO_ROOT"
git worktree list
```

2. **For each Ralph worktree** (branch matches `ralph/*`):

Gather and display:

```bash
WORKTREE="$BASE_DIR/$PROJECT_NAME-ralph-$NAME"

# Branch name
git -C "$WORKTREE" branch --show-current

# Commit count ahead of default branch
git -C "$WORKTREE" rev-list --count "origin/$DEFAULT_BRANCH..HEAD"

# Last commit message and time
git -C "$WORKTREE" log --oneline -1
git -C "$WORKTREE" log -1 --format="%cr"

# Working tree status (clean vs dirty)
git -C "$WORKTREE" status --short | wc -l

# Check for RALPH_LOG.md (blocker documentation)
test -f "$WORKTREE/RALPH_LOG.md" && echo "Has RALPH_LOG.md"

# Check diff stats against default branch
git -C "$WORKTREE" diff --stat "origin/$DEFAULT_BRANCH..HEAD" | tail -1
```

3. **Format as a dashboard table**:

```
Ralph Worktree Status
=====================

| Worktree | Branch | Commits | Last Activity | Status | Notes |
|----------|--------|---------|---------------|--------|-------|
| exception-hardening | ralph/exception-hardening | 12 | 2 hours ago | Clean | +340 -89 across 7 files |
| security-config | ralph/security-config | 8 | 30 min ago | Dirty | Has RALPH_LOG.md |
| pyjwt-migration | ralph/pyjwt-migration | 0 | (not started) | Clean | |
```

4. **Show summary** with:
   - Total Ralph worktrees
   - Total commits across all
   - Any worktrees with RALPH_LOG.md (potential blockers)
   - Suggested next actions (push, review, cleanup)
