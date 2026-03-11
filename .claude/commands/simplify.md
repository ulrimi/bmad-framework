# Simplify Command - Code Complexity Reduction

**Trigger**: `/simplify $ARGUMENTS`

Analyze and simplify code for: **$ARGUMENTS**

This command reviews code for over-engineering and applies the Boy Scout Rule: leave code cleaner than you found it.

---

## Argument Parsing

| Input Pattern | Mode | Action |
|---------------|------|--------|
| (no args) | Recent Changes | Simplify uncommitted changes (`git diff`) |
| `path/to/file.py` | Single File | Analyze and simplify one file |
| `path/to/directory/` | Directory | Analyze all files in directory |
| `--staged` | Staged Changes | Simplify staged changes only |
| `--last-commit` | Last Commit | Simplify files from last commit |
| `--deep` | Deep Analysis | More aggressive simplification suggestions |

---

## Phase 1: Scope Detection

```yaml
1.1 Determine Target Files:

    If no arguments:
      # Get uncommitted changes
      files = $(git diff --name-only HEAD)
      if empty:
        files = $(git diff --name-only --staged)
      if still empty:
        Ask: "No changes detected. Specify files or directory to simplify."

    If path argument:
      if is_file(path):
        files = [path]
      if is_directory(path):
        files = glob(path/**/*.{py,ts,tsx,js,jsx})

    If --staged:
      files = $(git diff --name-only --staged)

    If --last-commit:
      files = $(git diff --name-only HEAD~1)

1.2 Filter to Code Files:
    Keep only: .py, .ts, .tsx, .js, .jsx, .go, .rs
    Exclude: tests/, __pycache__/, node_modules/, .git/

1.3 Display Scope:
    "Analyzing [N] files for simplification opportunities..."

    | File | Lines | Last Modified |
    |------|-------|---------------|
    | path/to/file1.py | 245 | 2 hours ago |
    | path/to/file2.ts | 189 | 5 hours ago |
```

---

## Phase 2: Complexity Analysis

```yaml
2.1 Read Target Files:
    For each file in scope:
    - Read full content
    - Count lines, functions, classes
    - Note import count

2.2 Sequential Thinking Analysis:

    mcp__sequential-thinking__sequentialthinking:
      thought: |
        Analyzing code for over-engineering patterns.

        CLAUDE.md Simplification Rules:
        1. SINGLE-USE ABSTRACTIONS: Helpers, utilities, or wrappers used only once
        2. PREMATURE ABSTRACTIONS: "Rule of Three" violations (abstracted before 3 uses)
        3. LONG FUNCTIONS: Functions >50 lines that should be split
        4. DEAD CODE: Unused imports, variables, functions, or commented code
        5. OVER-HANDLING: Error handling for impossible scenarios
        6. BACKWARDS-COMPAT HACKS: Unused _vars, re-exports, "# removed" comments
        7. OBVIOUS COMMENTS: Comments explaining self-evident code
        8. FEATURE CREEP: Configurability or features beyond what was asked

        File: [FILENAME]
        Content analysis:
        [ANALYZE EACH PATTERN]
      totalThoughts: 8
      nextThoughtNeeded: true

2.3 Build Findings List:
    For each issue found:
    - File path and line numbers
    - Issue category (from list above)
    - Severity: LOW (style) | MEDIUM (cleanup) | HIGH (significant bloat)
    - Suggested action
    - Code snippet (before)
    - Proposed change (after)
```

---

## Phase 3: Present Findings

