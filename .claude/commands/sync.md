# Git Sync Command

Sync current branch with remote. Fetches latest and rebases local changes on top.

## Protocol

### Step 1: Check Current State

```bash
# Get branch info
CURRENT_BRANCH=$(git branch --show-current)
echo "Branch: $CURRENT_BRANCH"

# Check for uncommitted changes
if ! git diff --quiet || ! git diff --cached --quiet; then
    echo "WARNING: Uncommitted changes detected"
    git status --short
fi
```

### Step 2: Fetch Latest

```bash
git fetch origin
```

### Step 3: Show What Will Change

```bash
# Show commits we're behind
BEHIND=$(git rev-list --count HEAD..origin/$CURRENT_BRANCH 2>/dev/null || echo "0")
AHEAD=$(git rev-list --count origin/$CURRENT_BRANCH..HEAD 2>/dev/null || echo "0")

echo "Status: $AHEAD ahead, $BEHIND behind origin/$CURRENT_BRANCH"
```

### Step 4: Rebase (if behind)

If there are remote changes, rebase local commits on top:

```bash
if [ "$BEHIND" -gt 0 ]; then
    echo "Rebasing local changes on top of origin/$CURRENT_BRANCH..."
    git rebase origin/$CURRENT_BRANCH
fi
```

### Step 5: Report Result

Display summary:

```markdown
## Sync Complete

| Property | Value |
|----------|-------|
| **Branch** | $CURRENT_BRANCH |
| **Pulled** | $BEHIND commits |
| **Local** | $AHEAD commits ahead |
| **Status** | Up to date with origin |
```

## Error Handling

### Rebase Conflicts

If rebase fails due to conflicts:

```bash
echo "Rebase conflict detected. Options:"
echo "  1. Resolve conflicts, then: git rebase --continue"
echo "  2. Abort rebase: git rebase --abort"
git status
```

### No Remote Branch

If the branch doesn't exist on remote yet:

```bash
echo "Branch $CURRENT_BRANCH not on remote yet."
echo "Run /push to push it."
```
