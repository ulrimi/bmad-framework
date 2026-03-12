# Story: Expand init-bmad Interactive Prompts

**Story ID**: per-project-customization-ux-003
**Epic**: per-project-customization-ux
**Priority**: Medium
**Estimated Effort**: Medium
**Status**: Complete
**Completed**: 2026-03-12
**Assigned to**: dev-agent
**Created**: 2026-03-12

## User Story

**As a** developer setting up BMAD in a new project
**I want** init-bmad to ask me about my architecture, frameworks, and database
**So that** 80%+ of the TODO markers are filled automatically during initial setup

## Business Context

### Problem Statement
init-bmad currently asks only 4 questions (name, description, stack, specialists). This leaves most specialist-specific and architecture-specific placeholders unfilled. Engineers have to manually hunt through files to fill them in. Adding a few more targeted questions during setup can auto-fill the majority.

### Business Value
Reduces post-setup manual editing from ~25 fields to ~5. Engineers spend time building, not configuring.

## Acceptance Criteria

**AC1:** Architecture pattern prompt
- **Given** a user runs init-bmad interactively
- **When** prompted for architecture pattern
- **Then** they can choose from: `monolith | monorepo | microservices | serverless | library`
- **And** the choice populates `{{ARCHITECTURE_SUMMARY}}` in CLAUDE.md with a sensible default

**AC2:** Framework prompts based on selected specialists
- **Given** a user selected "backend" as a specialist
- **When** init-bmad reaches framework prompts
- **Then** it asks: "Backend framework? [1) fastapi 2) django 3) flask 4) express 5) nestjs 6) gin 7) other]"
- **And** the answer populates `{{BACKEND_TECH}}` and related placeholders in the backend-specialist stub
- **And** frontend specialist triggers a similar prompt for frontend frameworks
- **And** data specialist triggers a prompt for data tools (pandas, spark, dbt, etc.)

**AC3:** Database prompt
- **Given** a user runs init-bmad interactively
- **When** prompted for database
- **Then** they can choose from: `postgres | mysql | sqlite | mongodb | dynamodb | none`
- **And** the choice is reflected in the tech stack table and architecture summary

**AC4:** Auto-detect key directories
- **Given** a user runs init-bmad in a repo with existing code
- **When** init-bmad starts
- **Then** it detects common directories (`src/`, `server/`, `web/`, `lib/`, `app/`, `api/`, `tests/`) and shows them
- **And** asks: "Detected directories: src/, tests/, api/. Correct? [Y/n]"
- **And** uses them to populate `{{KEY_FILES_TABLE}}` and specialist `{{*_KEY_FILES}}` placeholders

**AC5:** New CLI flags for non-interactive mode
- **Given** a CI/CD pipeline or script needs to run init-bmad without interaction
- **When** it passes `--arch monolith --backend-framework fastapi --database postgres`
- **Then** those values are used without prompting
- **And** all existing `--non-interactive` behavior continues to work with sensible defaults for new options

**AC6:** Backward compatibility
- **Given** an existing script that calls `init-bmad --name Foo --stack python --non-interactive`
- **When** it runs against the updated init-bmad
- **Then** it succeeds with no errors — new prompts are skipped and defaults are used

## Technical Context

### Files to Modify
- `.claude/scripts/init-bmad` — Add new prompts, CLI flags, and sed substitutions

### New Prompts (Interactive Mode)

Insert after the existing specialists prompt (line ~117):

