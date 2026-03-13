# Implement Command - Story-Driven Development Execution

**Trigger**: `/implement $ARGUMENTS`

Execute full implementation for: **$ARGUMENTS**

This command implements stories until completion. It handles epics (all stories), single stories, or multiple stories passed as arguments.

---

## Step 0: Establish Repository Root (MANDATORY — RUN FIRST, NO EXCEPTIONS)

**YOU MUST RUN THIS BASH COMMAND BEFORE ANYTHING ELSE. Do not search, glob, or read any files until this command has been executed and you have verified the output.**

```bash
# === MANDATORY STEP 0: Run this FIRST ===
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd) && \
echo "=== REPO_ROOT: $REPO_ROOT ===" && \
echo "=== Branch: $(git branch --show-current) ===" && \
echo "=== Worktree: $(if [ "$(git rev-parse --git-common-dir 2>/dev/null)" != "$(git rev-parse --git-dir 2>/dev/null)" ]; then echo "YES"; else echo "NO (main repo)"; fi) ===" && \
echo "=== Available epics ===" && \
ls "$REPO_ROOT/bmad/epics/" 2>/dev/null || echo "ERROR: No bmad/epics/ directory at $REPO_ROOT"
```

**After running, verify:**
1. `REPO_ROOT` points to the correct repository (not a different project)
2. The epic from `$ARGUMENTS` appears in the "Available epics" list
3. If the epic is NOT listed, tell the user immediately — do NOT search elsewhere

**All subsequent paths use `$REPO_ROOT` as prefix:**
- Epic paths: `$REPO_ROOT/bmad/epics/[epic-name]/`
- Story paths: `$REPO_ROOT/bmad/epics/[epic-name]/stories/`
- Source paths: `$REPO_ROOT/src/`, `$REPO_ROOT/tests/`, etc.
- Specialists: `$REPO_ROOT/bmad/qf-bmad/agents/active/`

**If in main repo (not worktree) and implementing a full epic**, warn:
```
Warning: You're in the main repository, not an isolated worktree.
Consider: /feature $EPIC_NAME first, then /implement $EPIC_NAME
Continue in main repo? [Y/n]
```

---

## Argument Parsing

Parse `$ARGUMENTS` to determine work scope. Resolution is tried **in order** — first match wins.

### Resolution Order (CRITICAL — follow this exact sequence)

For each argument, try these checks in order:

**Check 1: Direct file path to epic-overview.md**
- If arg ends with `epic-overview.md` and the file exists → **Epic Mode**
- Example: `bmad/epics/data-layer/epic-overview.md`

**Check 2: Direct directory path to an epic**
- If arg is a directory path AND it contains `epic-overview.md` → **Epic Mode**
- Use Glob to check: `$REPO_ROOT/{arg}/epic-overview.md`
- Examples: `bmad/epics/data-layer`, `bmad/epics/project-scaffold`
- This handles both relative and absolute paths

**Check 3: Direct file path to a story**
- If arg ends with `.md` and the file exists at `$REPO_ROOT/{arg}` → **Story Mode**
- Example: `bmad/epics/data-layer/stories/story-dl-001-exchange-calendar.md`

**Check 4: Epic name shorthand (no slashes or single segment)**
- If arg has no `/` → search for epic directory matching the name
- Use Glob: `$REPO_ROOT/bmad/epics/{arg}/epic-overview.md`
- If exactly one match → **Epic Mode** using that directory
- If no match → error with list of available epics from `$REPO_ROOT/bmad/epics/`
- Example: `data-layer` → finds `$REPO_ROOT/bmad/epics/data-layer/`

**Check 5: Epic/story shorthand (one slash)**
- If arg has exactly one `/` → split into `{epic-part}/{story-part}`
- Search: `$REPO_ROOT/bmad/epics/{epic-part}/stories/*{story-part}*.md`
- If exactly one match → **Story Mode**
- If multiple matches → show matches and ask user to pick
- If no match → error with available stories in that epic
- Example: `data-layer/parquet-store` → finds `story-dl-002-parquet-store.md`

**Check 6: Multiple story files**
- If multiple args each ending in `.md` → **Multi-Story Mode**
- Resolve each story file and queue in order given

