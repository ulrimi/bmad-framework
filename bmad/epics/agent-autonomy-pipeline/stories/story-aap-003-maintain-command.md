# Story: /maintain Command

Story: Create /maintain command for repository-wide quality, consistency, and documentation checks
Story ID: aap-003
Epic: agent-autonomy-pipeline
Priority: Medium
Estimated Effort: L
Status: Draft
Assigned to: backend-specialist
Created: 2026-03-13

## User Story
As an engineer maintaining an agent-generated codebase
I want a single command that scans for pattern drift, documentation staleness, and tech debt
So that entropy is continuously managed rather than accumulating until it becomes a crisis

## Business Context

### Problem Statement
The OpenAI harness engineering team initially spent 20% of their week manually cleaning up agent-generated code — every Friday was cleanup day. This didn't scale. Their solution: encode golden principles into the repo and build a recurring cleanup process where background agents scan for deviations. BMAD has Phase 7 (simplification) on individual stories but no repository-wide maintenance process.

### Business Value
/maintain functions like garbage collection for technical debt. Small, continuous payments prevent compounding. It surfaces problems early (stale docs, duplicated patterns, boundary violations) when they're cheap to fix.

## Acceptance Criteria

**AC1:** /maintain command exists
- Given I run `/maintain`
- When the command completes
- Then it outputs findings organized by category: Pattern Consistency, Documentation Freshness, Quality Scores, and Tech Debt Assessment

**AC2:** Pattern consistency scanning
- Given the agent scans the codebase
- When it checks against golden-principles.md
- Then it identifies: duplicated utility patterns, hand-rolled helpers that should use shared packages, and boundary violations where data is probed without validation

**AC3:** Documentation freshness checking
- Given the agent checks docs/
- When it compares documentation against code
- Then it flags: references to files/functions that no longer exist, ARCHITECTURE.md sections that don't match current module structure, stale TODO markers

**AC4:** Tech debt tracking
- Given findings are generated
- When the command completes
- Then it updates docs/exec-plans/tech-debt-tracker.md (or creates it) with prioritized items

**AC5:** Actionable output
- Given the command produces findings
- When I review the output
- Then each finding includes: what's wrong, where it is, and what to do about it — optionally offering to create targeted fix stories

## Technical Context

### Existing Patterns to Follow
- `/review` command shows how to scan code and output structured findings
- `/simplify` command shows how to analyze code quality per file
- golden-principles.md (from hef-002) provides the rules to check against

### Dependencies
- Story aap-002 (quality scoring) — /maintain calls /score internally
- Recommended: hef-002 (golden principles) — provides the rules to check against
- Recommended: hef-005 (docs scaffold) — provides the docs/ directory to check

## Implementation Guidance

### Files to Create
- `.claude/commands/maintain.md` — The /maintain command definition

### Command Design
The command should use subagents for parallelism:
1. **Pattern Consistency Agent** — Scans for duplicated utilities, hand-rolled helpers, boundary violations
2. **Documentation Freshness Agent** — Compares docs against code, checks for stale references
3. **Quality Scoring** — Runs /score and includes results
4. **Tech Debt Assessment** — Synthesizes findings into prioritized tech debt list

Output should be structured markdown with severity levels (high/medium/low) and optional auto-fix suggestions.

### Recurring Scheduling
The command can be run:
- Manually via `/maintain`
- As part of a Ralph loop (`/loop 1w /maintain`)
- Before sprint planning to inform priorities

**Note**: The synthesis document listed `/garden` as a separate command for documentation freshness. That functionality is subsumed by `/maintain`'s Documentation Freshness task. If a focused docs-only check is later needed, `/garden` can be added as an alias or focused subset.

## Testing Requirements

### Manual Testing
- Run `/maintain` on the BMAD framework itself
- Verify findings are categorized and actionable
- Verify tech-debt-tracker.md is created/updated

## Definition of Done
- [ ] /maintain command created
- [ ] Pattern consistency scanning works
- [ ] Documentation freshness checking works
- [ ] Tech debt tracker updated with findings
- [ ] Output is actionable with severity levels
- [ ] Story status updated
