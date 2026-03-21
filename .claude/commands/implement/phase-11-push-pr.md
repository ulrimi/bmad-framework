# Phase 11: Push & Create PR

Runs automatically after ALL stories in the queue are complete.

---

## 11.1 Display Implementation Summary

```markdown
## Implementation Complete

### Stories Implemented
| Story | Status | Commit |
|-------|--------|--------|
| story-001-db-models | ✅ Complete | abc123 |
| story-002-api-endpoints | ✅ Complete | def456 |

### Stories Skipped (if any)
| Story | Reason |
|-------|--------|
| story-003-frontend | Blocked by external dependency |
```

## 11.2 Push Branch to Remote

```yaml
CURRENT_BRANCH=$(git branch --show-current)
# Robust default branch detection (never hardcode main/master)
DEFAULT_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@')
if [ -z "$DEFAULT_BRANCH" ]; then
  git remote set-head origin --auto 2>/dev/null
  DEFAULT_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@')
fi
DEFAULT_BRANCH="${DEFAULT_BRANCH:-main}"

# Abort if on default branch (safety check)
if [ "$CURRENT_BRANCH" = "$DEFAULT_BRANCH" ]; then
    echo "WARNING: On $DEFAULT_BRANCH — cannot auto-create PR."
    echo "Manually create a branch and cherry-pick if needed."
    exit 1
fi

# Push with upstream tracking
git push -u origin "$CURRENT_BRANCH"

# Handle push rejection (non-fast-forward)
# If rejected: inform user to run /sync, then retry
```

## 11.3 Check for Existing PR

```yaml
EXISTING_PR=$(gh pr list --head "$CURRENT_BRANCH" --json number,url --jq '.[0]')
if [ -n "$EXISTING_PR" ]; then
    echo "PR already exists for this branch:"
    gh pr view "$CURRENT_BRANCH"
    SKIP PR creation — display existing PR URL and finish
fi
```

## 11.4 Gather PR Context

```yaml
# Commits since divergence from default branch
COMMITS=$(git log origin/$DEFAULT_BRANCH..HEAD --oneline)
COMMIT_COUNT=$(git rev-list --count origin/$DEFAULT_BRANCH..HEAD)
FILES_CHANGED=$(git diff --stat origin/$DEFAULT_BRANCH..HEAD | tail -1)

# Build story list from the implementation session
# Use the stories_implemented[] array tracked during the queue
```

## 11.5 Create PR

```yaml
Generate PR title:
  - If single story: "feat(epic-name): story title"
  - If multiple stories: "feat(epic-name): implement [N] stories — [brief epic description]"
  - Keep under 70 characters

Generate PR body using this template:

gh pr create --title "$PR_TITLE" --body "$(cat <<'EOF'
## Summary

[1-3 sentence description of what this implementation delivers,
 derived from the epic goal and stories completed]

## Stories Implemented

| Story | Description | Commit |
|-------|-------------|--------|
| story-001 | [title] | abc123 |
| story-002 | [title] | def456 |

## Stories Skipped (if any)

| Story | Reason |
|-------|--------|
| story-003 | Blocked by [reason] |

## Changes

- $COMMIT_COUNT commits
- $FILES_CHANGED

## Commits

$COMMITS

## Quality Gates

- [x] All tests pass
- [x] Linting passes
- [x] Code simplification review (Phase 7)
- [x] Self-review + multi-agent review (Phase 8)
- [x] Acceptance criteria verified per story

## Test Plan

- [x] Unit tests pass
- [x] Linting clean
- [ ] Integration tests (if applicable)
- [ ] Manual verification

---
🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)" --base "$DEFAULT_BRANCH" --head "$CURRENT_BRANCH"
```

## 11.6 Report Final Result

```markdown
## PR Created

| Property | Value |
|----------|-------|
| **Branch** | $CURRENT_BRANCH → $DEFAULT_BRANCH |
| **Stories** | [N] implemented |
| **Commits** | $COMMIT_COUNT |
| **PR URL** | [link from gh pr create output] |

### Branch Summary
git log --oneline $DEFAULT_BRANCH..HEAD
```

---

## Error Handling

```yaml
Push Rejected (Non-Fast-Forward):
    "Push rejected — remote has changes you don't have locally."
    "Run /sync first, then /push and /pr manually."

gh CLI Not Authenticated:
    "GitHub CLI not authenticated. Run: gh auth login"
    "Then create PR manually: /pr"

No Commits to Push:
    "Already up to date with origin/$CURRENT_BRANCH — no PR needed."
```
