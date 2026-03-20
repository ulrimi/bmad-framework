# Phase 2: Analyze

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

## Next Phase

Read `.claude/commands/configure/phase-3-present.md` to proceed.
