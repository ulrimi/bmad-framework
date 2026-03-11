# Epic Refinement (Gap Analysis)

**Trigger**: `/refine $ARGUMENTS`

Refine an existing epic: **$ARGUMENTS**

This command performs deep gap analysis and refinement on an already-created epic.

## Protocol

### Step 0: Establish Repository Root (MANDATORY)

```bash
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
```

ALL `bmad/` paths below are relative to `$REPO_ROOT`. Never use bare `bmad/epics/`.

### Step 1: Load Epic Context

```bash
# Find the epic in THIS repo
ls "$REPO_ROOT/bmad/epics/" | grep -i "$ARGUMENTS"

# Read epic overview
cat "$REPO_ROOT/bmad/epics/[epic-name]/epic-overview.md"

# Read all stories
cat "$REPO_ROOT/bmad/epics/[epic-name]/stories/*.md"
```

### Step 2: Generate Fresh Codebase Context

```bash
npx repomix --style xml --output /tmp/context.xml \
  --ignore "**/*.lock,**/*.json,node_modules/,dist/,venv/,**/.git/"
```

Read the output for current codebase state.

### Step 3: Deploy Gap Analysis Agent

```yaml
subagent_type: general-purpose
prompt: |
  Perform rigorous gap analysis on epic: $ARGUMENTS

  ## Inputs
  - Epic overview: [content]
  - Stories: [content]
  - Fresh codebase context: [from repomix]

  ## Analysis Required

  ### Structural Gaps
  - Missing stories (logical steps omitted)
  - Dependency issues (blocking relationships not documented)
  - Edge cases not covered

  ### Technical Optimization
  - Code duplication (proposing code that exists)
  - Over-engineering (too complex for problem)
  - Under-engineering (too naive for requirements)

  ### Architecture Alignment
  - Pattern violations
  - Database design issues
  - API contract problems

  ## Output
  Refinement report with:
  - Critical gaps (must fix)
  - Optimizations (should fix)
  - Nice-to-haves (could fix)
  - Specific fix recommendations per story
```

### Step 4: Sequential Reasoning for Refinement Decisions

Use `mcp__sequential-thinking__sequentialthinking` with 6+ thoughts:

1. What gaps are truly critical?
2. What can be deferred?
3. How do fixes affect dependencies?
4. What's the minimal change set?
5. Are there ripple effects?
6. Final refinement plan

### Step 5: Apply Refinements

For each identified gap:
1. Update story file directly
2. Add missing acceptance criteria
3. Enhance technical context
4. Update dependency graph if needed

### Step 6: Execute BMAD Refine Task

Read and follow: `$REPO_ROOT/bmad/qf-bmad/tasks/refine-epic.md`

### Step 7: Output Refinement Report

```markdown
# Refinement Report: [Epic Name]

## Critical Gaps Fixed
- [Gap 1]: [How fixed]
- [Gap 2]: [How fixed]

## Optimizations Applied
- [Optimization 1]: [Change made]

## Stories Updated
- story-001: [Changes]
- story-002: [Changes]

## New Stories Added
- story-00X: [Why needed]

## Validation
- [ ] All stories still atomic
- [ ] Dependencies updated
- [ ] Technical context complete
```

## Quick Reference

```bash
/refine billing
/refine signup-hardening
/refine dynamic-pricing
```

Begin refinement of: **$ARGUMENTS**