**If none match**: Show error with the argument that failed and list available epics:
```bash
# List what's actually in this repo
ls "$REPO_ROOT/bmad/epics/"
```
```
Epic not found: [arg]

Available epics in $REPO_ROOT/bmad/epics/:
  - [list actual directories found]

Usage: /implement <epic-name> or /implement <path/to/epic-or-story>
```

### Step 1: Build the Story Queue

```python
# Pseudocode for queue building
story_queue = []

for arg in ARGUMENTS:
    epic_dir = resolve_epic_or_story(arg)  # Uses resolution order above

    if mode == EPIC_MODE:
        # Queue all incomplete stories from epic directory
        stories = glob(f"{epic_dir}/stories/story-*.md")
        for story in sorted(stories):
            if story.status not in ['Complete', 'Archived']:
                story_queue.append(story)
    elif mode == STORY_MODE:
        # Queue the specific story
        story_queue.append(resolved_story_path)

# Validate queue
if not story_queue:
    error("No incomplete stories found")
```

### Step 2: Display Work Plan

Before starting, show the user what will be implemented:

```markdown
## Implementation Queue

| # | Story | Status | Specialist |
|---|-------|--------|------------|
| 1 | story-001-db-models.md | Ready | backend-specialist |
| 2 | story-002-api-endpoints.md | Ready | backend-specialist |
| 3 | story-003-ui-updates.md | Blocked (needs 001, 002) | frontend-specialist |

**Estimated scope**: 3 stories, ~X files
**Branch**: feature/[epic-name]

Proceed with implementation? [Y/n]
```

---

## Story Implementation Protocol

For EACH story in the queue, execute this complete cycle:

### Phase Overview

| Phase | Name | Mandatory | Description |
|-------|------|-----------|-------------|
| 1 | Context Loading | ✅ | Read story, verify prerequisites, load specialist |
| 2 | Exploration | ✅ | Scan codebase, identify change scope |
| 3 | Implementation Planning | ✅ | Sequence changes, get user approval |
| 4 | Implementation Execution | ✅ | Write code file by file with todo tracking |
| 5 | Testing | ✅ | Run existing tests, write new tests |
| 6 | Validation & Linting | ✅ | Lint, type check, verify acceptance criteria |
| 6.5 | Structural Validation | Configurable | Run project-specific structural checks (dependency direction, naming, file size) |
| **7** | **Code Simplification** | **✅ MANDATORY** | **Review for over-engineering, apply Boy Scout Rule** |
| **8** | **Self-Review + Multi-Agent Review** | **✅ MANDATORY** | **Self-review + specialist domain reviews with escalation** |
| 9 | Commit | ✅ | Stage, commit with gate check for Phases 7 & 8 |
| 10 | Story Completion | ✅ | Update story file with completion notes |
| **11** | **Push & Create PR** | **✅ AUTO** | **Push branch, create GitHub PR (runs after ALL stories complete)** |

---

### Phase 1: Context Loading (2 min)

```yaml
1.1 Read Story File:
    - Load full story content
    - Extract: Goal, Acceptance Criteria, Technical Context, Testing Requirements
    - Identify: Touched files, dependencies, blocked-by stories

1.2 Verify Prerequisites:
    - Check if blocked-by stories are complete
    - If blocked: skip and move to next story, or ask user

1.3 Load Specialist Persona:
    - Match story domain to specialist file in bmad/qf-bmad/agents/active/
    - Read specialist .md and adopt expertise
    - Match based on story keywords and specialist domain descriptions
```

### Phase 2: Exploration (3-5 min)

```yaml
2.1 Quick Codebase Scan:
    subagent_type: Explore
    thoroughness: quick
    prompt: |
      Exploration for implementing: [STORY TITLE]

      Files mentioned in story: [LIST FROM TECHNICAL CONTEXT]

      Find:
      1. Current state of each file to be modified
      2. Patterns used in similar existing code
      3. Related tests that exist
      4. Import dependencies

      Output: File inventory with current line counts and key functions

2.2 Identify Change Scope:
    - List files to CREATE (new)
    - List files to MODIFY (existing)
    - List files to DELETE (if any)
    - List tests to CREATE or MODIFY
```

### Phase 3: Implementation Planning (2 min)

