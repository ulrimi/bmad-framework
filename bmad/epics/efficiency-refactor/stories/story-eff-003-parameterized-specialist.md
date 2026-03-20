---
id: eff-003
epic: efficiency-refactor
specialist: backend
status: ✅ Complete
scope: [.claude/bmad-template/agents/stubs/, .claude/scripts/init-bmad]
depends_on: []
---

# Story: Parameterized Specialist Template

**Story ID**: EFF-003
**Epic**: efficiency-refactor
**Priority**: Medium
**Estimated Effort**: Medium
**Status**: ✅ Complete
**Completed**: 2026-03-20
**Assigned to**: backend-specialist
**Created**: 2026-03-20

## User Story

**As a** framework maintainer
**I want** specialist agents defined by a single template + YAML config
**So that** I maintain one template instead of 5 near-identical stubs, and adding a new specialist is config-only

## Business Context

**Problem Statement**: 5 specialist stub files (backend, frontend, data, infra, qa) at 64-68 lines each share ~85% identical content. Changes must be replicated across all 5 files. Adding a new specialist requires copying and modifying a stub file.

**Business Value**: Reduces 326 lines to ~110 lines (1 template + 1 config). Makes specialist management trivial and eliminates cross-file duplication drift.

## Acceptance Criteria

### AC1: Single template replaces 5 stubs
- **Given** 5 specialist stub files in `.claude/bmad-template/agents/stubs/`
- **When** the refactor is complete
- **Then** a single `specialist-template.md` exists with `{{VARIABLE}}` placeholders, plus a `specialist-config.yaml` defining the 5 specialist variants

### AC2: init-bmad renders from template
- **Given** a user runs `init-bmad --specialists "backend,data,qa"`
- **When** specialist files are created
- **Then** init-bmad reads `specialist-template.md`, substitutes values from `specialist-config.yaml` for each requested specialist, and produces functionally equivalent output to current stubs

### AC3: Adding a new specialist is config-only
- **Given** a developer wants to add a "security-specialist" type
- **When** they add an entry to `specialist-config.yaml`
- **Then** `init-bmad` can produce the new specialist without any template file changes

### AC4: Existing specialist content preserved
- **Given** current specialist stubs have domain-specific expertise items, quality criteria, and patterns
- **When** the template is instantiated
- **Then** all domain-specific content from the original stubs is preserved in the config and correctly injected

## Technical Context

**Current Specialist Stub Structure** (all 5 files identical structure):
```
Line 1:    # Title with {{PROJECT_NAME}}
Lines 5-35: YAML agent definition (name, id, persona, expertise, quality_criteria, patterns)
Lines 37-51: Context section (Domain, Key Files, Patterns, Quality Gates — all TODOs)
Lines 53-68: Application Driving section (identical across all 5)
```

**Common vs Unique Content**:
- Common (~62%): YAML structure, activation instructions pattern, Context section TODOs, Application Driving section
- Unique (~38%): Specialist name/id, role description, expertise examples, domain focus

**New File Structure**:
```
.claude/bmad-template/agents/
├── specialist-template.md     (~70 lines — single template with {{VAR}} placeholders)
├── specialist-config.yaml     (~80 lines — 5 specialist definitions)
└── stubs/                     (removed — replaced by template + config)
```

**specialist-config.yaml Structure**:
```yaml
specialists:
  - id: backend
    name: "Backend Engineer"
    icon: "⚙️"
    role: "Backend/API development"
    identity: "Expert in {{PROJECT_NAME}} backend services"
    expertise:
      - "API design and implementation"
      - "Database query optimization"
      - "Service architecture patterns"
    quality_criteria:
      - "API contracts match OpenAPI spec"
      - "Database queries are optimized"
      - "Error handling is comprehensive"
      - "Authentication/authorization enforced"
    patterns_to_enforce:
      - "Repository pattern for data access"
      - "Service layer for business logic"
    activation_section: "backend"
  # ... (frontend, data, infra, qa follow same structure)
```

## Implementation Guidance

### Step 1: Analyze current stubs
Read all 5 stubs side by side. Extract the union of all fields into a template with the superset of placeholders.

### Step 2: Create specialist-config.yaml
For each specialist, extract the unique values (name, id, role, expertise items, quality criteria, patterns).

### Step 3: Create specialist-template.md
Build template with `{{VAR}}` placeholders that match config keys. Include all common sections inline.

### Step 4: Update init-bmad
Replace the specialist creation logic (lines ~1034-1122) to:
1. Read specialist-config.yaml
2. For each requested specialist, read template, substitute values, write output

### Step 5: Remove individual stub files
Delete the 5 individual files from `stubs/` directory.

## Testing Requirements

- Generate each of the 5 specialists from template + config and diff against original stubs
- Verify init-bmad correctly renders all 5 specialists
- Test adding a hypothetical 6th specialist via config-only change
- Verify `{{PROJECT_NAME}}` and other project-specific placeholders still work

## Definition of Done

- [x] `specialist-template.md` exists with full placeholder coverage
- [x] `specialist-config.yaml` defines all 5 specialists
- [x] init-bmad renders specialists from template + config
- [x] Generated specialists are functionally equivalent to original stubs
- [x] 5 individual stub files removed
- [x] Adding a new specialist requires only a config entry

## Completion Notes

**Implemented**: 2026-03-20

### Files Changed
- `.claude/bmad-template/agents/specialist-template.md` - New template with {{VAR}} placeholders
- `.claude/bmad-template/agents/specialist-config.yaml` - 5 specialist definitions
- `.claude/scripts/init-bmad` - Added render_specialist() function, replaced copy+sed loop
- `.claude/bmad-template/agents/stubs/` - Removed 5 individual stub files

### Simplification Results
- Files reviewed: 3
- Issues found: 0
- Status: No issues found

### Self-Review Results
- Findings: 0 total
- Fixed: 0
- Skipped: 0

### Notes
- render_specialist() uses awk for YAML extraction and temp files for multi-line block replacement
- Fallback for unknown specialists creates minimal blank file (same as before)
- {{PROJECT_NAME}} and {{TEST_FRAMEWORK}} still replaced by sed in init-bmad after rendering
