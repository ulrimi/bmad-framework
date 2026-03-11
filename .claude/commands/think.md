# Deep Sequential Reasoning

**Trigger**: `/think $ARGUMENTS`

Engage deep structured reasoning for: **$ARGUMENTS**

This command invokes `mcp__sequential-thinking__sequentialthinking` for complex problems that require careful, multi-step analysis without full BMAD orchestration.

## When to Use

- Complex architectural decisions
- Trade-off analysis
- Debugging difficult issues
- Planning without epic creation
- Understanding complex code
- Risk assessment

## Protocol

### Step 1: Frame the Problem

Before thinking, gather context:
- What is the core question?
- What constraints exist?
- What information do we have?
- What are we trying to decide?

### Step 2: Initialize Deep Thinking

```yaml
tool: mcp__sequential-thinking__sequentialthinking
parameters:
  thought: "Analyzing: $ARGUMENTS. Let me structure this problem..."
  nextThoughtNeeded: true
  thoughtNumber: 1
  totalThoughts: 10  # Minimum for complex problems
```

### Step 3: Thinking Structure

Follow this thought progression:

**Thoughts 1-2: Problem Decomposition**
- Break down the problem into components
- Identify what we know vs. don't know
- Surface hidden assumptions

**Thoughts 3-4: Evidence Gathering**
- What does the codebase tell us?
- What do docs say?
- What has worked before?

**Thoughts 5-6: Option Generation**
- What are the possible approaches?
- What are the trade-offs of each?
- What do we NOT want to do?

**Thoughts 7-8: Analysis & Comparison**
- Compare options against criteria
- Consider second-order effects
- Check mission alignment

**Thoughts 9-10: Synthesis & Recommendation**
- Form a hypothesis
- Verify against evidence
- State confidence level
- Identify remaining uncertainties

### Step 4: Allow Branching & Revision

If during thinking you realize:
- Previous thought was wrong → Use `isRevision: true`
- Need to explore alternative → Use `branchFromThought: N`
- Need more depth → Increase `totalThoughts`

### Step 5: Output Conclusions

After thinking completes, summarize:

```markdown
## Analysis: $ARGUMENTS

### Problem
[Restated clearly]

### Key Findings
1. [Finding with evidence]
2. [Finding with evidence]

### Recommendation
[Clear recommendation with reasoning]

### Confidence Level
[High/Medium/Low] because [reasoning]

### Remaining Uncertainties
- [Uncertainty 1]
- [Uncertainty 2]

### Next Steps
1. [Action if recommendation accepted]
2. [Action if need more info]
```

---

## Thinking Intensity Levels

| Complexity | Thoughts | Use For |
|------------|----------|---------|
| Quick | 5 | Simple decisions, clarifications |
| Standard | 10 | Feature planning, trade-offs |
| Deep | 15 | Architecture decisions, debugging |
| Maximum | 20+ | Novel problems, critical decisions |

---

## Examples

```bash
# Architecture decision
/think should we use Redis or PostgreSQL for session storage

# Trade-off analysis
/think sync vs async for blockchain transaction submission

# Debugging
/think why are webhook retries failing intermittently

# Planning
/think how should we structure the multi-tenant isolation
```

---

## Quality Principles

1. **No rushed conclusions** - Use all allocated thoughts
2. **Evidence-based** - Reference actual code/docs
3. **Acknowledge uncertainty** - Don't fake confidence
4. **Revise when wrong** - Use revision mechanism
5. **Branch when needed** - Explore alternatives properly

Begin deep analysis of: **$ARGUMENTS**
