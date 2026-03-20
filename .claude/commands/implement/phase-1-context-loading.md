# Phase 1: Context Loading (2 min)

```yaml
1.1 Read Story File:
    - Load full story content
    - Extract: Goal, Acceptance Criteria, Technical Context, Testing Requirements
    - Identify: Touched files, dependencies, blocked-by stories

1.2 Verify Prerequisites:
    - Check if blocked-by stories are complete
    - If blocked: skip and move to next story, or ask user

1.3 Load Specialist Persona:
    - Match story domain to specialist file in bmad/config/agents/active/
    - Read specialist .md and adopt expertise
    - Match based on story keywords and specialist domain descriptions
    - If specialist has a "Supplementary Modules" section:
      Note the module paths and their load phases (e.g., "load during: phase-4, phase-5")
      Do NOT load modules now — load them when entering the specified phase
```

## Next Phase

Read `.claude/commands/implement/phase-2-exploration.md` to proceed.
