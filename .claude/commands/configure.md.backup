---
allowed-tools: Read, Glob, Grep, Edit, Bash(ls:*), Bash(cat:*), Bash(head:*), Bash(git:*)
argument-hint: [--all | --claude-md | --specialists | --dry-run | --force]
description: Auto-detect project settings and fill TODO markers in CLAUDE.md and BMAD config files
---

# Configure Command — Auto-Detect Project Settings

**Trigger**: `/configure $ARGUMENTS`

Auto-detect and fill project settings for: **$ARGUMENTS**

This command analyzes your codebase to fill remaining `<!-- TODO: ... -->` markers in CLAUDE.md and BMAD specialist files. It reads dependency files, directory structure, environment variable usage, and linter configs to generate accurate settings.

---

## Argument Parsing

Parse `$ARGUMENTS` to determine mode:

| Flag | Effect |
|------|--------|
| (none) or `--all` | Analyze and fill everything |
| `--claude-md` | Only update CLAUDE.md |
| `--specialists` | Only update specialist agent files |
| `--dry-run` | Show detections but don't modify files |
| `--force` | Overwrite already-filled sections (not just TODOs) |

```
MODE="all"
DRY_RUN=false
FORCE=false

for arg in $ARGUMENTS; do
  case "$arg" in
    --claude-md)    MODE="claude-md" ;;
    --specialists)  MODE="specialists" ;;
    --all)          MODE="all" ;;
    --dry-run)      DRY_RUN=true ;;
    --force)        FORCE=true ;;
  esac
done
```

---

## Phase 1: Discover

Gather raw project information. Run these steps in parallel where possible.

### 1.1 Find TODO Markers

Read CLAUDE.md and all BMAD config files. Identify every `<!-- TODO: ... -->` marker and its location.

```
Files to scan:
- CLAUDE.md
- bmad/config/agents/active/*.md
- bmad/config/workflows/*.md
- bmad/config/core-config.yaml
```

For each file, record:
- File path
- Line number
- TODO content
- What placeholder it represents

If no TODO markers found and `--force` is not set:
```
All settings are already configured. Nothing to do.
Run /configure --force to re-detect and overwrite existing settings.
```

### 1.2 Scan Dependency Files

Look for these files and read them if present:

| File | Stack |
|------|-------|
| `requirements.txt` | Python |
| `pyproject.toml` | Python |
| `setup.py` / `setup.cfg` | Python |
| `Pipfile` | Python |
| `package.json` | JavaScript/TypeScript |
| `go.mod` | Go |
| `Cargo.toml` | Rust |
| `Gemfile` | Ruby |
| `pom.xml` / `build.gradle` | Java |

Extract: framework names, major libraries, versions.

### 1.3 Scan Config Files

Look for linter/formatter configs:

| File | Tool |
|------|------|
| `ruff.toml` or `pyproject.toml [tool.ruff]` | ruff |
| `.eslintrc*` or `eslint.config.*` | ESLint |
| `.prettierrc*` or `prettier.config.*` | Prettier |
| `tsconfig.json` | TypeScript |
| `.editorconfig` | EditorConfig |
| `.flake8` | Flake8 |
| `mypy.ini` or `pyproject.toml [tool.mypy]` | mypy |

Extract: line length, indent style, key rules.

### 1.4 Scan Environment Variables

Check for:
1. `.env.example`, `.env.template`, `.env.sample` — read variable names
2. Grep for `os.environ`, `os.getenv`, `os.Getenv` in source files
3. Grep for `process.env.` in source files
4. Check for `dotenv` imports

Extract: variable names and infer purpose from naming conventions and surrounding code.

### 1.5 Detect Directory Structure

```bash
ls -d */ 2>/dev/null
```

Map directories to roles:
| Directory | Role |
|-----------|------|
| `src/`, `app/`, `lib/` | Source code |
| `server/`, `api/` | Backend |
| `web/`, `frontend/`, `client/` | Frontend |
| `tests/`, `test/`, `spec/` | Tests |
| `docs/` | Documentation |
| `scripts/`, `bin/` | Scripts |
| `migrations/`, `alembic/` | Database migrations |
| `public/`, `static/`, `assets/` | Static assets |
| `config/`, `conf/` | Configuration |
| `deploy/`, `infra/`, `terraform/` | Infrastructure |

### 1.6 Identify Entry Points & Key Files

Look for common entry points:
- `main.py`, `app.py`, `manage.py`, `wsgi.py`, `asgi.py`
- `index.ts`, `index.js`, `server.ts`, `server.js`, `main.ts`
- `main.go`, `cmd/*/main.go`
- `Dockerfile`, `docker-compose.yml`
- Route/controller directories

---

## Phase 2: Analyze

Synthesize discoveries into concrete values for each TODO marker.

### 2.1 Tech Stack Table

From dependency files, build a table:

```markdown
| Layer | Technologies |
|-------|-------------|
| Language | Python 3.11 |
| Backend | FastAPI, SQLAlchemy, Alembic |
| Database | PostgreSQL (psycopg2) |
| Testing | pytest, pytest-asyncio |
| Linting | ruff |
```

Rules:
- Include the primary language and version if detectable
- Group related packages (e.g., "FastAPI, Pydantic" not separate rows)
- Only include significant frameworks, not every utility package
- If a layer wasn't detected, omit it