```bash
# Architecture pattern
if [[ "${NON_INTERACTIVE}" == false ]]; then
  echo ""
  echo "  1) monolith"
  echo "  2) monorepo"
  echo "  3) microservices"
  echo "  4) serverless"
  echo "  5) library/package"
  prompt "Architecture pattern? [1]"
  read -r arch_choice
  case "${arch_choice}" in
    2) ARCH_PATTERN="monorepo" ;;
    3) ARCH_PATTERN="microservices" ;;
    4) ARCH_PATTERN="serverless" ;;
    5) ARCH_PATTERN="library" ;;
    *) ARCH_PATTERN="monolith" ;;
  esac
fi
ARCH_PATTERN="${ARCH_PATTERN:-monolith}"

# Conditional framework prompts based on specialists
for spec in "${SPECIALIST_LIST[@]}"; do
  case "${spec}" in
    backend)
      # Show framework options based on PRIMARY_STACK
      prompt "Backend framework? [e.g., fastapi, express, gin]"
      read -r BACKEND_FRAMEWORK
      ;;
    frontend)
      prompt "Frontend framework? [e.g., react, vue, angular, svelte]"
      read -r FRONTEND_FRAMEWORK
      ;;
    data)
      prompt "Data tools? [e.g., pandas, spark, dbt, sqlalchemy]"
      read -r DATA_TOOLS
      ;;
  esac
done

# Database
prompt "Database? [postgres/mysql/sqlite/mongodb/none] [none]"
read -r DATABASE
DATABASE="${DATABASE:-none}"
```

### New CLI Flags

```bash
--arch PATTERN          Architecture pattern
--backend-framework FW  Backend framework name
--frontend-framework FW Frontend framework name
--data-tools TOOLS      Data tools/frameworks
--database DB           Database type
```

### New Sed Substitutions

After the existing substitutions, add:
```bash
# Architecture and framework substitutions in CLAUDE.md
sed -i.bak \
  -e "s|{{ARCHITECTURE_SUMMARY}}|${ARCH_SUMMARY_TEXT}|g" \
  -e "s|{{TECH_STACK_TABLE}}|${TECH_STACK_TEXT}|g" \
  CLAUDE.md && rm CLAUDE.md.bak

# Specialist-specific substitutions
if [[ -f "bmad/qf-bmad/agents/active/backend-specialist.md" ]]; then
  sed -i.bak \
    -e "s|{{BACKEND_TECH}}|${BACKEND_FRAMEWORK}|g" \
    -e "s|{{BACKEND_FOCUS}}|${PROJECT_NAME} backend services|g" \
    "bmad/qf-bmad/agents/active/backend-specialist.md" && rm "...bak"
fi
```

### Key Directory Auto-Detection

```bash
DETECTED_DIRS=""
for dir in src server web lib app api cmd pkg internal tests test spec; do
  [[ -d "${dir}" ]] && DETECTED_DIRS="${DETECTED_DIRS} ${dir}/"
done

if [[ -n "${DETECTED_DIRS}" ]] && [[ "${NON_INTERACTIVE}" == false ]]; then
  info "Detected directories:${DETECTED_DIRS}"
  prompt "Use these for key files? [Y/n]"
  read -r confirm
  [[ "${confirm}" =~ ^[Nn]$ ]] || KEY_DIRS="${DETECTED_DIRS}"
fi
```

## Definition of Done

- [x] Architecture pattern prompt added (5 choices)
- [x] Conditional framework prompts for backend/frontend/data specialists
- [x] Database prompt added
- [x] Key directory auto-detection implemented
- [x] All new prompts have corresponding CLI flags
- [x] `--non-interactive` uses sensible defaults for all new options
- [x] New values are substituted into CLAUDE.md, specialist stubs, and bmad-flow.md
- [x] Backward compatible — existing `--non-interactive` scripts still work
- [x] Story status updated

## Completion Notes

**Implemented**: 2026-03-12

### Files Changed
- `.claude/scripts/init-bmad` — Added architecture, framework, database, and data-tools prompts; CLI flags (--arch, --backend-framework, --frontend-framework, --data-tools, --database); auto-detect key directories; build architecture summary, tech stack table, and key files table; Python3-based multi-line replacement for cross-platform reliability; fixed pipefail crash when DETECTED_DIRS is empty

### Notes
- Used `_kf_sep` separator pattern to avoid blank line in key files table
- Used Python3 for multi-line placeholder replacement (macOS sed/awk unreliable for multi-line)
- Added `|| true` to grep commands in specialist file detection to prevent pipefail crash in empty repos
