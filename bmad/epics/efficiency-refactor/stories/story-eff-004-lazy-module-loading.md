---
id: eff-004
epic: efficiency-refactor
specialist: backend
status: ✅ Complete
scope: [.claude/bmad-template/agents/, .claude/commands/implement/]
depends_on: [eff-003]
---

# Story: Lazy Module Loading for Specialists

**Story ID**: EFF-004
**Epic**: efficiency-refactor
**Priority**: Medium
**Estimated Effort**: Small
**Status**: ✅ Complete
**Completed**: 2026-03-20
**Assigned to**: backend-specialist
**Created**: 2026-03-20
**Blocked by**: EFF-003 (completed)

## User Story

**As a** BMAD framework optimizer
**I want** specialist files to reference supplementary modules by path instead of inlining content
**So that** module content is only loaded into context when the specialist is actually executing, not during routing or planning

## Business Context

**Problem Statement**: When `/configure` composes specialists, it inlines module content directly into specialist files. This means all module content is in context whenever the specialist file is referenced — even during routing phases that only need the specialist's domain tag.

**Business Value**: ~30% reduction in context usage during non-implementation phases. Module content is only loaded when the specialist is actively working.

## Acceptance Criteria

### AC1: Specialist files reference modules by path
- **Given** a specialist agent file in `bmad/config/agents/active/`
- **When** the file is loaded as a persona
- **Then** it contains a `modules:` YAML field listing paths to supplementary instruction files rather than inlining module content

### AC2: Module loading is phase-driven
- **Given** `/implement` is in Phase 4 (Execution) and the active specialist references a domain-specific module
- **When** the phase instructions execute
- **Then** the phase file instructs Claude to Read the referenced module only during that phase

### AC3: Specialists work without modules
- **Given** a specialist file with an empty `modules: []` or no modules section
- **When** the specialist is activated
- **Then** behavior is identical to today — no errors, no missing context

### AC4: Module config in specialist-config.yaml
- **Given** `specialist-config.yaml` from EFF-003
- **When** a specialist has domain-specific modules
- **Then** the modules are listed in the config and rendered into the specialist template's `modules:` field

## Technical Context

**Current State**: `/configure` Phase 4.2 composes specialists by reading module files and embedding their content directly into the specialist `.md` files via string replacement.

**New Approach**:
```yaml
# In specialist-config.yaml (from EFF-003)
specialists:
  - id: backend
    modules:
      - path: .claude/bmad-template/agents/modules/api-patterns.md
        load_in: [phase-4, phase-5]
      - path: .claude/bmad-template/agents/modules/testing-patterns.md
        load_in: [phase-5]
```

```markdown
# In specialist-template.md, modules section:
{{#if modules}}
## Supplementary Modules
Load these files when reaching the specified phases:
{{#each modules}}
- `{{path}}` — load during: {{load_in}}
{{/each}}
{{/if}}
```

**New Directory**:
```
.claude/bmad-template/agents/
├── specialist-template.md
├── specialist-config.yaml
└── modules/                    (new)
    ├── api-patterns.md         (optional, domain-specific)
    ├── testing-patterns.md     (optional, domain-specific)
    └── ...
```

## Implementation Guidance

### Step 1: Create modules directory
Create `.claude/bmad-template/agents/modules/` — initially empty, as current specialists don't have heavy inlined content.

### Step 2: Add modules field to specialist-config.yaml
Add an optional `modules:` array to each specialist definition in the config from EFF-003.

### Step 3: Update specialist template
Add a conditional modules section to `specialist-template.md` that renders module references when present.

### Step 4: Update implement phase files
In relevant phase files (from EFF-001), add instructions to check specialist modules and Read them when entering the specified phase.

### Step 5: Update /configure
Modify `/configure` Phase 4.2 to write module references instead of inlining module content into specialist files.

## Testing Requirements

- Verify specialist files with modules render correctly
- Verify specialist files without modules still work
- Verify module loading instructions appear in correct implement phase files
- Verify /configure writes references instead of inlining

## Definition of Done

- [x] `modules/` directory exists in agent template structure
- [x] `specialist-config.yaml` supports optional `modules:` field
- [x] Specialist template conditionally renders module references
- [x] Implement phase files include module loading instructions
- [x] Specialists without modules work identically to current behavior

## Completion Notes

**Implemented**: 2026-03-20

### Files Changed
- `.claude/bmad-template/agents/specialist-template.md` - Added {{MODULES_BLOCK}} placeholder
- `.claude/bmad-template/agents/specialist-config.yaml` - Added modules documentation
- `.claude/bmad-template/agents/modules/.gitkeep` - Created modules directory
- `.claude/scripts/init-bmad` - Added modules block rendering to render_specialist()
- `.claude/commands/implement/phase-1-context-loading.md` - Added module awareness instructions
- `.claude/commands/implement/phase-4-execution.md` - Added module loading trigger

### Simplification Results
- Files reviewed: 6
- Issues found: 0
- Status: No issues found

### Self-Review Results
- Findings: 0 total
- Fixed: 0

### Notes
- Modules block renders conditionally: empty when no modules configured, formatted section when present
- Module loading is deferred to the phase specified in the module config
- Currently no specialists define modules — infrastructure is ready for project-specific modules
