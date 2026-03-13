# Epic: Agent Autonomy Pipeline

## Overview
**Epic ID**: agent-autonomy-pipeline
**Created**: 2026-03-13
**Status**: Draft
**Source**: 01-harness-engineering-guide.md, 02-bmad-harness-engineering-synthesis.md
**Prerequisite**: harness-engineering-foundation epic (recommended, not strictly required)

## Business Value
The harness engineering report's key finding is that documentation alone doesn't keep an agent-generated codebase coherent — architecture must be enforced mechanically. This epic adds the enforcement layer: structural validation in the implementation cycle, quality scoring per domain, a maintenance command for continuous entropy management, multi-agent review for the Ralph loop, and application-driving capabilities that let agents validate runtime behavior directly.

These changes push BMAD from "disciplined agent workflow" toward "fully autonomous development pipeline" — the L8 goal. Each story is independently valuable and can be adopted incrementally.

## Scope

### In Scope
- Phase 6.5 structural validation hooks in `/implement` (dependency direction, naming, file size, boundary validation)
- QUALITY_SCORE.md template with per-domain quality grading
- `/score` command to display quality grades and flag regressions
- `/maintain` command for repository-wide quality, consistency, and documentation checks
- Tech debt tracker template (docs/exec-plans/tech-debt-tracker.md)
- Multi-agent review enhancement to Phase 8 (specialist domain review + escalation rules)
- Application-driving capability blocks in specialist agent templates
- Enhanced story template with runtime_validation section
- Custom lint scaffolding per stack (starter linter configs with agent-friendly error messages)
- Context verification phase (Phase 0.5) checking ARCHITECTURE.md freshness and CLAUDE.md pointer validity
- Knowledge update phase (Phase 10.5) for post-implementation documentation updates (before commit/PR)

### Out of Scope
- Building full observability stacks (Grafana, Loki, etc.) — that's per-project infrastructure
- Browser automation tools (Playwright, Puppeteer) — per-project dependency
- Building custom linters for specific architectures — this epic provides the scaffolding, projects fill it in

## Story Breakdown

| # | Story | Description | Effort | Dependencies | Status |
|---|-------|-------------|--------|--------------|--------|
| 001 | structural-validation | Add Phase 6.5 structural validation hooks to /implement with customizable checks | M | None | ✅ Complete |
| 002 | quality-scoring | Create QUALITY_SCORE.md template and /score command for per-domain quality grading | M | None | ✅ Complete |
| 003 | maintain-command | Create /maintain command for pattern scanning, doc freshness, and tech debt tracking | L | 002 | Draft |
| 004 | multi-agent-review | Enhance Phase 8 with multi-agent review: specialist domain review + escalation rules | M | None | ✅ Complete |
| 005 | app-driving-scaffold | Add application_driving capability blocks to specialist templates and runtime_validation to story template | M | 001 | ✅ Complete |
| 006 | lint-scaffold | Add lints/ directory scaffold to init-bmad with per-stack starter configs and agent-friendly error messages | M | 001 | Draft |
| 007 | context-verification | Add Phase 0.5 (context verification) and Phase 10.5 (knowledge update) to /implement lifecycle | S | None | ✅ Complete |
| 008 | tech-debt-tracker | Create tech-debt-tracker.md template, integrate with /maintain for continuous debt management | S | 003, HEF-005 | Draft |

## Implementation Order
1. **Stories 001, 002, 004, 007** (parallel) — Independent additions to different parts of the framework
2. **Story 005** — After 001 (phase ordering coordination: Phase 6.5 structural → Phase 6.75 runtime)
3. **Stories 003, 006** — Depend on quality scoring and structural validation respectively
4. **Story 008** — Depends on /maintain command existing AND HEF-005 (docs/ directory)

## Cross-Epic Prerequisites
Stories AAP-002, AAP-003, AAP-006, and AAP-008 depend on HEF-005 (docs scaffold) from the Harness Engineering Foundation epic for the `docs/` directory structure. These stories should gracefully handle missing `docs/` directory, but full functionality requires HEF-005.

## Success Metrics
- [ ] `/implement` runs structural validation checks between Phase 6 and Phase 7
- [ ] `/score` displays quality grades per domain and flags regressions from previous scores
- [ ] `/maintain` runs a suite of pattern consistency, doc freshness, and tech debt checks
- [ ] Phase 8 can route reviews to domain-specialist agents and escalate conflicting guidance
- [ ] Story template supports runtime_validation section for user-facing behavior checks
- [ ] `init-bmad` scaffolds a lints/ directory with per-stack starter configs
- [ ] `/implement` verifies ARCHITECTURE.md freshness before starting and updates docs before commit

## Technical Considerations
- **Architecture reference**: Changes span `/implement` command phases, new commands, template files, and init-bmad
- **Key modules affected**: `.claude/commands/implement.md`, `.claude/commands/` (new commands), `.claude/bmad-template/` (templates), `init-bmad` script
- **New dependencies**: None at the framework level; per-project lint tools are project dependencies
- **Risk areas**: Phase modifications to `/implement` must not break the existing 11-phase flow — new phases should be additive and skippable when structural validation isn't configured
- **Incremental adoption**: Each story is designed to work independently; projects can adopt any subset
