# Epic: Per-Project Customization UX

## Overview

**Epic ID**: per-project-customization-ux
**Created**: 2026-03-12
**Status**: Complete
**ARCHITECTURE.md Milestone**: Template System & Developer Onboarding

## Business Value

Senior engineers who clone bmad-framework and run `install.sh` then `init-bmad` are left with ~40+ unfilled `{{PLACEHOLDER}}` markers scattered across CLAUDE.md, agent stubs, and workflow files. There is no guidance on what to fill in, no tooling to auto-detect settings, and the interactive setup only asks 4 questions. For a high-level engineering team, this creates friction and makes the framework feel unfinished.

This epic makes the setup process polished, intuitive, and largely automated — so engineers go from `git clone` to a fully-configured BMAD project in under 2 minutes.

## Scope

### In Scope
- Fix existing bugs in init-bmad (capitalize ordering, missing substitutions, unreplaced inline placeholders in bmad-master.md)
- Replace all unfilled `{{PLACEHOLDER}}` markers in template files with instructive TODO comments
- Add catchall sweep in init-bmad to convert any remaining raw `{{}}` to TODO markers
- Expand init-bmad interactive prompts (architecture pattern, frameworks, database, key directories)
- Add new CLI flags to init-bmad for non-interactive use with expanded options
- Create `/configure` slash command that auto-detects project settings from codebase analysis
- Update install.sh post-install messaging to mention `/configure`

### Out of Scope
- Changing the global command definitions (commands stay global, unchanged)
- Web UI or GUI for configuration
- Automatic ARCHITECTURE.md generation (that's a separate feature)
- Changes to the symlink vs copy install mode logic

## Story Breakdown

| # | Story | Description | Effort | Dependencies | Status |
|---|-------|-------------|--------|--------------|--------|
| 001 | fix-init-bmad-bugs | Fix capitalize ordering, missing substitutions, unreplaced bmad-master placeholders | S | None | Complete |
| 002 | todo-markers | Replace all unfilled placeholders in templates with instructive TODO markers | M | 001 | Complete |
| 003 | expand-init-prompts | Add architecture, framework, database, and directory prompts to init-bmad | M | 001, 002 | Complete |
| 004 | configure-command | Create /configure slash command for codebase-aware auto-configuration | L | 002 | Complete |
| 005 | polish-and-messaging | Update install.sh messaging, init-bmad summary, and verify end-to-end flow | S | 003, 004 | Complete |

## Implementation Order

1. **Story 001** (fix-init-bmad-bugs) — Foundation: fix existing bugs before adding features
2. **Story 002** (todo-markers) — Replace raw placeholders with instructive TODO markers in all templates
3. **Story 003** (expand-init-prompts) — Expand init-bmad to fill more placeholders during setup (depends on 001, 002)
4. **Story 004** (configure-command) — Create /configure command that auto-detects and fills remaining TODOs (depends on 002)
5. **Story 005** (polish-and-messaging) — End-to-end polish and messaging updates (depends on 003, 004)

## Success Metrics

- [ ] After `init-bmad`, zero raw `{{PLACEHOLDER}}` text appears in any scaffolded file
- [ ] Every unfilled section has a clear, actionable TODO with an example
- [ ] `init-bmad` interactive mode gathers enough info to fill 80%+ of placeholders
- [ ] `/configure` can auto-detect and fill remaining TODOs from codebase analysis
- [ ] A senior engineer can go from `git clone` to fully-configured project in < 2 minutes
- [ ] `--non-interactive` mode still works with sensible defaults for all new prompts
- [ ] All stories complete and passing tests

## Technical Considerations

- **Key modules affected**: `.claude/scripts/init-bmad`, `.claude/bmad-template/**/*.md`, `.claude/commands/configure.md` (new)
- **No new dependencies**: Pure bash + Claude Code slash command (markdown)
- **Symlink safety**: Template changes only affect future `init-bmad` runs, not existing projects
- **Risk areas**: sed catchall sweep must target only BMAD placeholders (uppercase + underscore), not arbitrary `{{}}` content like Jinja2 templates
- **Existing bugs to fix first**: `capitalize` function used before defined (line 221 vs 239), `{{TEST_FRAMEWORK}}` not substituted in qa-specialist.md, `{{SPECIALIST_AGENTS_LIST}}` and `{{SPECIALIST_AGENTS_TABLE}}` never replaced in bmad-master.md
