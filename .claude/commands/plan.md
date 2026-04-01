# ExecPlan Creation (Medium Compute)

**Trigger**: `/plan $ARGUMENTS`

Create an ExecPlan for: **$ARGUMENTS**

ExecPlans are living design documents for complex, multi-story work with significant unknowns. They guide an agent through research, prototyping, and implementation while capturing all decisions, discoveries, and progress.

## Protocol

### Step 0: Establish Repository Root (MANDATORY)

```bash
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
```

ALL paths below are relative to `$REPO_ROOT`.

### Step 1: Determine Output Location

Check for the docs/ knowledge layer (created by `init-bmad --full`):

```bash
if [ -d "$REPO_ROOT/docs/exec-plans/active" ]; then
    PLAN_DIR="$REPO_ROOT/docs/exec-plans/active"
    echo "Using docs layer: $PLAN_DIR"
else
    # Fallback: place alongside epics
    PLAN_DIR="$REPO_ROOT/bmad/epics"
    echo "No docs/ layer found. Using fallback: $PLAN_DIR"
fi
```

Derive filename from `$ARGUMENTS`:
- Slugify the name: lowercase, hyphens for spaces, strip special characters
- Example: `auth migration` → `auth-migration.md`
- Full path: `$PLAN_DIR/[slug].md`

If the file already exists, inform the user and ask whether to overwrite or open the existing plan.

### Step 2: Context Gathering

Deploy TWO agents in parallel:

**Agent 1: Codebase Explorer**
```yaml
subagent_type: Explore
thoroughness: medium
prompt: |
  Explore codebase for ExecPlan: $ARGUMENTS

  > Workers cannot see your conversation, prior agent results, or the broader plan.
  > This prompt is your complete context. If critical information is missing, state what you need.

  Identify:
  - Relevant files and modules (full repository-relative paths)
  - Current state of the system in this area
  - Existing patterns to follow
  - Dependencies and integration points
  - Key interfaces that will be affected

  Return: File inventory with paths, current state summary, patterns, dependencies
```

**Agent 2: Architecture & Scope Assessment**
```yaml
subagent_type: Plan
prompt: |
  Assess scope and architecture for ExecPlan: $ARGUMENTS

  > Workers cannot see your conversation, prior agent results, or the broader plan.
  > This prompt is your complete context. If critical information is missing, state what you need.

  Read: $REPO_ROOT/ARCHITECTURE.md (if present)
  Read: $REPO_ROOT/docs/ (if present)

  Determine:
  - How this work fits existing architecture
  - Components needing modification
  - Key unknowns and risks to de-risk
  - Suggested prototyping milestones
  - Interfaces this work produces or consumes

  Return: Architecture assessment, unknowns, suggested milestones
```

### Step 3: Populate ExecPlan

Read the template from `$REPO_ROOT/.claude/bmad-template/templates/exec-plan-template.md`.

Using the agent outputs and user's description, populate each section:

1. **Title**: Short, action-oriented description derived from `$ARGUMENTS`
2. **Purpose / Big Picture**: Why this matters, written in prose
3. **Progress**: Initialize with plan creation timestamp using today's ISO date
4. **Context and Orientation**: Current state from Explorer agent, key files by full path
5. **Plan of Work**: Sequence of changes from Architecture agent, with prototyping milestones for unknowns
6. **Concrete Steps**: Specific commands and file changes (leave detailed for known parts, outline for unknowns)
7. **Validation and Acceptance**: Observable behaviors that prove success
8. **Idempotence and Recovery**: How steps can be safely re-run
9. **Interfaces and Dependencies**: From Architecture agent output

Leave living-document sections (Surprises & Discoveries, Decision Log, Outcomes & Retrospective) with their initial placeholders — these are filled during execution.

**Key authoring rules** (from the ExecPlans spec):
- Write in prose. Checklists only in the Progress section.
- Embed all required knowledge. Never point to external docs.
- Name files with full repository-relative paths.
- Include prototyping milestones to de-risk unknowns.
- Each step must be idempotent and safe.

### Step 4: Write the Plan

Write the populated ExecPlan to `$PLAN_DIR/[slug].md`.

### Step 5: Report

Display:

```markdown
## ExecPlan Created

| Property | Value |
|----------|-------|
| **Plan** | $ARGUMENTS |
| **Location** | $PLAN_DIR/[slug].md |
| **Unknowns** | [N] items to de-risk |
| **Estimated scope** | [summary from architecture agent] |

### Next Steps
- Review and refine the plan
- Begin implementation with `/implement` or work through the Concrete Steps directly
- Update the Progress section as work proceeds
```

## Lifecycle

ExecPlans are living documents. As work progresses:

1. **During execution**: Update Progress (with ISO timestamps), add Surprises & Discoveries, record decisions in Decision Log
2. **At completion**: Fill Outcomes & Retrospective, then move the file:
   ```bash
   # If using docs/ layer:
   mv docs/exec-plans/active/[plan].md docs/exec-plans/completed/[plan].md
   # If using fallback:
   # Leave in place and mark status as complete in the document
   ```

## Quick Reference

```bash
# Create an ExecPlan for auth migration work
/plan auth migration

# Create an ExecPlan for performance optimization
/plan api response time optimization

# Create an ExecPlan for a research spike
/plan evaluate vector database options
```

Begin creating ExecPlan for: **$ARGUMENTS**
