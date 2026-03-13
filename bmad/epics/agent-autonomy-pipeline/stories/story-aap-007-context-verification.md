# Story: Context Verification and Knowledge Update Phases

Story: Add Phase 0.5 (context verification) and Phase 10.5 (knowledge update) to /implement
Story ID: aap-007
Epic: agent-autonomy-pipeline
Priority: Medium
Estimated Effort: S
Status: Draft
Assigned to: backend-specialist
Created: 2026-03-13

## User Story
As an agent starting and completing implementation
I want to verify that ARCHITECTURE.md and CLAUDE.md are current before I start, and update docs with discoveries before committing
So that knowledge artifacts stay accurate, doc updates are included in the commit, and future agent sessions benefit from what I learned

## Business Context

### Problem Statement
The harness engineering report's enhanced lifecycle adds bookend phases: pre-flight context verification and post-implementation knowledge updates. Currently, /implement jumps straight into context loading (Phase 1) without checking if the knowledge it's loading is stale. And it commits and creates a PR without considering whether architectural docs need updating. Knowledge updates must happen before commit (Phase 9) so they're included in the same changeset.

### Business Value
Context verification prevents agents from building on stale foundations (e.g., implementing against an ARCHITECTURE.md that describes a module structure that's been reorganized). Knowledge updates ensure that discoveries and decisions flow back into the knowledge base, benefiting all future agent sessions.

## Acceptance Criteria

**AC1:** Phase 0.5 exists in /implement
- Given I read the /implement command
- When I find Phase 0.5
- Then it describes: verifying ARCHITECTURE.md exists and checking CLAUDE.md pointer validity

**AC2:** Phase 0.5 flags stale architecture docs
- Given ARCHITECTURE.md references modules that don't exist
- When Phase 0.5 runs
- Then it flags the stale references and asks whether to proceed or update docs first

**AC3:** Phase 10.5 exists in /implement
- Given I read the /implement command
- When I find Phase 10.5 (between Story Completion and Push/PR)
- Then it describes: updating docs if architectural decisions were made during implementation, BEFORE the commit

**AC4:** Phase 10.5 updates Decision Log
- Given the implementation involved architectural decisions
- When Phase 10.5 runs
- Then it prompts the agent to log significant decisions in the epic's Decision Log section, and these updates are included in the commit

**AC5:** Both phases are lightweight
- Given Phases 0.5 and 12 run
- When I observe their execution
- Then they add minimal overhead (quick file reads and optional writes, not lengthy analysis)

## Technical Context

### Architecture Reference
Section 4 of 02-bmad-harness-engineering-synthesis.md (Enhanced BMAD Lifecycle)

### Existing Patterns to Follow
- /implement phases are sequential and numbered
- Phase 1 already does context loading — Phase 0.5 is a pre-check
- Phase 10 already updates story files — Phase 10.5 updates broader docs before commit (Phase 9 in current numbering actually comes after Phase 10 story completion, so 10.5 fits between story completion and commit/PR)

### Dependencies
None.

## Implementation Guidance

### Files to Modify
- `.claude/commands/implement.md` — Add Phase 0.5 before Phase 1 and Phase 10.5 after story completion but before commit/PR

### Phase 0.5: Context Verification
```
Phase 0.5: Context Verification (lightweight)
  If ARCHITECTURE.md exists:
    Quick-scan for references to files/modules that don't exist
    If stale references found: warn and ask to proceed or update
  If CLAUDE.md exists:
    Verify key file references point to existing files
    If broken pointers found: warn
  Proceed to Phase 1
```

### Phase 10.5: Knowledge Update
```
Phase 10.5: Knowledge Update (optional, before commit/PR)
  If architectural decisions were made during implementation:
    Prompt: "Update the epic Decision Log with these decisions? [Y/n]"
  If new patterns were established:
    Prompt: "Update golden-principles.md or ARCHITECTURE.md? [Y/n]"
  If QUALITY_SCORE.md exists:
    Note whether quality improved in the affected domain
  Note: All updates are staged with the implementation changes for a single commit.
```

## Testing Requirements

### Manual Testing
- Verify phases appear in implement.md
- Verify they're described as lightweight
- Verify they don't block when docs don't exist

## Definition of Done
- [ ] Phase 0.5 added to implement.md
- [ ] Phase 10.5 added to implement.md (between story completion and commit/PR)
- [ ] Both phases are lightweight and non-blocking by default
- [ ] Graceful handling when docs don't exist
- [ ] Story status updated
