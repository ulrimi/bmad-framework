# Story: Replace Unfilled Placeholders with Instructive TODO Markers

**Story ID**: per-project-customization-ux-002
**Epic**: per-project-customization-ux
**Priority**: High
**Estimated Effort**: Medium
**Status**: Complete
**Completed**: 2026-03-12
**Assigned to**: dev-agent
**Created**: 2026-03-12

## User Story

**As a** developer who just ran init-bmad
**I want** every unfilled section to have a clear, actionable TODO with examples
**So that** I know exactly what to fill in and can do it quickly without reading docs

## Business Context

### Problem Statement
After init-bmad runs, ~25+ placeholders remain as raw `{{PLACEHOLDER_NAME}}` text. Engineers see `{{ARCHITECTURE_SUMMARY}}` and don't know what format is expected, what a good example looks like, or that `/configure` can auto-fill it. This makes the framework feel incomplete.

### Business Value
First impressions matter. When a senior engineer opens CLAUDE.md after init and sees helpful TODO comments instead of raw mustache syntax, the framework feels professional and intentional.

## Acceptance Criteria

**AC1:** CLAUDE.md.template TODO markers
- **Given** init-bmad generates CLAUDE.md
- **When** an engineer opens it
- **Then** every unfilled section has a `<!-- TODO: ... -->` comment with:
  - What to fill in (1 sentence)
  - A concrete example
  - A note that `/configure` can auto-detect it

**AC2:** Agent stub TODO markers
- **Given** init-bmad copies specialist stubs
- **When** an engineer opens a specialist file
- **Then** unfilled fields like `{{BACKEND_TECH}}` are replaced with TODO comments showing examples relevant to that specialist type

**AC3:** Workflow TODO markers
- **Given** init-bmad copies bmad-flow.md
- **When** an engineer opens it
- **Then** `{{PRE_FLIGHT_ENV}}` and any remaining specialist placeholders have TODO markers

**AC4:** init-bmad catchall sweep
- **Given** init-bmad finishes all its sed substitutions
- **When** any `{{UPPERCASE_NAME}}` pattern remains in any scaffolded file
- **Then** it is converted to `<!-- TODO: Fill in UPPERCASE_NAME. Run /configure to auto-detect. -->`
- **And** a summary line is printed: "X TODO markers remaining — run /configure in Claude Code to auto-fill"

**AC5:** No false positives
- **Given** a project uses Jinja2, Handlebars, or other `{{}}` syntax in its own code
- **When** the catchall sweep runs
- **Then** it only processes files under `CLAUDE.md` and `bmad/qf-bmad/` — never touches other project files

## Technical Context

### Files to Modify

**Template files** (replace raw `{{}}` with TODO markers):
1. `.claude/bmad-template/CLAUDE.md.template` — 6 unfilled placeholders:
   - `{{ARCHITECTURE_SUMMARY}}` → TODO with example architecture description
   - `{{TECH_STACK_TABLE}}` → TODO with example table rows
   - `{{CODE_STYLE}}` → TODO with example style rules
   - `{{KEY_FILES_TABLE}}` → TODO with example file references
   - `{{ENV_VARS_TABLE}}` → TODO with example env var rows
   - `{{PROJECT_SPECIFIC_CHECKLIST}}` → TODO with example checklist items

2. `.claude/bmad-template/agents/stubs/backend-specialist.md` — 6 unfilled:
   - `{{BACKEND_TECH}}`, `{{BACKEND_PATTERNS}}`, `{{BACKEND_FOCUS}}`, `{{BACKEND_KEY_FILES}}`, `{{BACKEND_PATTERN_1}}`, `{{BACKEND_PATTERN_2}}`

3. `.claude/bmad-template/agents/stubs/frontend-specialist.md` — 4 unfilled:
   - `{{FRONTEND_TECH}}`, `{{FRONTEND_PATTERNS}}`, `{{FRONTEND_FOCUS}}`, `{{FRONTEND_KEY_FILES}}`

4. `.claude/bmad-template/agents/stubs/data-specialist.md` — 4 unfilled:
   - `{{DATA_TECH}}`, `{{DATA_PATTERNS}}`, `{{DATA_FOCUS}}`, `{{DATA_KEY_FILES}}`

5. `.claude/bmad-template/agents/stubs/infra-specialist.md` — 4 unfilled:
   - `{{INFRA_TECH}}`, `{{INFRA_PATTERNS}}`, `{{INFRA_FOCUS}}`, `{{INFRA_KEY_FILES}}`

6. `.claude/bmad-template/workflows/bmad-flow.md` — 7 unfilled:
   - `{{PRE_FLIGHT_ENV}}`, `{{SPECIALIST_1_NAME}}`, `{{SPECIALIST_1_FOCUS}}`, `{{SPECIALIST_2_NAME}}`, `{{SPECIALIST_2_FOCUS}}`, `{{SPECIALIST_3_NAME}}`, `{{SPECIALIST_3_FOCUS}}`

**Script file:**
7. `.claude/scripts/init-bmad` — Add catchall sweep after all sed substitutions (before the summary section)

### TODO Marker Format

Use HTML comments so they're invisible in rendered markdown but visible when editing:

```markdown
<!-- TODO: Describe your system architecture (e.g., "FastAPI monolith with PostgreSQL,
deployed on AWS ECS. React SPA frontend served via CloudFront.")
Run /configure to auto-detect from your codebase. -->
```

For inline values in YAML/agent stubs, use a comment-appropriate format:
```yaml
expertise:
  - "<!-- TODO: e.g., FastAPI, SQLAlchemy, Pydantic --> implementation patterns"
```

### Catchall Sweep Implementation

Add to init-bmad after all explicit sed substitutions, before the summary output:

```bash
# ─── Catchall: convert remaining {{PLACEHOLDERS}} to TODO markers ─────
info "Checking for remaining placeholders..."
REMAINING=0
for f in CLAUDE.md bmad/qf-bmad/**/*.md bmad/qf-bmad/**/*.yaml; do
  if [[ -f "${f}" ]] && grep -qE '\{\{[A-Z_]+\}\}' "${f}"; then
    # Replace remaining {{UPPERCASE_THING}} with TODO markers
    sed -i.bak -E 's/\{\{([A-Z_]+)\}\}/<!-- TODO: Fill in \1. Run \/configure to auto-detect. -->/g' "${f}" && rm "${f}.bak"
    count=$(grep -c 'TODO: Fill in' "${f}" 2>/dev/null || echo 0)
    REMAINING=$((REMAINING + count))
  fi
done

if [[ ${REMAINING} -gt 0 ]]; then
  warn "${REMAINING} TODO markers remaining — run /configure in Claude Code to auto-fill"
else
  success "All placeholders filled!"
fi
```

## Definition of Done

- [ ] All 6 CLAUDE.md.template unfilled placeholders converted to TODO markers with examples
- [ ] All specialist stub unfilled placeholders converted to TODO markers with domain-relevant examples
- [ ] bmad-flow.md unfilled placeholders converted to TODO markers
- [ ] init-bmad has catchall sweep that catches any stragglers
- [ ] Catchall only processes CLAUDE.md and bmad/qf-bmad/ files
- [ ] Running init-bmad produces zero raw `{{UPPERCASE}}` patterns in output
- [ ] TODO count is reported in init-bmad summary
- [ ] Story status updated
