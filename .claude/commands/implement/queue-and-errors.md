# Queue Continuation & Error Handling

## Queue Continuation

After completing a story:

```yaml
1. Check if more stories in queue
2. If yes:
   - Display: "✅ Story [N] complete. Next: Story [N+1] - [title]"
   - Do not summarize what was just completed — the commit message captures it.
   - Do not recap the previous story's changes or findings.
   - Do not preface with "Moving on to..." or "Now let's work on..."
   - Load the next story file and begin Phase 1 immediately.
   - Check if next story was blocked on the one just completed
   - If unblocked: proceed automatically
   - If still blocked: skip and continue
3. If no more stories:
   - Proceed to Phase 11: Push & Create PR (automatic)
   - Read `.claude/commands/implement/phase-11-push-pr.md`
   - Display completion summary with PR URL
```

---

## Error Handling

### If Tests Fail
```
1. Attempt auto-fix (up to 3 attempts)
2. If still failing:
   - Show failure details
   - Ask: "Tests failing. Options: [R]etry, [S]kip story, [A]sk for help, [Q]uit"
```

### If Blocked Story
```
1. Check what it's blocked by
2. If blocker is in queue: reorder queue
3. If blocker is external: skip and note in summary
```

### Circuit Breaker Rule (applies to ALL retry loops)

Max 3 fix attempts for any single failing check (tests, lint, structural, runtime, review).
If still failing after 3 cycles, escalate to user — repeated attempts consume context
without converging. This limit applies uniformly across Phase 5 (testing), Phase 6.5
(structural), Phase 6.75 (runtime), and Phase 8 (review fixes).

### Error Recovery: Continue vs. Fresh Agent

- Test failure after implementation → Continue (you have the error context)
- Lint failure after review fix → Continue (small, targeted fix)
- Architecture-level failure → Spawn fresh Plan agent (clean assessment)
- Verification failure → Continue with verifier (it has the failure context)

### If Implementation Unclear
```
1. Re-read story acceptance criteria
2. Check technical context for patterns
3. If still unclear: Ask user for clarification
4. Never guess on business logic — an incorrect guess ships silently and costs 10x more to fix in production than asking the user now
```
