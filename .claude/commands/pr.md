# Create Pull Request Command

Create a GitHub PR from current branch to main/master.

## Protocol

### Step 1: Check Prerequisites

```bash
CURRENT_BRANCH=$(git branch --show-current)
# Robust default branch detection (never hardcode main/master)
DEFAULT_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@')
if [ -z "$DEFAULT_BRANCH" ]; then
  git remote set-head origin --auto 2>/dev/null
  DEFAULT_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@')
fi
DEFAULT_BRANCH="${DEFAULT_BRANCH:-main}"

echo "Current branch: $CURRENT_BRANCH"
echo "Target branch: $DEFAULT_BRANCH"

# Ensure we're not on the default branch
if [ "$CURRENT_BRANCH" = "$DEFAULT_BRANCH" ]; then
    echo "ERROR: Cannot create PR from $DEFAULT_BRANCH to itself"
    exit 1
fi
```

### Step 2: Ensure Branch is Pushed

```bash
# Check if branch exists on remote
if ! git show-ref --verify --quiet "refs/remotes/origin/$CURRENT_BRANCH"; then
    echo "Branch not on remote. Pushing..."
    git push -u origin "$CURRENT_BRANCH"
fi
```

### Step 3: Check for Existing PR

```bash
EXISTING_PR=$(gh pr list --head "$CURRENT_BRANCH" --json number,url --jq '.[0]')
if [ -n "$EXISTING_PR" ]; then
    echo "PR already exists:"
    gh pr view "$CURRENT_BRANCH" --web
    exit 0
fi
```

### Step 4: Gather PR Information

Analyze the commits to generate PR title and body:

```bash
# Get commits since branching
COMMITS=$(git log origin/$DEFAULT_BRANCH..HEAD --oneline)
COMMIT_COUNT=$(git rev-list --count origin/$DEFAULT_BRANCH..HEAD)
FIRST_COMMIT_MSG=$(git log origin/$DEFAULT_BRANCH..HEAD --format=%s | tail -1)

# Get changed files summary
FILES_CHANGED=$(git diff --stat origin/$DEFAULT_BRANCH..HEAD | tail -1)
```

### Step 5: Create PR

```bash
gh pr create \
    --title "$PR_TITLE" \
    --body "$PR_BODY" \
    --base "$DEFAULT_BRANCH" \
    --head "$CURRENT_BRANCH"
```

**PR Body Template:**

```markdown
## Summary

[Brief description based on commits]

## Changes

- $COMMIT_COUNT commits
- $FILES_CHANGED

## Commits

$COMMITS

## Test Plan

- [ ] Tests pass locally
- [ ] Linting passes
- [ ] Manual verification

---
Generated with Claude Code
```

### Step 6: Report Result

```markdown
## PR Created

| Property | Value |
|----------|-------|
| **Branch** | $CURRENT_BRANCH |
| **Target** | $DEFAULT_BRANCH |
| **Commits** | $COMMIT_COUNT |
| **URL** | [link] |

### Next Steps

- Review the PR on GitHub
- Request reviewers
- Address any CI failures
```

## Error Handling

### No Changes

```bash
echo "No commits between $DEFAULT_BRANCH and $CURRENT_BRANCH"
echo "Nothing to create a PR for."
```

### gh CLI Not Authenticated

```bash
echo "GitHub CLI not authenticated. Run:"
echo "  gh auth login"
```
