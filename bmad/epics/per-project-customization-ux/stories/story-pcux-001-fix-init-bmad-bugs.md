# Story: Fix init-bmad Existing Bugs

**Story ID**: per-project-customization-ux-001
**Epic**: per-project-customization-ux
**Priority**: High
**Estimated Effort**: Small
**Status**: Complete
**Completed**: 2026-03-12
**Assigned to**: dev-agent
**Created**: 2026-03-12

## User Story

**As a** developer running init-bmad in a new project
**I want** the script to work correctly without errors or orphaned placeholders
**So that** I get a clean, functional BMAD scaffold on first run

## Business Context

### Problem Statement
init-bmad has three bugs that cause errors or leave broken content in scaffolded files. These must be fixed before adding new features.

### Business Value
Foundation work — all subsequent stories depend on a bug-free init-bmad.

## Acceptance Criteria

**AC1:** capitalize function ordering
- **Given** a user specifies an unknown specialist name (e.g., "devops")
- **When** init-bmad creates a blank agent file for it
- **Then** the capitalize function works (it is defined before first use)

**AC2:** qa-specialist TEST_FRAMEWORK substitution
- **Given** a user selects "qa" as a specialist
- **When** init-bmad copies qa-specialist.md
- **Then** `{{TEST_FRAMEWORK}}` is replaced with the detected test framework (e.g., "pytest")

**AC3:** bmad-master inline placeholder replacement
- **Given** init-bmad copies bmad-master.md
- **When** the specialist list is generated
- **Then** `{{SPECIALIST_AGENTS_LIST}}` (YAML block, line ~41) is replaced with proper YAML content
- **And** `{{SPECIALIST_AGENTS_TABLE}}` (markdown table, line ~73) is replaced with a proper table

**AC4:** All specialist stubs get PROJECT_NAME + stack-relevant substitutions
- **Given** a user selects any specialist
- **When** init-bmad copies that specialist's stub
- **Then** `{{PROJECT_NAME}}` is replaced in all occurrences (already works)
- **And** `{{TEST_FRAMEWORK}}` is replaced where present (qa-specialist)

## Technical Context

### Files to Modify
- `.claude/scripts/init-bmad` — bug fixes in the specialist loop and bmad-master generation

### Bug Details

**Bug 1 — capitalize used before defined:**
- Line 221: `SPEC_CAP="$(capitalize "${spec}")"` — calls the function
- Line 239: `capitalize() { ... }` — defines the function
- Fix: Move `capitalize()` definition above the specialist loop (before line 206)

**Bug 2 — qa-specialist missing TEST_FRAMEWORK:**
- Line 215: `sed -i.bak "s|{{PROJECT_NAME}}|${PROJECT_NAME}|g" "${dest}"` — only replaces PROJECT_NAME
- Fix: Add `{{TEST_FRAMEWORK}}` substitution in the specialist copy loop: `sed -e "s|{{TEST_FRAMEWORK}}|${TEST_CMD%% *}|g"`

**Bug 3 — bmad-master unreplaced inline placeholders:**
- Lines 247-249 replace `{{PROJECT_NAME}}`, `{{PROJECT_DESCRIPTION}}`, `{{PROJECT_DOMAIN}}`
- Lines 253-259 append specialist list to bottom of file
- But `{{SPECIALIST_AGENTS_LIST}}` (line ~41 of template) and `{{SPECIALIST_AGENTS_TABLE}}` (line ~73 of template) are never replaced
- Fix: Generate proper content and use sed to replace these placeholders, or build the content in a variable and substitute

### Existing Patterns to Follow
- The script already uses `sed -i.bak ... && rm *.bak` pattern for in-place editing
- Stack defaults are derived from the `PRIMARY_STACK` case statement

## Testing Requirements

### Manual Test Script
```bash
# Test in a temp directory
cd /tmp && mkdir test-init && cd test-init && git init

# Test with unknown specialist (exercises capitalize bug)
init-bmad --name TestProject --stack python --specialists "backend,devops,qa" --non-interactive

# Verify no raw {{}} in output
grep -r '{{' bmad/ CLAUDE.md || echo "PASS: No raw placeholders"

# Verify capitalize worked for unknown specialist
cat bmad/qf-bmad/agents/active/devops-specialist.md | head -1
# Expected: "# Devops Specialist - TestProject"

# Verify qa-specialist has test framework
grep "pytest" bmad/qf-bmad/agents/active/qa-specialist.md || echo "FAIL: TEST_FRAMEWORK not replaced"

# Verify bmad-master has no {{SPECIALIST_AGENTS_LIST}} or {{SPECIALIST_AGENTS_TABLE}}
grep -c '{{SPECIALIST' bmad/qf-bmad/agents/bmad-master.md
# Expected: 0

# Cleanup
cd / && rm -rf /tmp/test-init
```

## Definition of Done

- [ ] `capitalize` function defined before first use
- [ ] `{{TEST_FRAMEWORK}}` replaced in qa-specialist.md during init
- [ ] `{{SPECIALIST_AGENTS_LIST}}` and `{{SPECIALIST_AGENTS_TABLE}}` replaced in bmad-master.md
- [ ] No errors when running init-bmad with unknown specialist names
- [ ] `--non-interactive` mode still works
- [ ] Story status updated