```yaml
3.1 Sequence Changes:
    Create ordered list of changes with rationale:

    1. [file1.py] - Add model class (foundation for others)
    2. [file2.py] - Add service functions (uses model)
    3. [file3.py] - Add router endpoints (uses service)
    4. [test_file.py] - Add tests (validates all above)

3.2 Show User the Plan:
    "I will make these changes in order:
     1. Modify models.py - Add new data model
     2. Modify service.py - Add business logic
     3. Modify router.py - Add API endpoint
     4. Create tests/test_feature.py - 5 test cases

     Proceed? [Y/n/modify]"
```

### Phase 4: Implementation Execution

**CRITICAL**: Use TodoWrite to track each file. Mark complete as you go.

```yaml
4.1 For Each File in Sequence:

    a) Pre-Implementation:
       - Read current file (if modifying)
       - Identify exact insertion points
       - Review patterns to follow

    b) Write Code:
       - Follow specialist patterns
       - Follow CLAUDE.md style mandates:
         * Python: X | None syntax, Google docstrings
         * TypeScript: strict mode, functional components
       - Keep changes minimal and focused
       - Include error handling
       - Add logging where appropriate

    c) Post-Implementation:
       - Verify file is syntactically valid
       - Check imports are correct
       - Mark todo item complete

4.2 Implementation Rules:
    - ONE file at a time (no parallel file edits)
    - Commit logical units (not every file)
    - If stuck > 5 min on a file, ask user for guidance
    - Never leave files in broken state
```

### Phase 5: Testing

```yaml
5.1 Run Existing Tests (ensure no regression):
    Use the test command from CLAUDE.md. Use Bash timeout=180000.
    If failures: FIX THEM before proceeding.
    If Bash times out: run only the test files relevant to your changes.

    TIMEOUT CAVEAT (prevents test-loop time sink):
    If the output shows tests running with 0 failures and only pass/skip
    results, ACCEPT THAT AS A PASS even if the summary line is cut off.
    Do NOT re-run tests just to "get the summary line".

5.2 Write New Tests (per story requirements):
    - Unit tests for new functions
    - Integration tests for new endpoints
    - Follow existing test patterns in tests/

5.3 Run New Tests:
    ```bash
    pytest tests/test_[new].py -v
    ```
    If failures: FIX THEM before proceeding

5.4 Coverage Check (if specified in story):
    ```bash
    pytest --cov=app/[module] tests/
    ```
```

### Phase 6: Validation & Linting

```yaml
6.1 Linting:
    Run the lint and format-check commands from CLAUDE.md.
    If failures: auto-fix where possible, manual edits otherwise.

6.2 Acceptance Criteria Verification:
    Go through EACH acceptance criterion in the story:

    - [ ] AC1: [description] - VERIFIED by [how]
    - [ ] AC2: [description] - VERIFIED by [how]
    - [ ] AC3: [description] - VERIFIED by [how]

    If ANY AC is not met: implement missing functionality
```

### Phase 6.5: Structural Validation (Configurable)

**Purpose**: Enforce architectural invariants mechanically — catch code that works but violates structural boundaries.

> This phase runs only when `structural_validation.enabled: true` in the project's `core-config.yaml`.
> If not configured, it logs a skip message and proceeds to Phase 7.

```yaml
6.5.1 Check Configuration:
    Read core-config.yaml and look for structural_validation section.

    If structural_validation.enabled is false or missing:
      Log: "No structural validation configured — skipping Phase 6.5"
      Proceed to Phase 7.

6.5.2 Run Configured Checks:
    For each entry in structural_validation.checks:
      ```bash
      # Run the configured check command
      $CHECK_COMMAND
      ```
      - If check passes: log success, continue to next check
      - If check fails: proceed to 6.5.3

6.5.3 Fix-Retry Loop (max 3 cycles per check):
    For each failed check:
      a) Read the error output (check scripts should include remediation hints)
      b) Attempt to fix the violation
      c) Re-run the failed check
      d) If fixed: log fix and continue
      e) If still failing after 3 cycles:
         - If the violation requires architectural discussion → flag for human review
         - Ask: "Structural check '[name]' failing after 3 fix attempts.
                 [S]kip check, [A]sk for help, [Q]uit"

6.5.4 Log Results:
    Record in story completion notes:

    ### Structural Validation Results
    - Checks configured: [N]
    - Checks passed: [X]
    - Checks fixed: [Y] (with retry)
    - Checks skipped: [Z]
```

