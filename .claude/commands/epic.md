# Epic Creation (Medium Compute)

**Trigger**: `/epic $ARGUMENTS`

Create a new BMAD epic for: **$ARGUMENTS**

This is a lighter-weight version of `/bmad` that focuses on epic creation without the full parallel agent deployment.

## Protocol

### Step 0: Establish Repository Root (MANDATORY)

```bash
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
```

ALL `bmad/` paths below are relative to `$REPO_ROOT`. Never use bare `bmad/epics/`.

### Step 1: Context Gathering

Deploy TWO agents in parallel:

**Agent 1: Codebase Explorer**
```yaml
subagent_type: Explore
thoroughness: medium
prompt: |
  Explore codebase for: $ARGUMENTS

  MANDATORY: Run repomix first:
  ```bash
  npx repomix --style xml --output /tmp/context.xml \
    --ignore "**/*.lock,**/*.json,node_modules/,dist/,venv/,**/.git/"
  ```

  Then identify:
  - Relevant files and modules
  - Existing patterns to follow
  - Dependencies and integration points

  Return: File list, patterns, dependencies
```

**Agent 2: Architecture Check**
```yaml
subagent_type: Plan
prompt: |
  Analyze architecture implications for: $ARGUMENTS

  Read: $REPO_ROOT/ARCHITECTURE.md (or docs/ if present)

  Determine:
  - How this fits existing architecture
  - Components needing modification
  - Database/API implications

  Return: Architecture assessment, component list
```

### Step 2: Execute Create Epic Task

With agent outputs, execute: `$REPO_ROOT/bmad/qf-bmad/tasks/create-epic.md`

### Step 3: Immediate Refinement

Execute: `$REPO_ROOT/bmad/qf-bmad/tasks/refine-epic.md`

Apply refinements to stories.

### Step 4: Output

Create:
- `$REPO_ROOT/bmad/epics/[epic-name]/epic-overview.md`
- `$REPO_ROOT/bmad/epics/[epic-name]/stories/story-001-*.md` through `story-00N-*.md`

## When to Use /epic vs /bmad

| Use `/epic` | Use `/bmad` |
|-------------|-------------|
| Clear scope, known patterns | Novel problem, unclear scope |
| Single-system changes | Multi-system integration |
| Incremental features | Major architecture changes |
| Time-sensitive | Quality-critical |

## Quick Reference

```bash
/epic signup form validation
/epic api rate limiting
/epic invoice pdf generation
```

Begin with: **$ARGUMENTS**
