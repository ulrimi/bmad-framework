# Git Status Command

Show status of all worktrees and their sync state with remote.

## Protocol

### Step 1: Get Main Repo

```bash
# Find the main repo (not a worktree)
MAIN_REPO=$(git worktree list | head -1 | awk '{print $1}')
cd "$MAIN_REPO"
```

### Step 2: Fetch All Remotes

```bash
git fetch --all --quiet
```

### Step 3: List All Worktrees with Status

For each worktree, show:
- Path
- Branch
- Ahead/behind remote
- Uncommitted changes
- PR status (if any)

```bash
git worktree list | while read -r line; do
    WORKTREE_PATH=$(echo "$line" | awk '{print $1}')
    BRANCH=$(echo "$line" | awk '{print $3}' | tr -d '[]')

    cd "$WORKTREE_PATH"

    # Check for uncommitted changes
    if git diff --quiet && git diff --cached --quiet; then
        DIRTY=""
    else
        DIRTY="*"
    fi

    # Check ahead/behind
    AHEAD=$(git rev-list --count origin/$BRANCH..HEAD 2>/dev/null || echo "?")
    BEHIND=$(git rev-list --count HEAD..origin/$BRANCH 2>/dev/null || echo "?")

    # Check for PR
    PR_NUM=$(gh pr list --head "$BRANCH" --json number --jq '.[0].number' 2>/dev/null || echo "")

    echo "$WORKTREE_PATH|$BRANCH$DIRTY|$AHEAD|$BEHIND|$PR_NUM"
done
```

### Step 4: Format Output

Display as a table:

```markdown
## Worktree Status

| Path | Branch | Ahead | Behind | PR |
|------|--------|-------|--------|-----|
| /path/to/main | master | 0 | 0 | - |
| /path/to/feature-1 | feature/billing* | 3 | 0 | #42 |
| /path/to/feature-2 | feature/frontend | 0 | 2 | - |

**Legend:**
- `*` after branch = uncommitted changes
- Ahead = local commits not pushed
- Behind = remote commits not pulled

### Recommendations

[Based on status, suggest actions like:]
- `feature/frontend` is behind - run `/sync` in that worktree
- `feature/billing` has unpushed commits - run `/push`
```

### Step 5: Show Orphaned Branches

Check for feature branches without worktrees:

```bash
echo ""
echo "## Remote Feature Branches (no worktree)"

git branch -r | grep "origin/feature/" | while read -r branch; do
    LOCAL_BRANCH=${branch#origin/}
    # Check if any worktree uses this branch
    if ! git worktree list | grep -q "$LOCAL_BRANCH"; then
        echo "- $branch"
    fi
done
```

## Quick Actions

After viewing status, suggest relevant commands:

```markdown
### Quick Actions

| Worktree | Suggested Action |
|----------|------------------|
| feature/billing | `/push` (3 unpushed commits) |
| feature/frontend | `/sync` (2 behind remote) |
| feature/api | `/pr` (pushed but no PR) |
```
