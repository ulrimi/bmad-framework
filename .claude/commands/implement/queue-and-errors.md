# Queue Continuation & Error Handling

## Queue Continuation

After completing a story:

```yaml
1. Check if more stories in queue
2. If yes:
   - Display: "✅ Story 001 complete. Next: Story 002 - [title]"
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

### If Implementation Unclear
```
1. Re-read story acceptance criteria
2. Check technical context for patterns
3. If still unclear: Ask user for clarification
4. Never guess on business logic
```
