---
id: ph-006
epic: prompt-heuristics
specialist: framework
status: Draft
scope: [.claude/commands/implement/phase-11-push-pr.md, .claude/commands/explore.md, .claude/commands/implement/phase-5-testing.md]
depends_on: []
---

# Story: Safety Framing + Large Result Handling

**Status**: Draft
**Priority**: LOW
**Effort**: S (3 files, 1-3 lines each)

## User Story

As a developer using BMAD, I want consequence framing on irreversible operations (push, PR creation) and guidance for handling oversized tool results so that I'm aware of the blast radius before actions go live and long outputs don't consume the context window.

## Background

Two minor gaps from the analysis report, consolidated into one story:

1. **Consequence Framing** (Report 01 Section 5): Anthropic's prompts make abstract harms concrete: "The cost of pausing to confirm is low, while the cost of an unwanted action (lost work, unintended messages sent, deleted branches) can be very high." Phase 11 pushes to remote and creates PRs automatically without framing the consequences.

2. **Large Result Handling** (Report 03 Section 9): Claude Code persists tool results >50K characters to disk with a 2KB preview. BMAD commands don't address what happens when tool results (repomix output, large test suites) exceed useful context limits.

## Acceptance Criteria

### Consequence Framing

- [ ] AC1: Phase 11 push step includes consequence framing: "Pushing to remote is visible to the team and triggers CI. Verify tests pass locally before pushing."
- [ ] AC2: Phase 11 PR creation includes: "Creating a PR notifies reviewers and may trigger automated deployments. Verify all quality gates passed."

### Large Result Handling

- [ ] AC3: `/explore` command includes guidance: "If repomix output exceeds context limits, re-run with `--include` scoped to the relevant module only."
- [ ] AC4: Phase 5 testing includes guidance: "If test output exceeds 200 lines, focus on the first failure and the summary line. Do not paste full output into context."

## Technical Context

### `.claude/commands/implement/phase-11-push-pr.md`

**Add to section 11.2 before the push command:**

```markdown
> **Consequence**: Pushing to remote is visible to the entire team and triggers CI pipelines.
> If tests are failing locally, the push will notify reviewers of broken code. Verify all
> quality gates (Phase 5-8) passed before pushing.
```

**Add to section 11.5 before the `gh pr create` command:**

```markdown
> **Consequence**: Creating a PR notifies reviewers and may trigger automated checks or
> deployments. Ensure the PR title and body accurately represent the changes — misleading
> descriptions waste reviewer time.
```

### `.claude/commands/explore.md`

**Add after the repomix command in the agent prompt (around line 35):**

```markdown
  If repomix output is too large for a single read, re-run with --include scoped
  to the relevant module:
  ```bash
  npx repomix --style xml --output /tmp/explore-context.xml \
    --include "src/[relevant-module]/**" \
    --ignore "**/*.lock,node_modules/"
  ```
```

### `.claude/commands/implement/phase-5-testing.md`

**Add after section 5.1 TIMEOUT CAVEAT:**

```markdown
    LARGE OUTPUT CAVEAT:
    If test output exceeds 200 lines, do NOT paste the full output into context.
    Focus on: (1) the first failing test's error message, (2) the summary line
    showing pass/fail counts. Read the full output from the persisted file if needed.
```

## Testing Requirements

- Verify consequence framing is present in Phase 11
- Verify explore.md has scoped repomix guidance
- Verify Phase 5 has large output guidance

## Definition of Done

- [ ] Phase 11 push has consequence framing
- [ ] Phase 11 PR creation has consequence framing
- [ ] Explore command has scoped repomix fallback guidance
- [ ] Phase 5 has large output handling guidance
