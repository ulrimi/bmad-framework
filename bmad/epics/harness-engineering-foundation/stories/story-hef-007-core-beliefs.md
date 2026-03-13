# Story: Core Beliefs Template

Story: Create core-beliefs.md template defining agent-first operating principles
Story ID: hef-007
Epic: harness-engineering-foundation
Priority: Low
Estimated Effort: S
Status: ✅ Complete
**Completed**: 2026-03-13
Assigned to: backend-specialist
Created: 2026-03-13

## User Story
As a team adopting BMAD for agent-first development
I want a core-beliefs.md document that defines our operating principles
So that every agent session starts with a shared understanding of how we build software and why

## Business Context

### Problem Statement
The harness engineering report recommends a `core-beliefs.md` document in `docs/design-docs/` that codifies agent-first operating principles. This is distinct from golden-principles.md (which is about code taste) — core beliefs are about the team's philosophy: how they think about agents, quality, speed, and tradeoffs.

### Business Value
Core beliefs align agent behavior with team values. When an agent faces an ambiguous choice (e.g., "should I add more tests or ship faster?"), core beliefs provide the tiebreaker. They also help onboard new team members by making implicit cultural norms explicit.

## Acceptance Criteria

**AC1:** Template exists with starter beliefs
- Given I look at `.claude/bmad-template/docs/design-docs/core-beliefs.md`
- When I read it
- Then it contains 5-8 operating principles relevant to agent-first development with brief explanations

**AC2:** Beliefs are agent-actionable
- Given I read each belief
- When I consider whether an agent could apply it
- Then each belief translates to a concrete behavior (not just an aspiration)

**AC3:** Scaffolded with --full flag
- Given I run `init-bmad --full`
- When the script completes
- Then `docs/design-docs/core-beliefs.md` exists with the template content

## Technical Context

### Existing Patterns to Follow
- docs/ directory is scaffolded by `init-bmad --full` (story hef-005)
- Template files in `.claude/bmad-template/` are copied during scaffold

### Dependencies
None (template creation is independent), but deployment depends on hef-005 (docs scaffold)

## Implementation Guidance

### Files to Create
- `.claude/bmad-template/docs/design-docs/core-beliefs.md` — Template

### Distinction from Golden Principles
Core-beliefs.md = "how we think about development" (team philosophy, tradeoff frameworks).
Golden-principles.md = "how we write code" (concrete code taste rules).
The template should include a header clarifying this distinction. Avoid duplicating specific rules between the two documents.

### Starter Core Beliefs
1. **Agents write the code; engineers design the environment.** When an agent fails, ask "what context or constraint is missing?" not "try harder."
2. **The repository is the only truth.** If it's not in the repo, it doesn't exist for agents. Capture decisions, patterns, and constraints as versioned artifacts.
3. **Mechanical enforcement over aspirational documentation.** If a rule matters, express it as a linter, test, or structural check — not just a comment.
4. **Stories are self-contained context vehicles.** A story file must contain everything needed for autonomous implementation. No assumed context.
5. **Corrections are cheap; waiting is expensive.** Ship and fix forward rather than blocking on perfection. This requires strong automated guardrails to be safe.
6. **Favor boring technologies.** Composable, API-stable, well-represented in training data. Agents model these correctly.
7. **Capture taste once, enforce everywhere.** Human review comments become documentation updates, linter rules, or structural tests.

## Testing Requirements

### Manual Testing
- Verify template is created by `init-bmad --full`
- Verify beliefs are concrete and actionable

## Definition of Done
- [x] core-beliefs.md template created
- [x] Beliefs are agent-actionable, not aspirational
- [x] Scaffolded via init-bmad --full
- [x] Story status updated

## Completion Notes

**Implemented**: 2026-03-13
**Commit**: 4cbccb5

### Files Changed
- `.claude/bmad-template/docs/design-docs/core-beliefs.md` — Created (7 agent-first principles, each with "Agent action" line)
- `.claude/scripts/init-bmad` — Added --full flag and docs/ scaffold with core-beliefs copy

### Simplification Results
- Files reviewed: 2
- Issues found: 0
- Status: No issues found

### Self-Review Results
- Findings: 0
- All acceptance criteria verified
