# Story: Polish End-to-End Flow and Messaging

**Story ID**: per-project-customization-ux-005
**Epic**: per-project-customization-ux
**Priority**: Medium
**Estimated Effort**: Small
**Status**: Complete
**Completed**: 2026-03-12
**Assigned to**: dev-agent
**Created**: 2026-03-12

## User Story

**As a** senior engineer trying BMAD for the first time
**I want** the install → init → configure flow to be seamless with clear guidance at every step
**So that** I never feel lost about what to do next

## Business Context

### Problem Statement
The individual pieces (install.sh, init-bmad, /configure) need to work together as a cohesive experience. Post-install and post-init messaging must guide users through the complete flow, and the /configure command needs to be discoverable.

### Business Value
Polish is what separates a tool engineers respect from one they abandon. For a senior engineering team, every rough edge erodes trust.

## Acceptance Criteria

**AC1:** install.sh post-install messaging
- **Given** a user runs install.sh
- **When** installation completes
- **Then** the "Quick start" section includes `/configure` as a step:
  ```
  cd /path/to/your-project
  git init
  init-bmad
  claude
  > /configure          # auto-detect project settings
  > /epic my-feature    # create your first epic
  ```

**AC2:** init-bmad post-init messaging
- **Given** a user runs init-bmad
- **When** setup completes
- **Then** the "Next steps" section prominently features `/configure`:
  ```
  Next steps:
    1. Open Claude Code: claude
    2. Run /configure — auto-detect and fill project settings
    3. Review CLAUDE.md — verify and adjust detected settings
    4. Create ARCHITECTURE.md — document your target architecture
    5. Run /epic <your-first-feature> — start building!
  ```
- **And** the TODO count from the catchall sweep is shown:
  ```
  [init-bmad] 12 TODO markers remaining — /configure can auto-fill most of them
  ```

**AC3:** init-bmad summary includes new settings
- **Given** init-bmad ran with expanded prompts (architecture, frameworks, database)
- **When** the summary prints
- **Then** it shows what was configured:
  ```
  Configuration:
    Project: MyApp
    Stack: python (FastAPI)
    Architecture: monolith
    Database: postgres
    Specialists: backend, qa
  ```

**AC4:** /configure appears in CLAUDE.md command table
- **Given** CLAUDE.md.template has the BMAD Quick Commands table
- **When** a new project is initialized
- **Then** `/configure` appears in the table:
  ```
  | `/configure` | Setup | Auto-detect project settings from codebase |
  ```

**AC5:** End-to-end verification
- **Given** a fresh project directory with typical code
- **When** running the full flow: install.sh → init-bmad → /configure
- **Then** CLAUDE.md has zero TODO markers remaining
- **And** all specialist stubs have meaningful content
- **And** the /configure command is listed in Claude Code's slash command help

**AC6:** Global CLAUDE.md mentions /configure
- **Given** the global `~/.claude/CLAUDE.md` has the commands table
- **When** a user reads it
- **Then** `/configure` is listed alongside the other commands

## Technical Context

### Files to Modify

1. `.claude/bmad-template/CLAUDE.md.template` — Add `/configure` to command table
2. `.claude/CLAUDE.md` (global) — Add `/configure` to command table
3. `.claude/scripts/init-bmad` — Update post-init messaging (lines ~312-331)
4. `install.sh` — Update post-install messaging (lines ~246-279)

### Changes to install.sh

Update the "Quick start" section (line ~248):
```bash
echo -e "${BOLD}Quick start:${NC}"
echo "  cd /path/to/your-project"
echo "  git init                      # if not already a repo"
echo "  init-bmad                     # bootstrap BMAD in the project"
echo "  claude                        # open Claude Code"
echo "  > /configure                  # auto-detect project settings"
echo "  > /epic my-first-feature      # create your first epic"
```

Add `/configure` to the slash commands list (after line ~268):
```bash
echo "  /configure   Auto-detect project settings from codebase"
```

### Changes to init-bmad

Update the "Next steps" section (line ~325):
```bash
echo -e "${BOLD}Next steps:${NC}"
echo "  1. Open Claude Code:  claude"
echo "  2. Auto-configure:    /configure"
echo "  3. Review settings:   edit CLAUDE.md"
echo "  4. Architecture doc:  create ARCHITECTURE.md"
echo "  5. Start building:    /epic <your-first-feature>"
```

Add configuration summary after "Created" section:
```bash
echo -e "${BOLD}Configuration:${NC}"
echo "  Project:       ${PROJECT_NAME}"
echo "  Stack:         ${PRIMARY_STACK}${BACKEND_FRAMEWORK:+ ($BACKEND_FRAMEWORK)}"
echo "  Architecture:  ${ARCH_PATTERN}"
echo "  Database:      ${DATABASE}"
echo "  Specialists:   ${SPECIALISTS_RAW}"
```

## Testing Requirements

### End-to-End Test
```bash
# 1. Fresh install
cd /path/to/bmad-framework && ./install.sh --force

# 2. Verify install messaging mentions /configure
./install.sh --force 2>&1 | grep -c "configure"
# Expected: >= 2

# 3. Init in test project
cd /tmp && mkdir e2e-test && cd e2e-test && git init
echo '{"name":"test","dependencies":{"fastapi":"*"}}' > package.json
init-bmad --name TestApp --stack python --non-interactive

# 4. Verify init messaging mentions /configure
# (visual check)

# 5. Verify CLAUDE.md has /configure in command table
grep "configure" CLAUDE.md
# Expected: row in the command table

# 6. Verify TODO count is reported
# (visual check of init-bmad output)

# Cleanup
cd / && rm -rf /tmp/e2e-test
```

## Definition of Done

- [x] install.sh post-install message includes /configure step
- [x] install.sh slash command list includes /configure
- [x] init-bmad post-init message prominently features /configure
- [x] init-bmad shows configuration summary (project, stack, architecture, database, specialists)
- [x] init-bmad reports TODO marker count with /configure suggestion
- [x] CLAUDE.md.template command table includes /configure
- [x] Global CLAUDE.md command table includes /configure
- [x] End-to-end flow produces zero raw placeholders
- [x] Story status updated

## Completion Notes

**Implemented**: 2026-03-12

### Files Changed
- `install.sh` — Added /configure to Quick start steps and slash commands list
- `.claude/scripts/init-bmad` — Added Configuration summary section, updated Next steps to feature /configure prominently, updated catchall message
- `.claude/bmad-template/CLAUDE.md.template` — Added /configure to BMAD Quick Commands table
- `.claude/CLAUDE.md` — Added /configure to global commands table and New Project Setup instructions
