# Phase 1: Discover

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

## Next Phase

Read `.claude/commands/configure/phase-2-analyze.md` to proceed.
