# Phase 2: Exploration (3-5 min)

```yaml
2.1 Quick Codebase Scan:
    subagent_type: Explore
    thoroughness: quick
    prompt: |
      Exploration for implementing: [STORY TITLE]

      Files mentioned in story: [LIST FROM TECHNICAL CONTEXT]

      Find:
      1. Current state of each file to be modified
      2. Patterns used in similar existing code
      3. Related tests that exist
      4. Import dependencies

      Output: File inventory with current line counts and key functions

2.2 Identify Change Scope:
    - List files to CREATE (new)
    - List files to MODIFY (existing)
    - List files to DELETE (if any)
    - List tests to CREATE or MODIFY
```

## Next Phase

Read `.claude/commands/implement/phase-3-planning.md` to proceed.
