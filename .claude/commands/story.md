# Story Creation & Implementation

**Trigger**: `/story $ARGUMENTS`

Work with story: **$ARGUMENTS**

This command handles both creating new stories and implementing existing ones.

## Intent Detection

Parse `$ARGUMENTS` to determine mode:

| Input Pattern | Mode | Action |
|---------------|------|--------|
| `epic-name/story-name` | Implement | Load and implement existing story |
| `create epic-name/story-name` | Create | Create new story in epic |
| `epic-name` only | List | Show stories in epic, ask which to work on |

---

## Step 0: Establish Repository Root (MANDATORY)

```bash
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
```

ALL `bmad/` paths below are relative to `$REPO_ROOT`. Never use bare `bmad/epics/`.

---

## Mode: Implement Existing Story

### Step 1: Load Story Context

```bash
# Find the story in THIS repo
cat "$REPO_ROOT/bmad/epics/[epic]/stories/[story].md"
```

### Step 2: Identify Specialist

Read story content and match to specialist from `$REPO_ROOT/bmad/config/agents/bmad-master.md`:

| Story Domain | Specialist File |
|--------------|-----------------|
| Strategy, backtest, signals, entry/exit, opening range | `agents/active/strategy-engine-specialist.md` |
| UI, Streamlit, sidebar, charts, rendering | `agents/active/streamlit-ui-specialist.md` |
| Data, Polygon, cache, Parquet, calendar | `agents/active/data-pipeline-specialist.md` |
| PnL, metrics, reporting, analytics, sweep | `agents/active/analytics-reporting-specialist.md` |
| Testing, QA, validation, fixtures | `agents/active/qa-testing-specialist.md` |

### Step 3: Load Specialist Persona

Read the identified specialist file and adopt its:
- Expertise and principles
- Command patterns
- Quality criteria

### Step 4: Execute Implementation

Follow the story's:
- Acceptance criteria (implement each)
- Technical context (follow patterns)
- Testing requirements (write tests)

### Step 5: Update Story Status

After implementation:
```markdown
Status: ✅ Complete
**Completed**: [TODAY'S DATE]

## Completion Notes
- [What was implemented]
- [Files changed]
- [Tests added]
```

---

## Mode: Create New Story

### Step 1: Verify Epic Exists

```bash
ls "$REPO_ROOT/bmad/epics/" | grep -i [epic-name]
```

If epic doesn't exist, suggest using `/epic` first.

### Step 2: Gather Story Context

Deploy exploration:
```yaml
subagent_type: Explore
thoroughness: quick
prompt: |
  Quick exploration for story context: $ARGUMENTS

  > Workers cannot see your conversation, prior agent results, or the broader plan.
  > This prompt is your complete context. If critical information is missing, state what you need.

  Identify and return:
  1. Files that will be modified or created (full paths from repo root)
  2. Patterns used in similar existing code (cite specific file:function examples)
  3. Related test files that exist for the affected modules
  4. Key imports and dependencies of the affected files

  Output format: Structured list with file paths, line counts, and pattern examples.
```

### Step 3: Execute Create Story Task

Read and follow: `$REPO_ROOT/bmad/config/tasks/create-story.md`

Ensure story includes:
- Clear user story (As a/I want/So that)
- Testable acceptance criteria
- Technical context with real file paths
- Testing requirements
- Definition of done

### Step 4: Create Story File

Write to: `$REPO_ROOT/bmad/epics/[epic]/stories/story-00N-[name].md`

The story file MUST include YAML frontmatter before the markdown content:
```markdown
---
id: epic-name-001
epic: epic-name
specialist: backend
status: Draft
scope: [src/api/, src/models/]
depends_on: []
---

# Story: Brief Title
...
```

The frontmatter enables lean queue-building without loading full story bodies.
Both frontmatter AND bold metadata (`**Status**:`, etc.) should be present for human readability.

### Step 5: Update Epic Overview

Add story to epic's story list with status.

---

## Mode: List Stories

### Step 1: Show Epic Stories

```bash
ls "$REPO_ROOT/bmad/epics/[epic]/stories/"
```

### Step 2: Show Status Summary

```markdown
## Stories in [Epic]

| # | Story | Status | Specialist |
|---|-------|--------|------------|
| 001 | [name] | ⏳ In Progress | api-gateway |
| 002 | [name] | ✅ Complete | frontend |
| 003 | [name] | 📋 Ready | sqlalchemy |
```

### Step 3: Ask User

"Which story would you like to work on?"

---

## Quick Reference

```bash
# Implement existing story
/story data-cache/parquet-store

# Create new story
/story create billing/invoice-pdf

# List stories in epic
/story billing
```

Process: **$ARGUMENTS**