### Phase 7: Code Simplification (MANDATORY)

**Purpose**: Apply the Boy Scout Rule - leave code cleaner than you found it.

> **CRITICAL**: This phase runs on EVERY implementation. It is NOT optional.
> Only skip if user explicitly passes `--no-simplify` flag.

```yaml
7.1 Complexity Scan:
    Use sequential thinking to review ALL changes made in this story:

    mcp__sequential-thinking__sequentialthinking:
      thought: |
        MANDATORY SIMPLIFICATION REVIEW

        Files changed in this implementation: [LIST ALL FILES]

        Checking against CLAUDE.md simplification rules:
        1. SINGLE-USE ABSTRACTIONS: Are there helpers/utilities used only once?
        2. PREMATURE ABSTRACTIONS: Anything abstracted before 3 uses?
        3. LONG FUNCTIONS: Any functions >50 lines?
        4. DEAD CODE: Unused imports, variables, or commented code?
        5. OVER-HANDLING: Error handling for impossible scenarios?
        6. BACKWARDS-COMPAT HACKS: Unused _vars, re-exports, "# removed" comments?
        7. OBVIOUS COMMENTS: Comments explaining self-evident code?
        8. FEATURE CREEP: Configurability beyond what was asked?

        For each file, analyze systematically...
      totalThoughts: 6
      nextThoughtNeeded: true

7.2 Report Findings:
    ALWAYS produce a simplification report, even if empty:

    ## Simplification Analysis

    **Files reviewed**: [N]
    **Issues found**: [M]

    If M == 0:
      "✅ No simplification opportunities found. Code is clean."

    If M > 0:
      | # | File:Line | Issue | Severity | Action |
      |---|-----------|-------|----------|--------|
      | 1 | service.py:45 | Single-use helper | MEDIUM | Inline |
      | 2 | router.py:23-89 | 66-line function | HIGH | Split into 2 |
      | 3 | models.py:12 | Unused import | LOW | Remove |

      Apply simplifications? [Y/n/select]

7.3 Apply Approved Simplifications:
    For each approved simplification:

    TodoWrite:
      - content: "Simplify [file]: [issue]"
        status: in_progress

    a) Read current file state
    b) Apply the specific change
    c) Verify syntax is valid (python -m py_compile / tsc --noEmit)
    d) Mark todo complete

7.4 Re-Validate After Simplification:
    MUST re-run validation after ANY simplification changes:

    # Re-run tests (use Bash timeout=180000)
    # Apply same TIMEOUT CAVEAT from Phase 5.1

    # Re-run linting (use lint commands from CLAUDE.md)

    If failures:
      - Identify which simplification broke things
      - Revert that specific change
      - Continue with remaining changes
      - Proceed to commit

7.5 Log Simplification Outcome:
    Record in story completion notes:

    ### Simplification Results
    - Files reviewed: [N]
    - Issues found: [M]
    - Issues fixed: [X]
    - Lines removed: [Y]
```

**IMPORTANT**: Never skip this phase silently. If skipping due to `--no-simplify`, explicitly log: "Simplification skipped per --no-simplify flag."

### Phase 8: Self-Review + Multi-Agent Review (MANDATORY)

**Purpose**: Run `/review` on your own changes, then route reviews to domain-specialist agents for deeper analysis. Fix meaningful issues before committing.

> **CRITICAL**: This phase runs on EVERY implementation. It is NOT optional.
> Multi-agent review runs when specialist agents are available in `bmad/qf-bmad/agents/active/`.

