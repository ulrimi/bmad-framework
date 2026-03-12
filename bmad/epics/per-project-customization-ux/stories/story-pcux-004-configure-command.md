# Story: Create /configure Slash Command

**Story ID**: per-project-customization-ux-004
**Epic**: per-project-customization-ux
**Priority**: High
**Estimated Effort**: Large
**Status**: Complete
**Completed**: 2026-03-12
**Assigned to**: dev-agent
**Created**: 2026-03-12

## User Story

**As a** developer who has run init-bmad in my project
**I want** to run `/configure` in Claude Code and have it auto-detect my project settings
**So that** remaining TODO markers are filled with accurate, codebase-derived values without manual editing

## Business Context

### Problem Statement
Even with expanded init-bmad prompts (Story 003), some settings can only be determined by analyzing the actual codebase — installed packages, directory structure, existing patterns, environment variables in use. A `/configure` command that reads the project and fills in the blanks is the final piece of a polished setup experience.

### Business Value
This is the "wow factor" — an engineer runs one command and watches Claude analyze their project and configure BMAD automatically. It demonstrates the framework's intelligence and saves significant manual work.

## Acceptance Criteria

**AC1:** Auto-detect tech stack
- **Given** a project has `package.json`, `requirements.txt`, `go.mod`, `pyproject.toml`, or `Cargo.toml`
- **When** `/configure` runs
- **Then** it reads dependency files and identifies major frameworks (FastAPI, React, Django, Express, etc.)
- **And** populates the tech stack table in CLAUDE.md

**AC2:** Auto-detect architecture
- **Given** a project has a directory structure
- **When** `/configure` analyzes it
- **Then** it generates an architecture summary describing the project layout
- **And** replaces the `ARCHITECTURE_SUMMARY` TODO in CLAUDE.md

**AC3:** Auto-detect environment variables
- **Given** a project has `.env.example`, `.env.template`, or code referencing `os.environ` / `process.env`
- **When** `/configure` runs
- **Then** it discovers environment variable names and their likely purposes
- **And** populates the env vars table in CLAUDE.md

**AC4:** Auto-detect code style
- **Given** a project has linter configs (`.eslintrc`, `ruff.toml`, `.prettierrc`, `pyproject.toml [tool.ruff]`)
- **When** `/configure` runs
- **Then** it describes the code style conventions in use
- **And** populates the code style section in CLAUDE.md

**AC5:** Auto-fill specialist agents
- **Given** specialist stubs exist in `bmad/qf-bmad/agents/active/`
- **When** `/configure` runs
- **Then** for each specialist, it identifies relevant tech, patterns, focus areas, and key files
- **And** replaces TODO markers in each specialist stub

**AC6:** Key files detection
- **Given** a project has entry points, config files, and route definitions
- **When** `/configure` runs
- **Then** it populates the key files table in CLAUDE.md with actual file paths and descriptions

**AC7:** Confirmation before writing
- **Given** `/configure` has detected all settings
- **When** it's ready to write changes
- **Then** it presents a summary of detected settings to the user
- **And** asks for confirmation before modifying files
- **And** reports what was filled and what still needs manual input

**AC8:** Dry-run mode
- **Given** a user runs `/configure --dry-run`
- **When** analysis completes
- **Then** detected settings are displayed but no files are modified

**AC9:** Selective mode
- **Given** a user runs `/configure --claude-md` or `/configure --specialists`
- **When** the command runs
- **Then** only the specified files are analyzed and updated

**AC10:** Idempotent
- **Given** `/configure` has already been run once
- **When** a user runs it again (e.g., after adding new dependencies)
- **Then** it detects what's already filled vs. what has TODO markers
- **And** only updates sections that still have TODO markers (unless `--force` is passed)

## Technical Context

### Files to Create
- `.claude/commands/configure.md` — The slash command definition

### Command Structure

Follow the Pattern 2 format (YAML frontmatter) matching existing commands like `review.md`:

