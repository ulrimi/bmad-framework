# Maximum-Compute Codebase Exploration

**Trigger**: `/explore $ARGUMENTS`

Deep exploration of: **$ARGUMENTS**

This command deploys maximum intelligence for codebase understanding WITHOUT planning or implementation.

## When to Use

- Understanding unfamiliar code
- Research before planning
- Finding all instances of a pattern
- Mapping dependencies
- Answering "how does X work?"

## Protocol

### Step 1: Deploy Exploration Agent

```yaml
subagent_type: Explore
thoroughness: very thorough
prompt: |
  # Deep Codebase Exploration: $ARGUMENTS

  > Workers cannot see your conversation, prior agent results, or the broader plan.
  > This prompt is your complete context. If critical information is missing, state what you need.

  ## Your Mission
  Achieve complete understanding of how $ARGUMENTS works in this codebase.

  ## MANDATORY FIRST STEP: Full Context

  Generate compressed repository context:
  ```bash
  npx repomix --style xml --output /tmp/explore-context.xml \
    --ignore "**/*.lock,**/*.json,node_modules/,dist/,venv/,**/.git/,**/*.svg,**/*.png"
  ```

  Read the output file to understand the full codebase structure.

  If repomix output is too large for a single read, re-run with --include scoped
  to the relevant module:
  ```bash
  npx repomix --style xml --output /tmp/explore-context.xml \
    --include "src/[relevant-module]/**" \
    --ignore "**/*.lock,node_modules/"
  ```

  ## Exploration Tools

  Use ALL of these as needed:

  1. **Pattern Search**
     ```
     Glob: **/*[keyword]*.py
     Glob: **/*[keyword]*.ts
     Glob: **/*[keyword]*.tsx
     ```

  2. **Content Search**
     ```
     Grep: "class.*[Keyword]"
     Grep: "def.*[keyword]"
     Grep: "function.*[keyword]"
     Grep: "import.*[keyword]"
     ```

  3. **File Deep Dive**
     ```
     Read: [specific files found]
     ```

  4. **Structure Understanding**
     ```
     Bash: tree -L 3 [relevant directory]
     Bash: wc -l [files to gauge complexity]
     ```

  5. **Dependency Tracing**
     ```
     Grep: "from.*import.*[module]"
     Grep: "import.*[module]"
     ```

  ## Required Outputs

  ### 1. Component Map
  All files/modules related to $ARGUMENTS:
  - File path
  - Purpose
  - Key classes/functions
  - Dependencies (imports from, imported by)

  ### 2. Data Flow
  How data moves through the system:
  - Entry points
  - Transformations
  - Storage
  - Exit points

  ### 3. Control Flow
  How execution flows:
  - Triggers
  - Decision points
  - Error handling paths
  - Async boundaries

  ### 4. Pattern Analysis
  Patterns used in this area:
  - Design patterns
  - Error handling approach
  - Testing approach
  - Naming conventions

  ### 5. Integration Points
  How this connects to other systems:
  - Internal integrations
  - External API calls
  - Database interactions
  - Event/message flows

  ### 6. Quality Assessment
  Current state observations:
  - Test coverage
  - Code complexity
  - Technical debt
  - Documentation quality
```

### Step 2: Synthesize Findings

After agent completes, use sequential thinking if needed:

```yaml
tool: mcp__sequential-thinking__sequentialthinking
parameters:
  thought: "Synthesizing exploration findings for $ARGUMENTS..."
  totalThoughts: 5
```

### Step 3: Output Exploration Report

```markdown
# Exploration Report: $ARGUMENTS

## Summary
[2-3 sentence overview of what was found]

## Component Map

| File | Purpose | Key Elements |
|------|---------|--------------|
| path/to/file.py | Description | class X, def Y |
| ... | ... | ... |

## Data Flow
```
[Entry] → [Process] → [Store] → [Output]
```

## Key Findings

### How It Works
[Explanation of the mechanism]

### Patterns Used
- [Pattern 1]: [Where/why]
- [Pattern 2]: [Where/why]

### Integration Points
- [System 1]: [How connected]
- [System 2]: [How connected]

## Quality Notes

### Strengths
- [Strength 1]
- [Strength 2]

### Concerns
- [Concern 1]
- [Concern 2]

## Related Code
Files you might also want to explore:
- `path/to/related1.py` - [Why relevant]
- `path/to/related2.ts` - [Why relevant]
```

---

## Exploration Depth Levels

| Depth | Thoroughness | Use For |
|-------|--------------|---------|
| Quick | `quick` | Simple lookups, file finding |
| Standard | `medium` | Understanding a feature |
| Deep | `very thorough` | Full system understanding |

---

## Examples

```bash
# Understand a feature
/explore how billing works

# Find all usages
/explore where API keys are validated

# Map a subsystem
/explore the webhook processing pipeline

# Understand patterns
/explore how error handling works in services
```

Begin exploration of: **$ARGUMENTS**