```yaml
8.1 Run /review on Uncommitted Changes:
    Execute the /review command against the current uncommitted diff.
    This performs a structured code review covering:
    - Correctness and logic errors
    - Security issues (injection, secrets, input validation)
    - Performance concerns
    - Style and consistency with CLAUDE.md conventions
    - Test coverage gaps

8.2 Process Self-Review Findings:
    Automatically fix medium-severity and above. Nits are informational only.

    | Priority | Action |
    |----------|--------|
    | Critical (bugs, security) | Fix immediately |
    | High (correctness, performance) | Fix immediately |
    | Medium (improvements, consistency) | Fix |
    | Nits (style, naming, minor) | Skip — log but do not fix |

8.3 Apply Self-Review Fixes:
    For each medium+ finding:
    a) Read the affected file
    b) Apply the fix
    c) If the fix is ambiguous, use best judgment aligned with CLAUDE.md style

    Do NOT fix nits — they add churn without meaningful value.

8.4 Multi-Agent Review — Determine Specialist Domains:
    Analyze which files were changed and map to specialist agents:

    a) List all files modified in this story implementation
    b) Match file paths/modules to specialist domains:
       - auth, security, crypto files → security-perspective review
       - API routes, endpoints → backend-specialist review
       - UI components, templates → frontend-specialist review
       - Database, data layer, caching → data-specialist review
       - Infrastructure, CI/CD, deploy → infra-specialist review
       - Tests, fixtures, QA → qa-specialist review
    c) Load matching specialist agent files from bmad/qf-bmad/agents/active/

    If no specialist agents exist in the project:
      Log: "No specialist agents configured — skipping multi-agent review"
      Proceed to 8.7

8.5 Multi-Agent Review — Specialist Reviews:
    For each relevant specialist:

    a) Spawn a review subagent (Agent tool) with the specialist persona loaded
    b) Provide the subagent with:
       - The diff of all changes
       - The story's acceptance criteria
       - Instruction: "Review from [specialist] perspective. Output findings
         with severity (critical/high/medium/nit) and specialist attribution."
    c) Collect findings with specialist attribution:
       - Format: "[Specialist] Finding description" (e.g., "[Security] API key exposed in error response")

    Run specialist reviews in parallel where possible.

8.6 Multi-Agent Review — Merge and Address Findings:
    a) Merge all specialist findings with self-review findings
    b) Deduplicate (same issue found by multiple reviewers)
    c) Sort by severity (critical → high → medium → nit)
    d) Address medium+ findings (apply fixes)
    e) If >10 lines changed in fixes, re-run specialist reviews (max 3 cycles)

    Escalation Rules — flag for human review instead of resolving autonomously:
    - Conflicting guidance between specialists (e.g., security says add validation,
      performance says remove it)
    - Architectural boundary violation that needs design discussion
    - Security-critical finding with unclear remediation
    - Any finding where the correct fix is ambiguous across domains

    If escalation triggered:
      "⚠️ Escalation: [description]. Requires human judgment.
       [C]ontinue with best guess, [A]sk for guidance, [S]kip this finding"

8.7 Re-Validate After All Fixes:
    MUST re-run tests and linting after any review fixes:

    # Re-run tests (use Bash timeout=180000)
    # Re-run linting (use lint commands from CLAUDE.md)

    If failures:
      - Identify which fix broke things
      - Adjust the fix to maintain correctness
      - Re-validate until green

8.8 Log Review Outcome:
    Record in story completion notes:

    ### Self-Review Results
    - Findings: [N] total ([X] critical/high, [Y] medium, [Z] nits)
    - Fixed: [N] (medium+)
    - Skipped: [N] nits

    ### Multi-Agent Review Results
    - Specialists consulted: [list, e.g., security, backend, data]
    - Findings: [N] total ([X] critical/high, [Y] medium, [Z] nits)
    - Fixed: [N]
    - Escalated: [N] (with reasons)
    - Review cycles: [N]
```

### Phase 9: Commit

```yaml
9.0 GATE CHECK - Verify Phases 7 & 8 Were Run:
    BEFORE committing, verify BOTH phases completed:

    Phase 7 (Simplification) evidence (at least one):
    - Simplification report was output (even if "0 issues found")
    - Sequential thinking tool was invoked for complexity scan
    - Explicit "Simplification skipped per --no-simplify flag" log

    Phase 8 (Self-Review + Multi-Agent Review) evidence (at least one):
    - /review was run and findings were processed
    - Self-review results logged (even if "0 findings")
    - Multi-agent review results logged (or "No specialist agents configured" skip logged)

    If either is missing: STOP and run the missing phase before proceeding.

9.1 Stage Changes:
    ```bash
    git add [specific files changed]
    ```

9.2 Create Story-Scoped Commit:
    ```bash
    git commit -m "$(cat <<'EOF'
    feat(epic-name): Implement story-001 - [brief description]

    - [Key change 1]
    - [Key change 2]
    - [Key change 3]

    Story: bmad/epics/[epic]/stories/story-001-*.md

    🤖 Generated with [Claude Code](https://claude.com/claude-code)

    Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>
    EOF
    )"
    ```

9.3 Verify Commit:
    ```bash
    git log -1 --oneline
    git status  # Should be clean
    ```
```

