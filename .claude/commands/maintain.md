---
allowed-tools: Bash(git log:*), Bash(git blame:*), Bash(wc:*), Bash(find:*), Read, Glob, Grep, Edit, Agent
argument-hint: [--skip-score]
description: Repository-wide quality, consistency, and documentation checks. Scans for pattern drift, documentation staleness, and tech debt.
---

# Maintain Command — Repository-Wide Quality Scan

**Trigger**: `/maintain $ARGUMENTS`

Scan the repository for pattern drift, documentation staleness, and tech debt. Functions like garbage collection for technical debt — small, continuous payments prevent compounding.

---

## Step 0: Establish Repository Root

```bash
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
```

Verify `$REPO_ROOT` is correct. All subsequent paths use `$REPO_ROOT` as prefix.

---

## Step 1: Pre-Flight Checks

```yaml
1.1 Locate Key Files:
    Required:
      - $REPO_ROOT/CLAUDE.md (or .claude/CLAUDE.md)

    Optional (enhances results):
      - $REPO_ROOT/ARCHITECTURE.md
      - $REPO_ROOT/bmad/qf-bmad/golden-principles.md
      - $REPO_ROOT/docs/ (knowledge base directory)
      - $REPO_ROOT/docs/QUALITY_SCORE.md
      - $REPO_ROOT/docs/exec-plans/tech-debt-tracker.md

    If CLAUDE.md is missing:
      "No CLAUDE.md found. Run init-bmad to bootstrap the project first."
      STOP.

1.2 Parse Arguments:
    --skip-score  → Skip quality scoring (faster run)
```

---

## Step 2: Launch Parallel Scans

Deploy up to 3 subagents in parallel for speed. Each returns structured findings.

### 2.1 Pattern Consistency Agent

```yaml
Agent:
  subagent_type: Explore
  description: "Scan for pattern drift"
  prompt: |
    Scan the codebase at $REPO_ROOT for pattern consistency issues.

    If golden-principles.md exists at $REPO_ROOT/bmad/qf-bmad/golden-principles.md,
    read it and check the codebase against each rule.

    If it does not exist, check against these universal principles:
    1. Functions under 50 lines
    2. One responsibility per file
    3. Validate at boundaries, trust internal data
    4. No hand-rolled helpers when shared packages exist
    5. External API calls in a single integration module
    6. Error messages include remediation
    7. No silent exception swallowing
    8. Tests mirror module structure
    9. Comments explain WHY not WHAT

    For each violation found, report:
    - File path and line number(s)
    - Which principle is violated
    - Severity: HIGH / MEDIUM / LOW
    - What to do about it

    Also check for:
    - Duplicated utility patterns (same logic in multiple files)
    - Hand-rolled helpers that duplicate stdlib or common packages
    - Boundary violations (data crossing layers without validation)

    Output: Structured list of findings with severity levels.
    If no violations found, say "No pattern consistency issues found."
```

### 2.2 Documentation Freshness Agent

```yaml
Agent:
  subagent_type: Explore
  description: "Check doc freshness"
  prompt: |
    Check documentation freshness in the repository at $REPO_ROOT.

    1. ARCHITECTURE.md (if exists):
       - Scan for references to files, directories, or modules that no longer exist
       - Check if the module/directory structure described matches reality
       - Flag sections that reference removed or renamed code

    2. CLAUDE.md:
       - Check that file paths referenced in the document exist
       - Verify command references are valid
       - Flag stale TODO markers

    3. docs/ directory (if exists):
       - Check each .md file for references to code that no longer exists
       - Flag files not updated in >90 days (use git log)
       - Check for broken internal links between docs

    4. Code-level documentation:
       - Find stale TODO/FIXME/HACK comments older than 30 days (use git blame)
       - Limit to 20 most stale items

    For each finding, report:
    - File path and line number
    - What's stale or incorrect
    - Severity: HIGH (misleading) / MEDIUM (outdated) / LOW (cosmetic)
    - Suggested action

    Output: Structured list of findings.
    If everything is fresh, say "No documentation freshness issues found."
```

