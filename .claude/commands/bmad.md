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
