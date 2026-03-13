# Story: ARCHITECTURE.md Template

Story: Create ARCHITECTURE.md template following matklad's pattern and integrate into init-bmad
Story ID: hef-001
Epic: harness-engineering-foundation
Priority: High
Estimated Effort: M
Status: Draft
Assigned to: backend-specialist
Created: 2026-03-13

## User Story
As an engineer bootstrapping a new BMAD project
I want an ARCHITECTURE.md template that follows matklad's proven pattern
So that agents can quickly understand where to make changes and what constraints exist, reducing the 10x time penalty of working in an unfamiliar codebase

## Business Context

### Problem Statement
BMAD currently recommends creating ARCHITECTURE.md after bootstrap but provides no template and lists it as "optional." The harness engineering research shows this is the highest-leverage single document for agent productivity — it bridges the gap between knowing *what* to change and knowing *where* to change it.

### Business Value
A well-structured ARCHITECTURE.md reduces agent context-hunting from minutes to seconds per task. It makes architectural invariants (especially absences — "the model layer never imports from views") discoverable, which prevents the most expensive class of agent errors: structural violations that pass tests but degrade the codebase.

## Acceptance Criteria

**AC1:** Template exists and follows matklad's pattern
- Given I look at `.claude/bmad-template/templates/architecture-template.md`
- When I read it
- Then it contains sections for: Overview, Codemap (with module descriptions keyed by name not link), Architectural Invariants (with examples of absence-based rules), Layer Boundaries, and Cross-Cutting Concerns

**AC2:** init-bmad scaffolds ARCHITECTURE.md
- Given I run `init-bmad` in a new project
- When the script completes
- Then `ARCHITECTURE.md` exists at the repo root with the template content and project-specific placeholders converted to TODO markers

**AC3:** Template guides naming for symbol search
- Given I read the template
- When I look at the Codemap section guidance
- Then it explicitly instructs users to name entities by their symbol/module name (searchable) rather than linking to line numbers or URLs

**AC4:** Template includes invariant examples
- Given I read the Architectural Invariants section
- When I review the examples
- Then they include at least one absence-based invariant (e.g., "X never depends on Y") and one boundary validation invariant (e.g., "all external data validated at boundary")

## Technical Context

### Architecture Reference
The template itself defines what good architecture documentation looks like. Source: matklad's ARCHITECTURE.md blog post and Section 3.2 of 01-harness-engineering-guide.md.

### Existing Patterns to Follow
- Template files live in `.claude/bmad-template/templates/`
- Placeholders use `{{VARIABLE_NAME}}` format
- init-bmad copies templates and substitutes placeholders, converting unfilled ones to `<!-- TODO: ... -->` markers

### Dependencies
None — this is a foundational template.

## Implementation Guidance

### Files to Create
- `.claude/bmad-template/templates/architecture-template.md` — The template itself

### Files to Modify
- `.claude/scripts/init-bmad` — Add logic to copy architecture-template.md to `ARCHITECTURE.md` at repo root during scaffold, substituting `{{PROJECT_NAME}}` and `{{PROJECT_DESCRIPTION}}`

### Key Design Decisions
- The template should be ~60-80 lines of guidance with clear section headers
- Each section should have a brief comment explaining what goes there and an example
- The Codemap section should be structured as subsections per module/domain, not a flat list
- Invariants should be phrased as constraints, not aspirations

## Testing Requirements

### Manual Testing
- Run `init-bmad --name "Test Project" --stack python --non-interactive` in a temp directory
- Verify ARCHITECTURE.md is created at repo root
- Verify placeholders are substituted or converted to TODO markers
- Verify template sections match matklad's pattern

## Definition of Done
- [ ] architecture-template.md created in bmad-template/templates/
- [ ] init-bmad copies template to ARCHITECTURE.md at repo root
- [ ] Template follows matklad's pattern (Overview, Codemap, Invariants, Boundaries, Cross-Cutting)
- [ ] Placeholders are project-aware ({{PROJECT_NAME}}, {{PROJECT_DESCRIPTION}})
- [ ] Lint check passes
- [ ] Story status updated
