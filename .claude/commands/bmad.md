# BMAD Maximum-Compute Protocol

**Trigger**: `/bmad $ARGUMENTS`

You are activating the full BMAD high-compute orchestration for: **$ARGUMENTS**

## Immediate Action

Invoke the BMAD skill which will:

1. **Phase 0**: Parse intent and determine compute intensity
2. **Phase 1**: Deploy 3-4 parallel agents for intelligence gathering
3. **Phase 2**: Execute 12+ step sequential reasoning synthesis
4. **Phase 3**: Create epic + immediate refinement
5. **Phase 4**: Route to specialists with handoff context
6. **Phase 5**: Validate quality and package outputs

## Synthesis Rule

When consuming agent outputs to create epics, stories, or handoff prompts, NEVER delegate understanding. Every outgoing prompt or artifact must include:
- Specific file paths and line numbers (not "the relevant files")
- Exact changes required (not "based on your findings, fix it")
- Concrete content inlined (not `[content]` placeholders)

### Examples

**BAD** (lazy delegation):
> "Based on the exploration results, create stories for the identified gaps."
> "Fix the issues found by the review agent."
> "Implement changes based on your research."

**GOOD** (specific, self-contained):
> "Create a story for adding input validation to `src/api/routes.py:45-67` — the `create_user` endpoint accepts unbounded string input for the `name` field. Add Pydantic validation with max_length=255."
> "In `src/auth/middleware.py:23`, the `verify_token` function catches all exceptions silently. Change the bare `except:` on line 31 to `except jwt.InvalidTokenError:` and log the error."

## Agent Routing Heuristics

When deciding whether to continue an existing agent (SendMessage) or spawn a fresh one (Agent), use this table:

| Situation | Action | Reason |
|-----------|--------|--------|
| Research explored the exact files to edit | Continue (SendMessage) | Already has files in context |
| Research was broad, implementation narrow | Spawn fresh | Avoid dragging exploration noise |
| Correcting a failure or extending recent work | Continue | Has error context |
| Verifying another agent's work | Always spawn fresh | Fresh eyes, no assumptions |
| Wrong approach entirely | Spawn fresh | Clean slate avoids anchoring |

## Execution

Read and execute the full protocol at: `.claude/skills/bmad/SKILL.md`

The skill contains:
- Detailed agent prompts with tool awareness
- Sequential thinking structure
- Quality gates and validation criteria
- Fallback protocols

## Expected Outputs

After completion, you will have:
- `$REPO_ROOT/bmad/epics/[epic-name]/epic-overview.md` - Complete epic definition
- `$REPO_ROOT/bmad/epics/[epic-name]/stories/*.md` - Individual story files

**Note**: `REPO_ROOT` = `git rev-parse --show-toplevel`. All bmad/ paths are relative to the current repo root.
- Specialist assignments for each story
- Dependency graph and execution order
- Risk mitigations documented

## Quick Reference

```bash
# Full protocol for new initiative
/bmad webhook reliability improvements

# Full protocol for feature
/bmad add team collaboration features

# Full protocol for refactor
/bmad migrate to async task queue
```

Begin Phase 0 now with: **$ARGUMENTS**