```yaml
---
allowed-tools: Bash(ls:*), Bash(cat:*), Bash(head:*), Bash(find:*), Bash(git:*), Read, Glob, Grep, Edit, Write
argument-hint: [--all | --claude-md | --specialists | --dry-run | --force]
description: Auto-detect project settings and fill TODO markers in CLAUDE.md and BMAD config files
---
```

### Detection Strategy

The command prompt should instruct Claude to:

**Phase 1: Discover**
```
1. Read CLAUDE.md and bmad/qf-bmad/ files, identify all <!-- TODO: ... --> markers
2. Scan for dependency files: package.json, requirements.txt, pyproject.toml, go.mod, Cargo.toml, Gemfile
3. Scan for config files: tsconfig.json, .eslintrc*, .prettierrc*, ruff.toml, pyproject.toml
4. Scan for env files: .env.example, .env.template, .env.sample
5. Grep for env var usage: os.environ, process.env, os.Getenv
6. Detect directory structure and entry points
```

**Phase 2: Analyze**
```
1. Parse dependency files to identify frameworks and libraries
2. Map directory structure to architecture pattern
3. Extract env var names and infer purposes from context
4. Match directories to specialist domains
5. Identify key files (entry points, configs, routes, models)
```

**Phase 3: Present & Confirm**
```
1. Show detected settings grouped by file they'll update
2. Ask user to confirm, modify, or skip each group
3. Highlight any low-confidence detections
```

**Phase 4: Apply**
```
1. Use Edit tool to replace TODO markers with detected content
2. Report summary: X filled, Y remaining, Z skipped
```

### Example Output

```
/configure

Analyzing project...

Detected Settings:
  Tech Stack:
    | Layer    | Technologies              |
    |----------|---------------------------|
    | Backend  | FastAPI, SQLAlchemy, Alembic |
    | Database | PostgreSQL                 |
    | Testing  | pytest, pytest-asyncio      |
    | Linting  | ruff                        |

  Architecture: FastAPI monolith with SQLAlchemy ORM, Alembic migrations.
    Entry point: app/main.py. Routes in app/api/.

  Environment Variables:
    | Variable      | Purpose            |
    |---------------|--------------------|
    | DATABASE_URL  | PostgreSQL connection |
    | SECRET_KEY    | JWT signing key    |
    | REDIS_URL     | Cache connection   |

  Backend Specialist:
    Tech: FastAPI, SQLAlchemy, Pydantic
    Focus: API routes, data models, business logic
    Key files: app/main.py, app/api/, app/models/

Apply these settings? [Y/n/edit]
```

### Existing Patterns to Follow
- Command format: see `.claude/commands/review.md` for frontmatter + step-by-step structure
- Repo root establishment: `REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)`
- Agent deployment: match the agent patterns used in `/explore` and `/bmad`

## Definition of Done

- [x] `/configure` command file created at `.claude/commands/configure.md`
- [x] Auto-detects tech stack from dependency files
- [x] Auto-detects architecture from directory structure
- [x] Auto-detects environment variables from .env files and code
- [x] Auto-detects code style from linter configs
- [x] Auto-fills specialist agent stubs with detected tech/patterns/files
- [x] Auto-fills key files table in CLAUDE.md
- [x] Shows summary and asks for confirmation before writing
- [x] `--dry-run` mode works
- [x] `--claude-md` and `--specialists` selective modes work
- [x] Idempotent — only updates remaining TODO markers
- [x] Follows existing command file format (YAML frontmatter)
- [x] Story status updated

## Completion Notes

**Implemented**: 2026-03-12

### Files Created
- `.claude/commands/configure.md` — Full slash command with 4-phase protocol (Discover → Analyze → Present & Confirm → Apply)

### Notes
- Command is a Claude prompt (slash command), not a bash script — Claude itself performs the analysis using Read, Glob, Grep, and Edit tools
- Supports `--all`, `--claude-md`, `--specialists`, `--dry-run`, `--force` flags
- Follows same YAML frontmatter pattern as other commands (review.md, explore.md)
- Detects: dependency files for 9 languages, linter/formatter configs, env vars from .env files and code grep, directory structure, entry points
- Idempotent by default — only fills TODO markers unless `--force` is passed
