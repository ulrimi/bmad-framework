# Story: Multi-Agent Review Enhancement

Story: Enhance Phase 8 with multi-agent review — specialist domain review plus escalation rules
Story ID: aap-004
Epic: agent-autonomy-pipeline
Priority: Medium
Estimated Effort: M
Status: Draft
Assigned to: backend-specialist
Created: 2026-03-13

## User Story
As an agent completing implementation via /implement
I want Phase 8 to route reviews to domain-specialist agents and iterate on feedback
So that code is reviewed from multiple perspectives (security, performance, domain correctness) before merge, enabling fully autonomous development

## Business Context

### Problem Statement
Human review doesn't scale when agents produce 3-5 PRs per day. BMAD currently has self-review in Phase 8 — the agent runs `/review` on its own diff. But the harness engineering report describes a richer pattern: agents request reviews from other agents (with different specialist perspectives), respond to feedback, and iterate until all reviewers are satisfied. This creates a review loop that only escalates to humans when genuine judgment is required.

### Business Value
Multi-agent review catches domain-specific issues that a generic self-review misses. A security specialist agent catches auth vulnerabilities; a performance specialist catches N+1 queries; a frontend specialist catches accessibility issues. This closes the quality gap between human review and agent-only review.

## Acceptance Criteria

**AC1:** Phase 8 routes to relevant specialists
- Given a story touches auth-related code
- When Phase 8 runs
- Then the review includes findings from a security-perspective review in addition to the general self-review

**AC2:** Specialist selection is automatic
- Given the agent analyzes which files were changed
- When it determines relevant domains
- Then it loads the appropriate specialist agent personas from `bmad/qf-bmad/agents/active/` for review

**AC3:** Feedback-response loop exists
- Given a specialist review produces findings
- When findings are at medium severity or higher
- Then the agent addresses them and re-runs the review (max 3 cycles)

**AC4:** Escalation rules are defined
- Given the agent encounters conflicting review guidance, an architectural boundary violation, or a security-critical finding with unclear remediation
- When it evaluates escalation criteria
- Then it flags the issue for human review instead of resolving autonomously

**AC5:** Review output includes specialist attribution
- Given multi-agent review produces findings
- When I read the review output
- Then each finding is attributed to the specialist perspective that raised it (e.g., "[Security] API key exposed in error response")

## Technical Context

### Existing Patterns to Follow
- Phase 8 currently runs /review on the agent's own changes
- Specialist agent files are in `bmad/qf-bmad/agents/active/`
- The Agent tool can spawn subagents with specialist personas loaded

### Dependencies
None — this enhances the existing Phase 8.

## Implementation Guidance

### Files to Modify
- `.claude/commands/implement.md` — Enhance Phase 8 description with multi-agent review protocol

### Phase 8 Enhancement
```
Phase 8: Self-Review + Multi-Agent Review
  8.1 Run general self-review (existing behavior)
  8.2 Determine specialist domains touched by this change
      - Map changed files to specialist agents using directory/module matching
  8.3 For each relevant specialist:
      - Spawn review subagent with specialist persona loaded
      - Review the diff from that specialist's perspective
      - Collect findings with specialist attribution
  8.4 Merge all findings, deduplicate, sort by severity
  8.5 Address medium+ findings
  8.6 Re-run reviews if >10 lines changed in fixes (max 3 cycles)
  8.7 Escalation check:
      - Conflicting guidance → escalate
      - Architectural boundary violation needing design discussion → escalate
      - Security-critical with unclear remediation → escalate
      - All other findings → resolve autonomously
```

## Testing Requirements

### Manual Testing
- Run /implement on a story that touches multiple domains
- Verify specialist reviews are generated
- Verify escalation criteria are evaluated

## Definition of Done
- [ ] Phase 8 enhanced with multi-agent review protocol
- [ ] Specialist selection is automatic based on changed files
- [ ] Feedback loop with 3-cycle maximum
- [ ] Escalation rules defined and documented
- [ ] Findings attributed to specialist perspective
- [ ] Story status updated
