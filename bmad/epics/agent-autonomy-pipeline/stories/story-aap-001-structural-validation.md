# Story: Phase 6.5 Structural Validation

Story: Add structural validation hooks between Phase 6 and Phase 7 in /implement
Story ID: aap-001
Epic: agent-autonomy-pipeline
Priority: High
Estimated Effort: M
Status: ✅ Complete
**Completed**: 2026-03-13
Assigned to: backend-specialist
Created: 2026-03-13

## User Story
As an agent running /implement
I want structural validation to run automatically after linting and before simplification
So that architectural violations (backward dependencies, naming violations, oversized files, missing boundary validation) are caught before they compound

## Business Context

### Problem Statement
BMAD enforces quality through behavioral checklists — the agent is asked to follow them faithfully. But the harness engineering report shows that documentation alone doesn't keep a fully agent-generated codebase coherent. Architecture must be enforced through tooling that runs automatically. Currently there's no mechanical check between "code compiles and passes lint" and "code respects architectural boundaries."

### Business Value
Mechanical enforcement catches the most expensive class of errors: code that works but violates architectural invariants. These errors pass tests, pass lint, and look correct — but degrade the codebase over time. Catching them at implementation time is 10x cheaper than discovering them during code review or after deployment.

## Acceptance Criteria

**AC1:** Phase 6.5 exists in /implement
- Given I read `.claude/commands/implement.md`
- When I find Phase 6.5
- Then it describes structural validation checks that run after Phase 6 (Validation & Linting) and before Phase 7 (Simplification)

**AC2:** Validation is project-configurable
- Given a project has structural validation configured in core-config.yaml
- When Phase 6.5 runs
- Then it executes the configured validation commands

**AC3:** Gracefully skips when not configured
- Given a project has NO structural validation in core-config.yaml
- When Phase 6.5 runs
- Then it logs "No structural validation configured — skipping" and proceeds to Phase 7

**AC4:** Violations block progression
- Given structural validation finds violations
- When the agent processes results
- Then it attempts to fix violations before proceeding, logging each fix attempt

**AC5:** core-config.yaml supports validation commands
- Given I read the core-config.yaml template
- When I look for structural validation
- Then there's a `structural_validation` section with configurable check commands

## Technical Context

### Architecture Reference
Section 4 of 01-harness-engineering-guide.md (Enforcing Architecture Mechanically)

### Existing Patterns to Follow
- `/implement` phases are numbered and described in `.claude/commands/implement.md`
- core-config.yaml already has `quality_gates` and `commands` sections
- The phase should follow the same pattern as existing phases (numbered, with clear entry/exit criteria)

### Dependencies
None — this adds a new phase to the existing lifecycle.

## Implementation Guidance

### Files to Modify
- `.claude/commands/implement.md` — Add Phase 6.5 between Phase 6 and Phase 7
- `.claude/bmad-template/core-config.yaml.template` — Add `structural_validation` section

### core-config.yaml addition
```yaml
structural_validation:
  enabled: false  # Set true when validation scripts exist
  checks:
    # - name: "Dependency Direction"
    #   command: "python lints/check_dependencies.py"
    # - name: "File Size Limits"
    #   command: "python lints/check_file_sizes.py --max 300"
    # - name: "Naming Conventions"
    #   command: "python lints/check_naming.py"
```

### Phase 6.5 description
```
Phase 6.5: Structural Validation
  If structural_validation.enabled in core-config.yaml:
    Run each configured check command
    For each failure:
      - Read error message (it should contain remediation instructions)
      - Attempt fix
      - Re-run failed check
      - If fix requires architectural discussion, flag for human review
    Maximum 3 fix-retry cycles per check
  Else:
    Log "No structural validation configured" and proceed
```

## Testing Requirements

### Manual Testing
- Verify Phase 6.5 appears in implement.md
- Verify core-config.yaml template has structural_validation section
- Verify graceful skip when not configured

## Definition of Done
- [x] Phase 6.5 added to implement.md
- [x] core-config.yaml template updated with structural_validation section
- [x] Graceful skip behavior when not configured
- [x] Fix-retry loop described with 3-cycle maximum
- [x] Story status updated

## Completion Notes

**Implemented**: 2026-03-13
**Commit**: d52cb0c

### Files Changed
- `.claude/commands/implement.md` — Added Phase 6.5 section and phase table entry
- `.claude/bmad-template/core-config.yaml.template` — Added structural_validation section

### Simplification Results
- Files reviewed: 2
- Issues found: 0
- Status: No issues found

### Self-Review Results
- Findings: 0
- Status: Clean
