# Story: Application-Driving Scaffold

Story: Add application_driving capability blocks to specialist templates and runtime_validation to story template
Story ID: aap-005
Epic: agent-autonomy-pipeline
Priority: Medium
Estimated Effort: M
Status: ✅ Complete
**Completed**: 2026-03-13
Assigned to: backend-specialist
Created: 2026-03-13

## User Story
As an agent implementing a user-facing story
I want to launch the application, validate runtime behavior, and record evidence
So that acceptance criteria are verified against the actual running system, not just tests

## Business Context

### Problem Statement
BMAD validates through test execution and linting. The agent runs tests and checks lint, but doesn't interact with the running application. The harness engineering report shows that as code throughput increases, the bottleneck shifts to human QA capacity. The solution: make the application directly legible to agents by letting them launch, drive, and observe it.

### Business Value
Runtime validation catches a class of bugs that unit tests miss: configuration errors, integration mismatches, performance regressions, and UI rendering issues. When an agent can `curl` the health endpoint and verify response times, acceptance criteria move from "tests pass" to "the system actually works."

## Acceptance Criteria

**AC1:** Specialist templates include application_driving block
- Given I read a specialist agent template stub
- When I look for application_driving
- Then it contains a YAML block with: launch_command, health_check, ui_validation (enabled/tool/screenshot_dir), and observability (enabled/log_query/metrics_query) — all with TODO markers

**AC2:** Story template includes runtime_validation section
- Given I read the story template
- When I look for runtime_validation
- Then it contains an optional section with: launch_command and acceptance_checks (each with description, command, expected)

**AC3:** /implement recognizes runtime_validation
- Given a story has runtime_validation configured
- When Phase 6.75 (Runtime Validation) runs — after Phase 6.5 (Structural Validation) and before Phase 7 (Simplification)
- Then the agent executes the runtime validation checks in addition to standard test/lint validation

**AC4:** Graceful degradation
- Given a story has NO runtime_validation section
- When Phase 6 runs
- Then behavior is unchanged (existing test/lint validation only)

## Technical Context

### Architecture Reference
Section 6 of 01-harness-engineering-guide.md (Increasing Application Legibility to Agents)

### Existing Patterns to Follow
- Specialist stubs are in `.claude/bmad-template/agents/stubs/`
- Story template is at `.claude/bmad-template/templates/story-template.yaml`
- `/implement` phases are in `.claude/commands/implement.md`
- core-config.yaml already has `app_launch` command

### Dependencies
- Story aap-001 (structural validation) — must coordinate phase ordering. AAP-001 adds Phase 6.5; this story adds Phase 6.75 after it.

## Implementation Guidance

### Files to Modify
- `.claude/bmad-template/agents/stubs/*.md` — Add application_driving YAML block to each specialist
- `.claude/bmad-template/templates/story-template.yaml` — Add optional runtime_validation section
- `.claude/commands/implement.md` — Add Phase 6.75 (Runtime Validation) after Phase 6.5 (Structural Validation, from AAP-001)

### application_driving block for specialist templates
```yaml
## Application Driving
<!-- TODO: Configure these for your project's application-driving capabilities -->
# application_driving:
#   launch_command: "{{APP_LAUNCH_COMMAND}}"
#   health_check: "curl -s http://localhost:{{PORT}}/health"
#   ui_validation:
#     enabled: false
#     tool: "playwright"
#     screenshot_dir: "tests/screenshots/"
#   observability:
#     enabled: false
#     log_query: "# e.g., docker logs app --tail 100"
#     metrics_query: "# e.g., curl localhost:9090/metrics"
```

### runtime_validation story section
```yaml
# Runtime Validation (optional - for user-facing stories)
# runtime_validation:
#   launch_command: "{{APP_LAUNCH_COMMAND}}"
#   acceptance_checks:
#     - description: "Health endpoint returns 200"
#       command: "curl -s -o /dev/null -w '%{http_code}' http://localhost:{{PORT}}/health"
#       expected: "200"
```

## Testing Requirements

### Manual Testing
- Verify specialist stubs contain application_driving block (commented out)
- Verify story template contains runtime_validation section (commented out)
- Verify /implement Phase 6 mentions runtime_validation

## Definition of Done
- [x] Specialist templates updated with application_driving blocks
- [x] Story template updated with runtime_validation section
- [x] /implement Phase 6 enhanced to recognize runtime_validation
- [x] Graceful degradation when not configured
- [x] Story status updated

## Completion Notes

**Implemented**: 2026-03-13
**Commit**: 97a8b65

### Files Changed
- `.claude/bmad-template/agents/stubs/backend-specialist.md` — Added application_driving block
- `.claude/bmad-template/agents/stubs/data-specialist.md` — Added application_driving block
- `.claude/bmad-template/agents/stubs/frontend-specialist.md` — Added application_driving block
- `.claude/bmad-template/agents/stubs/infra-specialist.md` — Added application_driving block
- `.claude/bmad-template/agents/stubs/qa-specialist.md` — Added application_driving block
- `.claude/bmad-template/templates/story-template.yaml` — Added runtime_validation section
- `.claude/commands/implement.md` — Added Phase 6.75 (Runtime Validation)

### Tests Added
- None (template/documentation changes only — verified by manual inspection)

### Simplification Results
- Files reviewed: 7
- Issues found: 0
- Issues fixed: 0
- Lines removed: 0
- Status: No issues found

### Self-Review Results
- Findings: 0 total (0 critical/high, 0 medium, 0 nits)
- Fixed: 0
- Skipped: 0 nits

### Multi-Agent Review Results
- No specialist agents configured — skipped

### Notes
- All application_driving blocks are fully commented out with TODO markers, as designed for per-project customization
- Phase 6.75 gracefully skips when no runtime_validation section exists in the story
- Phase 6.75 falls back to core-config.yaml `app_launch` if story doesn't specify launch_command
