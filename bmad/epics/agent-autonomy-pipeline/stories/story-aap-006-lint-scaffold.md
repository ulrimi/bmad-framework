# Story: Custom Lint Scaffolding

Story: Add lints/ directory scaffold to init-bmad with per-stack starter configs
Story ID: aap-006
Epic: agent-autonomy-pipeline
Priority: Low
Estimated Effort: M
Status: Draft
Assigned to: backend-specialist
Created: 2026-03-13

## User Story
As an engineer setting up architectural enforcement for an agent-generated codebase
I want init-bmad to scaffold a lints/ directory with starter validation scripts for my stack
So that I have a foundation for custom structural checks that enforce architectural invariants with agent-friendly error messages

## Business Context

### Problem Statement
The harness engineering report emphasizes that custom linters are essential agent guardrails — and critically, that lint error messages should contain remediation instructions because the error message *is* the agent's prompt. BMAD has no scaffolding for custom lints. Engineers who want mechanical enforcement must build everything from scratch.

### Business Value
Starter lint scripts reduce the barrier to adopting mechanical enforcement. Instead of figuring out how to write a dependency direction checker from scratch, engineers get a working example they can customize. The emphasis on agent-friendly error messages ensures lints are immediately useful for agent workflows.

## Acceptance Criteria

**AC1:** init-bmad --full creates lints/ directory
- Given I run `init-bmad --full --stack python`
- When the script completes
- Then a `lints/` directory exists with stack-appropriate starter scripts

**AC2:** Starter scripts are stack-specific
- Given I bootstrap a Python project
- When I look at lints/
- Then I see Python-based validation scripts (e.g., `check_file_sizes.py`, `check_imports.py`)

**AC3:** Error messages are agent-friendly
- Given I read a starter lint script
- When I look at the error output format
- Then each error includes: what rule was violated, why it matters, and what to do instead

**AC4:** README explains the pattern
- Given I read `lints/README.md`
- When I review its content
- Then it explains: the purpose of custom lints, how to add new checks, the agent-friendly error message format, and how to wire checks into structural_validation in core-config.yaml

## Technical Context

### Existing Patterns to Follow
- init-bmad detects stack from `--stack` flag or interactive prompt
- Template files are copied from `.claude/bmad-template/`
- The `--full` flag (from hef-005) controls optional scaffolding

### Dependencies
- Story aap-001 (structural validation) — lints are wired into Phase 6.5 via core-config.yaml

## Implementation Guidance

### Files to Create
- `.claude/bmad-template/lints/README.md` — Explains the custom lints pattern
- `.claude/bmad-template/lints/python/check_file_sizes.py` — Example: flag files over N lines
- `.claude/bmad-template/lints/python/check_imports.py` — Example: validate import direction
- `.claude/bmad-template/lints/typescript/check-file-sizes.js` — TypeScript equivalent
- `.claude/bmad-template/lints/typescript/check-imports.js` — TypeScript equivalent

### Files to Modify
- `.claude/scripts/init-bmad` — Copy stack-appropriate lint scripts when `--full` flag is used

### Agent-Friendly Error Message Format
```
VIOLATION: [Rule Name]
FILE: path/to/file.py:42
RULE: [What the rule requires]
WHY: [Why this rule exists — the architectural invariant it protects]
FIX: [What to do instead — specific enough for an agent to act on]
```

## Testing Requirements

### Manual Testing
- Run `init-bmad --full --stack python` — verify Python lint scripts
- Run `init-bmad --full --stack typescript` — verify TypeScript lint scripts
- Run a lint script and verify error message format

## Definition of Done
- [ ] lints/ directory scaffolded by init-bmad --full
- [ ] Stack-specific starter scripts (Python, TypeScript minimum)
- [ ] Error messages follow agent-friendly format
- [ ] README explains pattern and integration
- [ ] Story status updated
