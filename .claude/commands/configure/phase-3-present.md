# Phase 3: Present & Confirm

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

## Next Phase

Read `.claude/commands/configure/phase-4-apply.md` to proceed.
