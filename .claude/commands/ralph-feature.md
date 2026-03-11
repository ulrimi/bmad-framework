# Ralph Worktree Setup (Prep Only)

**Trigger**: `/ralph-feature $ARGUMENTS`

Create an isolated git worktree for a Ralph autonomous loop. This command **only creates the worktree** — it cannot launch a new Claude session or skip permissions from inside the current session. After running this, the user must open a separate terminal to start the actual Ralph loop.

## Parse Arguments

`$ARGUMENTS` should be a name like `exception-hardening` or `security-config`.

## Steps

1. **Validate** the name is provided (error if empty)

2. **Establish repo root and create the worktree** from the main repo:

```bash
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
PROJECT_NAME=$(basename "$REPO_ROOT")
BASE_DIR=$(dirname "$REPO_ROOT")
# Robust default branch detection
DEFAULT_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@')
[ -z "$DEFAULT_BRANCH" ] && git remote set-head origin --auto 2>/dev/null && DEFAULT_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@')
DEFAULT_BRANCH="${DEFAULT_BRANCH:-main}"

cd "$REPO_ROOT"
git fetch origin "$DEFAULT_BRANCH" 2>/dev/null || true

WORKTREE="$BASE_DIR/$PROJECT_NAME-ralph-$ARGUMENTS"
BRANCH="ralph/$ARGUMENTS"

# Create if doesn't exist
if [ ! -d "$WORKTREE" ]; then
    git worktree add -b "$BRANCH" "$WORKTREE" "$DEFAULT_BRANCH"
fi
```

3. **Symlink config** into the worktree:

```bash
ln -sf "$REPO_ROOT/.claude" "$WORKTREE/.claude"
ln -sf "$REPO_ROOT/CLAUDE.md" "$WORKTREE/CLAUDE.md"
# Symlink venv if it exists
[ -d "$REPO_ROOT/venv" ] && ln -sf "$REPO_ROOT/venv" "$WORKTREE/venv"
```

4. **Report to user** with clear next steps:

```
Worktree ready at:
  $WORKTREE
  Branch: ralph/{name}

NEXT STEP — open a new terminal and run:

  claude-feature --ralph {name}

This launches Claude Code with --dangerously-skip-permissions in the worktree.
Then paste your /ralph-loop prompt.
```

## Important

- Do NOT switch the current session's working directory
- Do NOT start a Ralph loop in this session — it won't have permissions skipped
- This command ONLY creates the worktree; the actual Ralph session must be launched from a terminal via `claude-feature --ralph {name}`
