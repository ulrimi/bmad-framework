# Epic: Harness Engineering Foundation

## Overview
**Epic ID**: harness-engineering-foundation
**Created**: 2026-03-13
**Status**: Draft
**Source**: 01-harness-engineering-guide.md, 02-bmad-harness-engineering-synthesis.md

## Business Value
BMAD already nails story-driven decomposition, specialist agents, and quality gates. But the harness engineering findings reveal that the highest-leverage investment for autonomous agent work is **repository knowledge architecture** — making the repo itself the single source of truth for everything an agent needs. This epic closes that gap by adding structured knowledge layers, progressive disclosure via a table-of-contents CLAUDE.md, first-class ARCHITECTURE.md support, execution plans for complex work, and golden principles for taste enforcement.

These changes make every agent session more effective by reducing context-hunting and making architectural decisions discoverable without human intervention.

## Scope

### In Scope
- ARCHITECTURE.md template following matklad's pattern (codemap, invariants, boundaries, cross-cutting concerns)
- Golden principles template for encoding project taste/style invariants
- CLAUDE.md restructuring as a ~100-line table of contents with pointers to deeper docs
- Living-document sections (Progress, Surprises, Decision Log, Retrospective) in epic template
- `docs/` directory scaffold in `init-bmad` (design-docs, exec-plans, product-specs, references, generated)
- ExecPlan template for complex multi-story work
- `/plan` command for creating ExecPlans
- Core-beliefs document template (agent-first operating principles)
- `init-bmad --upgrade` command for non-destructive adoption in existing BMAD projects

### Out of Scope
- Mechanical enforcement of architecture (separate epic)
- Quality scoring automation (separate epic)
- Application-driving capabilities (separate epic)
- Multi-agent review workflow (separate epic)

## Story Breakdown

| # | Story | Description | Effort | Dependencies | Status |
|---|-------|-------------|--------|--------------|--------|
| 001 | architecture-template | Create ARCHITECTURE.md template with matklad's pattern, integrate into init-bmad | M | None | ✅ Complete |
| 002 | golden-principles | Create golden-principles.md template with taste invariants, add to scaffold | S | None | ✅ Complete |
| 003 | claude-md-toc | Restructure CLAUDE.md.template as table of contents (~100 lines) pointing to deeper docs | M | 001, 002, 007 | ✅ Complete |
| 004 | living-docs | Add Progress, Surprises, Decision Log, Retrospective sections to epic template | S | None | ✅ Complete |
| 005 | docs-scaffold | Add docs/ directory structure to init-bmad scaffold (design-docs, exec-plans, product-specs, references, generated) | M | 001, 002 | ✅ Complete |
| 006 | exec-plan-template | Create ExecPlan template based on Codex ExecPlans spec, add /plan command | M | 005 | ✅ Complete |
| 007 | core-beliefs | Create core-beliefs.md template defining agent-first operating principles | S | None | ✅ Complete |
| 008 | upgrade-command | Add `init-bmad --upgrade` for non-destructive adoption in existing projects | L | 001, 002, 004, 005, 007 | Draft |

## Implementation Order
1. **Stories 001, 002, 004, 007** (parallel) — Independent templates with no dependencies
2. **Stories 003, 005** — Depend on templates from step 1 existing (003 needs 001+002+007; 005 needs 001+002)
3. **Story 006** — Depends on docs/ scaffold being in place
4. **Story 008** — Depends on ALL template stories (001, 002, 004, 005, 007) since it offers them as upgrade options

## Cross-Epic Notes
- AAP stories 002, 003, 006, and 008 from the Agent Autonomy Pipeline epic depend on HEF-005 (docs scaffold) for directory structure
- HEF stories should be completed before starting AAP to maximize value

## Success Metrics
- [ ] `init-bmad` scaffolds ARCHITECTURE.md with a useful template that follows matklad's pattern
- [ ] `init-bmad` scaffolds golden-principles.md with project-customizable taste rules
- [ ] CLAUDE.md template is restructured as a short table of contents (~100 lines)
- [ ] Epic template includes living-document sections for complex work tracking
- [ ] `init-bmad --full` scaffolds the complete docs/ knowledge base directory
- [ ] `/plan` command creates ExecPlans for complex multi-story work
- [ ] All templates are self-contained enough for a stateless agent to use
- [ ] `init-bmad --upgrade` detects existing setups and non-destructively adds missing artifacts

## Technical Considerations
- **Architecture reference**: All changes are to template files in `.claude/bmad-template/` and commands in `.claude/commands/`
- **Key modules affected**: `init-bmad` script, `CLAUDE.md.template`, `epic-template.md`, new template files
- **New dependencies**: None
- **Risk areas**: CLAUDE.md restructuring must not break existing projects — the new format should be a superset that gracefully handles projects without the docs/ layer
- **Backward compatibility**: Projects bootstrapped before this change should still work; the docs/ layer is additive
