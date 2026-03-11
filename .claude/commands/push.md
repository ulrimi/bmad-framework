# Git Push Command

Push current branch to remote with upstream tracking.

## Protocol

### Step 1: Check Current State

```bash
CURRENT_BRANCH=$(git branch --show-current)
WORKTREE_ROOT=$(git rev-parse --show-toplevel)

echo "Branch: $CURRENT_BRANCH"
echo "Repo: $WORKTREE_ROOT"
```

### Step 2: Check for Unpushed Commits

```bash
# Check if remote branch exists
if git show-ref --verify --quiet "refs/remotes/origin/$CURRENT_BRANCH"; then
    UNPUSHED=$(git rev-list --count origin/$CURRENT_BRANCH..HEAD)
    echo "Unpushed commits: $UNPUSHED"
else
    echo "Branch not on remote yet - will create"
    UNPUSHED="all"
fi
```

### Step 3: Show What Will Be Pushed

```bash
# Show commit summary
git log origin/$CURRENT_BRANCH..HEAD --oneline 2>/dev/null || git log --oneline -5
```

### Step 4: Push with Upstream

```bash
git push -u origin "$CURRENT_BRANCH"
```

### Step 5: Report Result

```markdown
## Push Complete

| Property | Value |
|----------|-------|
| **Branch** | $CURRENT_BRANCH |
| **Remote** | origin/$CURRENT_BRANCH |
| **Commits Pushed** | $UNPUSHED |

### Next Steps

- Create PR: `/pr`
- Continue working and push again later
```

## Error Handling

### Push Rejected (Non-Fast-Forward)

```bash
echo "Push rejected - remote has changes you don't have locally."
echo "Run /sync first to rebase your changes."
```

### No Commits to Push

```bash
echo "Already up to date with origin/$CURRENT_BRANCH"
```
