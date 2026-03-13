# Story: docs/ Directory Scaffold

Story: Add docs/ knowledge base directory structure to init-bmad scaffold
Story ID: hef-005
Epic: harness-engineering-foundation
Priority: Medium
Estimated Effort: M
Status: Draft
Assigned to: backend-specialist
Created: 2026-03-13

## User Story
As an engineer bootstrapping a new BMAD project
I want init-bmad to optionally scaffold a docs/ knowledge base directory
So that the repository has a structured place for design docs, execution plans, product specs, and reference materials that agents can discover through progressive disclosure

## Business Context

### Problem Statement
The harness engineering report's core operational rule: "if a decision, pattern, or constraint matters, it must be discoverable in the repository as a versioned artifact." Currently, BMAD has no structured docs/ layer. Knowledge lives in CLAUDE.md, story files, and people's heads. There's nowhere for design docs, product specs, or reference materials to live in a way that agents can systematically discover.

### Business Value
A structured docs/ directory with indexes makes the repository self-documenting. Agents can navigate from CLAUDE.md → docs/design-docs/index.md → specific design doc without human guidance. Reference materials (like LLM-friendly library docs) give agents the context they need for unfamiliar dependencies.

## Acceptance Criteria

**AC1:** init-bmad scaffolds docs/ with --full flag
- Given I run `init-bmad --full` in a new project
- When the script completes
- Then the following directory structure exists:
  ```
  docs/
  ├── design-docs/
  │   └── index.md
  ├── exec-plans/
  │   ├── active/
  │   ├── completed/
  │   └── tech-debt-tracker.md
  ├── product-specs/
  │   └── index.md
  ├── references/
  │   └── README.md
  ├── generated/
  │   └── .gitkeep
  └── QUALITY_SCORE.md
  ```

**AC2:** Index files have useful starter content
- Given I read docs/design-docs/index.md
- When I review its content
- Then it explains what goes in the directory and links to the template for creating new design docs

**AC3:** --full flag is optional
- Given I run `init-bmad` without --full
- When the script completes
- Then docs/ is NOT created (existing behavior preserved)

**AC4:** References directory explains its purpose
- Given I read docs/references/README.md
- When I review its content
- Then it explains that this directory holds LLM-friendly reference docs for key dependencies (e.g., `design-system-reference-llms.txt`) and how to create them

## Technical Context

### Existing Patterns to Follow
- init-bmad already creates directory structures with `mkdir -p`
- init-bmad uses template files from `.claude/bmad-template/`
- The `--gitignore` flag pattern shows how to add optional flags

### Dependencies
- Stories hef-001 and hef-002 should be done first so CLAUDE.md references are accurate
- But this story can technically be implemented independently

## Implementation Guidance

### Files to Create
- `.claude/bmad-template/docs/design-docs/index.md` — Index template
- `.claude/bmad-template/docs/product-specs/index.md` — Index template
- `.claude/bmad-template/docs/references/README.md` — Purpose explanation
- `.claude/bmad-template/docs/generated/.gitkeep` — Keep empty dir in git

### Files to Modify
- `.claude/scripts/init-bmad` — Add `--full` flag handling, docs/ directory creation, template copying

### Design Decisions
- Use `--full` flag rather than always scaffolding docs/ to avoid overwhelming small projects
- Index files should be short (10-20 lines) with clear guidance
- The exec-plans/ directory has active/ and completed/ subdirs to match the ExecPlans lifecycle
- generated/ uses .gitkeep because auto-generated docs may be gitignored in some projects

## Testing Requirements

### Manual Testing
- Run `init-bmad --name "Test" --stack python --non-interactive` — verify NO docs/ created
- Run `init-bmad --name "Test" --stack python --non-interactive --full` — verify docs/ created with all subdirs
- Verify index files have useful content

## Definition of Done
- [ ] --full flag added to init-bmad
- [ ] docs/ directory structure created with index templates
- [ ] References README explains purpose
- [ ] Default behavior (no --full) unchanged
- [ ] Story status updated