### 2.2 Architecture Summary

From directory structure and frameworks, write a 1-2 sentence summary:

Examples:
- "FastAPI monolith with SQLAlchemy ORM and Alembic migrations. Entry point: app/main.py."
- "Next.js full-stack application with Prisma ORM. API routes in app/api/."
- "Go microservice with gRPC endpoints. Services in internal/service/."

### 2.3 Code Style

From linter configs, describe conventions:

Example:
```
- ruff enforced (line-length: 120, target: py311)
- Google-style docstrings (convention = "google")
- Type hints required on public functions
- Max complexity: 10
```

### 2.4 Environment Variables Table

From .env files and code analysis:

```markdown
| Variable | Purpose |
|----------|---------|
| DATABASE_URL | PostgreSQL connection string |
| SECRET_KEY | JWT signing key |
| REDIS_URL | Cache/queue connection |
```

Rules:
- Infer purpose from variable name and surrounding code context
- Don't include values, only names and purposes
- Group related vars if many (e.g., AWS_* → "AWS configuration")

### 2.5 Key Files Table

From directory scan and entry point detection:

```markdown
| Doc | Path |
|-----|------|
| Entry Point | `app/main.py` |
| API Routes | `app/api/` |
| Models | `app/models/` |
| Tests | `tests/` |
| Migrations | `alembic/` |
```

### 2.6 Specialist Agent Settings

For each specialist in `bmad/config/agents/active/`:

**Backend Specialist**: Match backend frameworks, API patterns, key backend files
**Frontend Specialist**: Match UI frameworks, component patterns, key frontend files
**Data Specialist**: Match data tools, pipeline patterns, data directories
**Infra Specialist**: Match deployment tools, CI/CD configs, infra files

For each, determine:
- `expertise` items (from detected frameworks)
- `patterns_to_enforce` (from code style analysis)
- `Domain` description
- `Key files I work in` paths

---

## Phase 3: Present & Confirm

Display all detected settings grouped by target file.

### Output Format

```
## Detected Settings

### CLAUDE.md Updates
(only shown if TODO markers exist or --force)

**Tech Stack:**
| Layer | Technologies |
|-------|-------------|
| ... | ... |

**Architecture Summary:**
[summary text]

**Code Style:**
[style description]

**Environment Variables:**
| Variable | Purpose |
|----------|---------|
| ... | ... |

**Key Files:**
| Doc | Path |
|-----|------|
| ... | ... |

### Specialist Updates
(only shown if specialist TODOs exist or --force)

**backend-specialist.md:**
- Expertise: FastAPI, SQLAlchemy, Pydantic
- Domain: API design, business logic, data access
- Key files: app/main.py, app/api/, app/models/

**frontend-specialist.md:**
- Expertise: React, Next.js
- Domain: UI components, state management
- Key files: src/components/, src/pages/

### Summary
- Settings detected: X
- TODO markers to fill: Y
- Already configured (skipped): Z

Apply these settings? [Y/n]
```

### Dry-Run Mode

If `--dry-run`, display the output above and then:
```
Dry run complete. No files were modified.
Run /configure to apply these settings.
```

---

## Phase 4: Apply

After user confirms, apply changes using the Edit tool.

### 4.1 Update CLAUDE.md

For each TODO marker in CLAUDE.md:
1. Read the current file
2. Find the `<!-- TODO: ... -->` comment
3. Replace it with the detected content using the Edit tool
4. For table sections, also remove the surrounding HTML comment markers if present

**Important**: For sections wrapped in `<!-- TODO: ... -->` comments, replace the entire comment block with the detected content. For inline TODOs, replace just the TODO marker.

### 4.2 Update Specialist Files

For each specialist in `bmad/config/agents/active/`:
1. Read the file
2. Find `<!-- TODO: ... -->` markers
3. Replace with detected values using Edit tool

### 4.3 Update Workflow Files

For any remaining TODOs in `bmad/config/workflows/`:
1. Read each file
2. Replace TODO markers with detected values

### 4.4 Report Results

```
## Configuration Complete

| File | TODOs Filled | Remaining |
|------|-------------|-----------|
| CLAUDE.md | 4 | 1 |
| backend-specialist.md | 3 | 0 |
| frontend-specialist.md | 2 | 1 |

**Filled**: X settings auto-detected and applied
**Remaining**: Y settings need manual input
**Skipped**: Z settings already configured

Remaining TODO markers (need manual input):
- CLAUDE.md:67 — Code style rules (no linter config detected)
- frontend-specialist.md:28 — Frontend patterns to enforce
```

---

## Edge Cases

- **No CLAUDE.md**: Error — "Run init-bmad first to scaffold the project."
- **No dependency files**: Skip tech stack detection, note in output.
- **Multiple languages**: Detect all, group in tech stack table.
- **Monorepo**: Detect multiple package files, build broader tech stack.
- **Already configured**: Skip filled sections unless `--force`. Report as "already configured."
- **Conflicting signals**: Prefer explicit config files over inferred patterns. Note confidence level.

---

## Quality Rules

- Never invent settings — only report what's actually detected in the codebase
- Prefer specific file paths over generic descriptions
- Keep descriptions concise — one line per entry where possible
- Follow existing CLAUDE.md formatting (markdown tables, heading levels)
- Don't modify anything outside CLAUDE.md and bmad/config/ directories
