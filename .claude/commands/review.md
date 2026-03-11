---
allowed-tools: Bash(git diff:*), Bash(git status:*), Bash(git log:*), Bash(git show:*), Bash(wc:*), Bash(npx repomix:*), Read, Glob, Grep
argument-hint: [quick|standard|deep|auto]
description: Code review with auto-detected depth. Analyzes git changes and applies appropriate review rigor based on risk and size.
---

# Code Review Command

You are performing a comprehensive code review. Follow these steps precisely.

---

## Step 1: Gather Git Context

Run these commands to understand the current changes:

```bash
# Get list of changed files (vs main branch or last commit)
git diff --name-only HEAD~1 2>/dev/null || git diff --name-only main...HEAD

# Get change statistics
git diff --stat HEAD~1 2>/dev/null | tail -5 || git diff --stat main...HEAD | tail -5

# Get file count and line count
git diff --numstat HEAD~1 2>/dev/null || git diff --numstat main...HEAD
```

---

## Step 2: Determine Review Tier

Based on the argument "$ARGUMENTS" or auto-detection:

### If explicit tier provided:
- `quick` → Use **Quick Review** (style/lint only)
- `standard` → Use **Standard Review** (logic/quality)
- `deep` → Use **Deep Review** (security/architecture audit)
- `auto` or empty → Auto-detect based on rules below

### Auto-Detection Logic:

```
1. CHECK RISKY PATHS (triggers Deep):
   - chain/           → Blockchain integration
   - auth             → Authentication (matches auth.py, routers/auth/, etc.)
   - billing/         → Payment processing
   - migrations/      → Database schema changes
   - security         → Security utilities
   - routers/v1/auth  → Auth API endpoints
   - services/auth    → Auth business logic
   - middleware/auth  → Auth middleware

2. CHECK DOCS ONLY:
   - If ALL files are .md, .txt, .json, .yaml → SKIP review
   - Output: "No code review needed - documentation only changes."

3. CHECK SIZE:
   - >20 files OR >500 lines → Standard Review
   - ≤5 files AND ≤200 lines → Quick Review
   - Default → Standard Review
```

---

## Step 3: Gather Context Based on Tier

### For Quick Review:
- Read `CLAUDE.md` from project root
- Get the git diff only

### For Standard Review:
- Read `CLAUDE.md` from project root
- Read full contents of each changed file
- Get the git diff

### For Deep Review:
- Generate filtered repo context:
```bash
npx repomix --style xml --output /tmp/review-context.xml \
  --ignore "**/*.lock,**/package-lock.json,node_modules/,dist/,venv/,**/.git/,**/*.svg,**/*.png,**/*.ico,**/*.woff*,coverage/,htmlcov/,*.pyc,__pycache__/,**/*.md" \
  --include "server/app/**/*.py,web/src/**/*.ts,web/src/**/*.tsx,CLAUDE.md"
```
- Read the generated context file
- Get the git diff

---

## Step 4: Perform Review

### GROUNDING RULES (CRITICAL - NON-NEGOTIABLE)

1. **Evidence-Based Only**: ONLY flag issues you can point to with specific `file:line` references in the diff
2. **Empty State Valid**: "None identified" is a VALID and expected output for any section - do NOT invent issues to fill sections
3. **No Speculation**: Do NOT suggest issues that MIGHT exist elsewhere in the codebase
4. **Confidence Prefixes**: For uncertain findings, prefix with:
   - "Definite:" - Clear bug or violation visible in diff
   - "Likely:" - Strong evidence but needs verification
   - "Possible:" - Worth checking but uncertain

### SEVERITY DEFINITIONS

- **CRITICAL**: Blocks merge. Security vulnerability, data loss risk, breaks production.
- **HIGH**: Should fix before merge. Logic errors, missing validation, test gaps.
- **MEDIUM**: Tech debt. Should address soon. Style violations, missing docs, complexity.
- **NIT**: Optional polish. Naming, minor style, suggestions for future.

---

## Step 5: Output Format

### Quick Review Output

```markdown
## Quick Review

**Tier**: quick | **Files**: N | **Lines**: N

### Issues Found
- `file:line` - Description (or "None identified")

### Summary
- 1-2 bullet points
- **Verdict**: LGTM or NEEDS_FIXES
```

### Standard Review Output

```markdown
## Standard Review

**Tier**: standard | **Files**: N | **Lines**: N

### CRITICAL Issues
- `file:line` - Problem → Fix (or "None identified")

### HIGH Priority
- `file:line` - Issue → Suggestion (or "None identified")

### MEDIUM / Tech Debt
- `file:line` - Issue (or "None identified")

### NITs
- `file:line` - Minor improvement (or "None identified")

### Verdict
**[APPROVE | REQUEST_CHANGES]** - Rationale
```

### Deep Review Output

```markdown
## Principal Engineer Review

**Tier**: deep | **Files**: N | **Lines**: N

### Security Assessment
[OWASP check, auth validation, input sanitization - or "No vulnerabilities identified"]

### Architecture Impact
[Structural assessment, coupling, SOLID principles - or "No architectural concerns"]

### CRITICAL Issues (Blockers)
- **File**: `filename.py:line`
- **Severity**: CRITICAL
- **Problem**: Description
- **Fix**: Code snippet or guidance

### HIGH Priority (Should Fix)
- `file:line` - Issue → Suggestion (or "None identified")

### MEDIUM / Tech Debt
- `file:line` - Issue (or "None identified")

### NITs & Polish
- `file:line` - Minor improvement (or "None identified")

### Compliance Check
| Rule | Status |
|------|--------|
| Type syntax (X \| None not Optional) | Pass/Fail |
| Async hygiene (no blocking I/O) | Pass/Fail |
| Docstrings on public functions | Pass/Fail |
| No secrets in code | Pass/Fail |

### Verdict
**[APPROVE | REQUEST_CHANGES]** - Rationale
```

---

## Anti-Hallucination Checklist

Before finalizing your review, verify:
- [ ] Every issue references a specific line in the provided diff
- [ ] You have NOT invented issues to make sections look complete
- [ ] You have NOT assumed bugs in code not shown in the diff
- [ ] Empty sections say "None identified" (this is acceptable!)
