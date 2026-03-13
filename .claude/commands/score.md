---
allowed-tools: Bash(wc:*), Bash(find:*), Bash(git log:*), Read, Glob, Grep, Edit
argument-hint: [domain-name]
description: Evaluate per-domain quality scores against QUALITY_SCORE.md criteria. Tracks trends over time.
---

# Score Command — Per-Domain Quality Grading

**Trigger**: `/score $ARGUMENTS`

Evaluate codebase quality against the scoring criteria in `docs/QUALITY_SCORE.md` and update domain scores.

---

## Step 1: Locate Quality Score File

```bash
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
```

Look for `docs/QUALITY_SCORE.md` at `$REPO_ROOT/docs/QUALITY_SCORE.md`.

If not found:
```
No QUALITY_SCORE.md found in docs/.
Run `init-bmad` or copy from .claude/bmad-template/docs/QUALITY_SCORE.md to get started.
```

---

## Step 2: Identify Domains

If `$ARGUMENTS` specifies a domain name, score only that domain.

Otherwise, auto-detect domains by scanning the project structure:
- Top-level source directories (e.g., `src/auth/`, `src/api/`, `app/models/`)
- Major module boundaries based on the project's language and framework
- Existing domain rows in QUALITY_SCORE.md

List the domains found and confirm with user:
```
Detected domains: auth, api, data, ui
Score all domains? [Y/n/select]
```

---

## Step 3: Evaluate Each Domain

For each domain, evaluate against the 7 scoring criteria:

### 3.1 Test Coverage (20%)
- Count test files targeting this domain
- If coverage tool is configured, run it: `pytest --cov=<domain> --cov-report=term-missing`
- Score: 100 if >80% coverage, 75 if 60-80%, 50 if 40-60%, 25 if <40%

### 3.2 Lint Cleanliness (15%)
- Run configured lint command scoped to domain files
- Score: 100 if zero warnings, -10 per warning (floor 0)

### 3.3 File Size Discipline (15%)
- Count source files in domain exceeding 300 lines (or configured limit)
- Score: 100 if none over limit, -20 per oversized file (floor 0)

### 3.4 Documentation Coverage (15%)
- Scan public functions/classes for docstrings (Python) or JSDoc (JS/TS)
- Score: percentage of public interfaces documented

### 3.5 Dependency Hygiene (15%)
- Check for circular imports within the domain
- Check that imports respect layer boundaries (if defined in ARCHITECTURE.md)
- Score: 100 if clean, -25 per violation (floor 0)

### 3.6 Error Handling (10%)
- Spot-check: bare `except:` blocks, swallowed errors, missing error boundaries
- Score: 100 if clean, -20 per issue (floor 0)

### 3.7 Code Freshness (10%)
- Count stale TODOs (>30 days old based on git blame)
- Count commented-out code blocks (>5 lines)
- Score: 100 if clean, -15 per stale item (floor 0)

### Calculate Domain Score
```
domain_score = sum(criterion_score * criterion_weight for each criterion)
domain_grade = map_to_grade(domain_score)  # A/B/C/D/F scale
```

---

## Step 4: Compare with Previous Scores

Read existing domain scores from QUALITY_SCORE.md.

For each domain:
- Calculate delta from last recorded score
- Determine trend: ↑ (improved >2pts), → (stable ±2pts), ↓ (declined >2pts)
- Flag regressions (↓) prominently

---

## Step 5: Display Results

```markdown
## Quality Score Report — [DATE]

| Domain | Grade | Score | Prev | Δ | Trend | Top Issue |
|--------|-------|-------|------|---|-------|-----------|
| auth   | B+    | 85    | 80   | +5 | ↑   | 2 files over 300 lines |
| api    | A-    | 90    | 91   | -1 | →   | — |
| data   | C     | 65    | 70   | -5 | ↓   | Low test coverage (35%) |

**Overall**: B (78) — Previous: B (80) — Trend: →

### Regressions Flagged
- **data**: Score dropped 5 points. Test coverage declined — 2 new modules lack tests.

### Improvement Priorities
1. **data** (C → B): Add tests for cache and transform modules
2. **auth** (B+ → A): Document remaining 3 public APIs
```

---

## Step 6: Update QUALITY_SCORE.md

Update the file with new scores:

1. **Domain Scores table**: Update grade, score, trend, last updated, notes for each domain
2. **Score History table**: Append a new row with today's date, overall score, top improvement, top regression
3. **Improvement Priorities table**: Update based on current lowest-scoring domains

Use the Edit tool to make targeted updates to each section.

---

## Step 7: Summary

```
Quality scoring complete.
- Domains scored: [N]
- Overall: [GRADE] ([SCORE])
- Regressions: [N] domains declined
- QUALITY_SCORE.md updated with latest scores.
```