### 2.3 Quality Scoring (unless --skip-score)

If `--skip-score` is NOT passed:

```
Run /score to get current quality grades.
Include the score summary in the maintain output.
```

If `--skip-score` IS passed or `/score` command is not available:
```
Skip quality scoring. Note in output: "Quality scoring skipped."
```

---

## Step 3: Synthesize Findings

After all agents return, combine results into a single report.

### 3.1 Categorize All Findings

```yaml
Categories:
  - Pattern Consistency: Violations of golden principles, duplicated code, boundary issues
  - Documentation Freshness: Stale docs, broken references, outdated TODOs
  - Quality Scores: Current grades and regressions (if /score was run)
```

### 3.2 Prioritize

```yaml
Priority Rules:
  1. HIGH severity findings first within each category
  2. Findings affecting frequently-changed files rank higher
  3. Findings with easy fixes rank higher than complex ones
```

---

## Step 4: Output Report

```markdown
# Maintenance Report — [DATE]

**Repository**: [PROJECT_NAME from CLAUDE.md or directory name]
**Scanned**: [N] source files across [M] directories

---

## Pattern Consistency

| # | File:Line | Principle Violated | Severity | Action |
|---|-----------|-------------------|----------|--------|
| 1 | src/service.py:145 | Function over 50 lines | HIGH | Split into smaller functions |
| 2 | src/utils.py:23 | Hand-rolled CSV parser | MEDIUM | Use stdlib csv module |

_[N] issues found_ (or "No issues found ✓")

## Documentation Freshness

| # | File:Line | Issue | Severity | Action |
|---|-----------|-------|----------|--------|
| 1 | ARCHITECTURE.md:45 | References deleted module `old_auth/` | HIGH | Update module map |
| 2 | src/api.py:12 | TODO from 60 days ago | LOW | Resolve or remove |

_[N] issues found_ (or "No issues found ✓")

## Quality Scores

[Include /score output summary here, or "Quality scoring skipped."]

---

## Tech Debt Summary

**New items this scan**: [N]
**Total active debt**: [M] (from tech-debt-tracker.md if it exists)

### Top Priority Items
1. [Highest severity finding with location and action]
2. [Second highest]
3. [Third highest]
```

---

## Step 5: Update Tech Debt Tracker

If `$REPO_ROOT/docs/exec-plans/tech-debt-tracker.md` exists:
- Append new HIGH and MEDIUM severity findings as rows in the Active Items table
- Use format: `| TD-[NNN] | [Category] | [high/medium] | [Description] | [File(s)] | [Recommended fix] | [S/M/L] | Open |`
- Categories: Code Quality, Architecture, Documentation, Testing, Dependencies
- Do NOT duplicate items already in the tracker (match by affected files + description)
- Update "Last Scanned" section with today's date

If the file does not exist:
- Note: "Tech debt tracker not found. Run `init-bmad --upgrade` to add it, or create `docs/exec-plans/tech-debt-tracker.md`."

---

## Step 6: Offer Next Steps

```markdown
## Next Steps

Options:
- [F] Create fix stories for top findings
- [S] Run /simplify on flagged files
- [R] Re-run with full scoring (/maintain)
- [D] Done — no action needed

Choice: _
```

If user selects [F]:
- For each top-priority finding, draft a story outline:
  ```
  Story: Fix [description]
  Goal: [what needs to change]
  Files: [affected files]
  Effort: S
  ```
- Ask user which to create as full stories

---

## Recurring Usage

This command can be run:
- **Manually**: `/maintain` any time
- **On a schedule**: `/loop 1w /maintain` for weekly scans
- **Before planning**: Run before sprint planning to inform priorities
- **After major changes**: Run after implementing an epic to catch drift

---

## Examples

```bash
# Full maintenance scan
/maintain

# Skip quality scoring for faster results
/maintain --skip-score
```

---

Begin maintenance scan for: **$ARGUMENTS**