### Phase 10: Story Completion

```yaml
10.1 Update Story File:
    Edit the story .md file:

    - Change Status: `📋 Ready` → `✅ Complete`
    - Add: `**Completed**: [TODAY'S DATE]`
    - Mark Definition of Done checkboxes: `[x]`
    - Add Completion Notes section:

    ```markdown
    ## Completion Notes

    **Implemented**: [DATE]
    **Commit**: [COMMIT HASH]

    ### Files Changed
    - `path/to/file1.py` - [what changed]
    - `path/to/file2.py` - [what changed]

    ### Tests Added
    - `tests/test_feature.py` - [N] test cases

    ### Simplification Results (REQUIRED)
    - Files reviewed: [N]
    - Issues found: [M]
    - Issues fixed: [X]
    - Lines removed: [Y]
    - Status: [Completed | Skipped (--no-simplify) | No issues found]

    ### Self-Review Results (REQUIRED)
    - Findings: [N] total ([X] critical/high, [Y] medium, [Z] nits)
    - Fixed: [N] (medium+)
    - Skipped: [N] nits

    ### Multi-Agent Review Results (if specialists available)
    - Specialists consulted: [list]
    - Findings: [N] total
    - Fixed: [N]
    - Escalated: [N]

    ### Notes
    - [Any implementation decisions or deviations]
    ```

10.2 Update Epic Overview:
    If epic has a status table, update the story's row to Complete
```

---

## Queue Continuation

After completing a story:

```yaml
1. Check if more stories in queue
2. If yes:
   - Display: "✅ Story 001 complete. Next: Story 002 - [title]"
   - Check if next story was blocked on the one just completed
   - If unblocked: proceed automatically
   - If still blocked: skip and continue
3. If no more stories:
   - Proceed to Phase 11: Push & Create PR (automatic)
   - Display completion summary with PR URL
```

---

## Completion Summary & Auto-PR

When queue is empty, automatically push and create a PR:

```yaml
Phase 11.1 - Display Implementation Summary:

    ## Implementation Complete

    ### Stories Implemented
    | Story | Status | Commit |
    |-------|--------|--------|
    | story-001-db-models | ✅ Complete | abc123 |
    | story-002-api-endpoints | ✅ Complete | def456 |

    ### Stories Skipped (if any)
    | Story | Reason |
    |-------|--------|
    | story-003-frontend | Blocked by external dependency |

Phase 11.2 - Push Branch to Remote:

    CURRENT_BRANCH=$(git branch --show-current)
    # Robust default branch detection (never hardcode main/master)
    DEFAULT_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@')
    if [ -z "$DEFAULT_BRANCH" ]; then
      git remote set-head origin --auto 2>/dev/null
      DEFAULT_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@')
    fi
    DEFAULT_BRANCH="${DEFAULT_BRANCH:-main}"

    # Abort if on default branch (safety check)
    if [ "$CURRENT_BRANCH" = "$DEFAULT_BRANCH" ]; then
        echo "WARNING: On $DEFAULT_BRANCH — cannot auto-create PR."
        echo "Manually create a branch and cherry-pick if needed."
        STOP HERE — do not push or create PR
    fi

    # Push with upstream tracking
    git push -u origin "$CURRENT_BRANCH"

    # Handle push rejection (non-fast-forward)
    # If rejected: inform user to run /sync, then retry

Phase 11.3 - Check for Existing PR:

    EXISTING_PR=$(gh pr list --head "$CURRENT_BRANCH" --json number,url --jq '.[0]')
    if [ -n "$EXISTING_PR" ]; then
        echo "PR already exists for this branch:"
        gh pr view "$CURRENT_BRANCH"
        SKIP PR creation — display existing PR URL and finish
    fi

Phase 11.4 - Gather PR Context:

    # Commits since divergence from default branch
    COMMITS=$(git log origin/$DEFAULT_BRANCH..HEAD --oneline)
    COMMIT_COUNT=$(git rev-list --count origin/$DEFAULT_BRANCH..HEAD)
    FILES_CHANGED=$(git diff --stat origin/$DEFAULT_BRANCH..HEAD | tail -1)

    # Build story list from the implementation session
    # Use the stories_implemented[] array tracked during the queue

Phase 11.5 - Create PR:

    Generate PR title:
      - If single story: "feat(epic-name): story title"
      - If multiple stories: "feat(epic-name): implement [N] stories — [brief epic description]"
      - Keep under 70 characters

    Generate PR body using this template:

    ```
    gh pr create --title "$PR_TITLE" --body "$(cat <<'EOF'
    ## Summary

    [1-3 sentence description of what this implementation delivers,
     derived from the epic goal and stories completed]

    ## Stories Implemented

    | Story | Description | Commit |
    |-------|-------------|--------|
    | story-001 | [title] | abc123 |
    | story-002 | [title] | def456 |

    ## Stories Skipped (if any)

    | Story | Reason |
    |-------|--------|
    | story-003 | Blocked by [reason] |

    ## Changes

    - $COMMIT_COUNT commits
    - $FILES_CHANGED

    ## Commits

    $COMMITS

    ## Quality Gates

    - [x] All tests pass
    - [x] Linting passes
    - [x] Code simplification review (Phase 7)
    - [x] Self-review + multi-agent review (Phase 8)
    - [x] Acceptance criteria verified per story

    ## Test Plan

    - [x] Unit tests pass
    - [x] Linting clean
    - [ ] Integration tests (if applicable)
    - [ ] Manual verification

    ---
    🤖 Generated with [Claude Code](https://claude.com/claude-code)
    EOF
    )" --base "$DEFAULT_BRANCH" --head "$CURRENT_BRANCH"
    ```

Phase 11.6 - Report Final Result:

    ## PR Created

    | Property | Value |
    |----------|-------|
    | **Branch** | $CURRENT_BRANCH → $DEFAULT_BRANCH |
    | **Stories** | [N] implemented |
    | **Commits** | $COMMIT_COUNT |
    | **PR URL** | [link from gh pr create output] |

    ### Branch Summary
    git log --oneline $DEFAULT_BRANCH..HEAD
```

**Error Handling for Push & PR:**

```yaml
Push Rejected (Non-Fast-Forward):
    "Push rejected — remote has changes you don't have locally."
    "Run /sync first, then /push and /pr manually."

gh CLI Not Authenticated:
    "GitHub CLI not authenticated. Run: gh auth login"
    "Then create PR manually: /pr"

No Commits to Push:
    "Already up to date with origin/$CURRENT_BRANCH — no PR needed."
```

---

## Error Handling

### If Tests Fail
```
1. Attempt auto-fix (up to 3 attempts)
2. If still failing:
   - Show failure details
   - Ask: "Tests failing. Options: [R]etry, [S]kip story, [A]sk for help, [Q]uit"
```

### If Blocked Story
```
1. Check what it's blocked by
2. If blocker is in queue: reorder queue
3. If blocker is external: skip and note in summary
```

### If Implementation Unclear
```
1. Re-read story acceptance criteria
2. Check technical context for patterns
3. If still unclear: Ask user for clarification
4. Never guess on business logic
```

---

## Examples

```bash
# Implement entire epic (direct path to overview file)
/implement bmad/epics/data-layer/epic-overview.md

# Implement entire epic (direct path to directory — auto-finds epic-overview.md)
/implement bmad/epics/data-layer

# Implement entire epic (shorthand name — searches bmad/epics/)
/implement data-layer

# Implement single story (direct path)
/implement bmad/epics/data-layer/stories/story-dl-001-exchange-calendar.md

# Implement single story (shorthand: epic-name/story-keyword)
/implement data-layer/exchange-calendar

# Implement multiple specific stories
/implement story-dl-001-exchange-calendar.md story-dl-002-parquet-store.md
```

---

## Integration with claude-feature

When launched via `claude-feature <name>`:

1. Script creates worktree and starts Claude
2. Claude detects worktree name from CWD
3. Auto-suggests: "Detected worktree 'backtester-data-cache'. Run `/implement data-cache`?"
4. User confirms, implementation begins

---

Begin implementation of: **$ARGUMENTS**