```yaml
3.1 Summary Table:

    ## Simplification Analysis Complete

    **Files analyzed**: [N]
    **Issues found**: [M]

    | # | File:Line | Issue | Severity | Action |
    |---|-----------|-------|----------|--------|
    | 1 | service.py:45-67 | Single-use helper | MEDIUM | Inline function |
    | 2 | router.py:23 | Unused import | LOW | Remove |
    | 3 | models.py:89-156 | 67-line function | HIGH | Split into 3 |
    | 4 | utils.py:12-34 | Dead code block | MEDIUM | Delete |

3.2 Detail View (for HIGH severity):

    ### Issue #3: Long Function (HIGH)

    **Location**: `models.py:89-156`
    **Problem**: Function `process_data` is 67 lines, violates <50 line rule

    **Current structure**:
    ```python
    def process_data(input):
        # validation (15 lines)
        # transformation (25 lines)
        # persistence (20 lines)
        # notification (7 lines)
    ```

    **Proposed split**:
    ```python
    def process_data(input):
        validated = _validate_input(input)
        transformed = _transform_data(validated)
        result = _persist_data(transformed)
        _notify_completion(result)
        return result
    ```

3.3 User Decision:

    Options:
    [A] Apply all simplifications
    [S] Select which to apply (interactive)
    [V] View details for specific issue (#)
    [N] Cancel - make no changes
    [E] Export findings to file

    Choice: _
```

---

## Phase 4: Apply Simplifications

```yaml
4.1 For Each Approved Change:

    TodoWrite:
      - content: "Simplify [file]:[issue]"
        status: in_progress

    a) Read current file state
    b) Apply the specific change
    c) Verify syntax (no parse errors)
    d) Mark todo complete

4.2 Track Changes:

    changes_made = []
    for each simplification:
      changes_made.append({
        file: path,
        issue: description,
        lines_removed: N,
        lines_added: M
      })

4.3 Handle Conflicts:
    If a change would conflict with another:
    - Show conflict
    - Ask user which to apply
    - Or skip both
```

---

## Phase 5: Validation

```yaml
5.1 Syntax Check:
    For each modified file:

    Python:
      python -m py_compile [file]

    TypeScript:
      pnpm exec tsc --noEmit [file]

5.2 Linting:
    Python:
      cd server && ruff check [files] && ruff format --check [files]

    TypeScript:
      cd web && pnpm lint

5.3 Quick Test (if available):
    If tests exist for modified files:
      pytest [related_tests] -x -q

    If any fail:
      "Tests failing after simplification. Revert changes? [Y/n]"
      If revert: git checkout -- [files]

5.4 If Validation Fails:
    Show which check failed
    Offer to:
    [R] Revert all changes
    [P] Revert problematic file only
    [I] Ignore and keep changes
```

---

## Phase 6: Summary

```yaml
6.1 Changes Applied:

    ## Simplification Complete

    ### Changes Made
    | File | Change | Lines | Net |
    |------|--------|-------|-----|
    | service.py | Inlined helper | -12, +4 | -8 |
    | router.py | Removed unused import | -1 | -1 |
    | models.py | Split long function | -67, +45 | -22 |

    **Total**: -31 lines of code

    ### Validation
    - [x] Syntax check passed
    - [x] Linting passed
    - [x] Tests passed

6.2 Commit Suggestion:

    Changes are unstaged. To commit:

    ```bash
    git add [files]
    git commit -m "refactor: simplify code (-31 lines)

    - Inline single-use helper in service.py
    - Remove unused imports
    - Split 67-line function in models.py

    Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>"
    ```

6.3 Export Option:

    Save findings to file? [Y/n]

    If yes: Write to `.claude/simplify-report-[date].md`
```

---

## Deep Mode (--deep)

When `--deep` flag is passed, also check for:

```yaml
Additional Patterns:
  - Overly defensive null checks (when type system guarantees non-null)
  - Redundant type assertions
  - Unnecessary async/await (sync operations wrapped in async)
  - Over-abstracted class hierarchies
  - Dependency injection where direct import works
  - Configuration for things that never change
  - Logging that's never used for debugging
  - Metrics that aren't monitored
```

---

## Examples

```bash
# Simplify uncommitted changes
/simplify

# Simplify a specific file
/simplify server/app/services/notary.py

# Simplify entire directory
/simplify server/app/routers/

# Simplify staged changes before commit
/simplify --staged

# Simplify last commit (for post-commit cleanup)
/simplify --last-commit

# Deep analysis with more aggressive suggestions
/simplify --deep server/app/
```

---

## Integration Notes

- This command can be run standalone or invoked from `/implement` Phase 6.5
- Findings are non-destructive until user approves
- Always validates after changes
- Respects `.gitignore` patterns
- Works with both Python and TypeScript codebases

---

Begin simplification analysis for: **$ARGUMENTS**
