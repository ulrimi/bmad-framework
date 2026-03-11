# Post-Development Checklist

**Run after completing any development work.**

## Tests

- [ ] All tests pass: `{{TEST_CMD}}`
- [ ] New tests written for new/changed functionality
- [ ] Edge cases covered (empty inputs, boundary values, error paths)

## Code Quality

- [ ] Linting passes: `{{LINT_CMD}}`
- [ ] Formatting passes: `{{FORMAT_CMD}}`
- [ ] Code style follows project standards (see CLAUDE.md)
- [ ] Functions are focused and appropriately sized
- [ ] Docstrings on new/modified public functions

## Application Health

- [ ] App/service still launches: `{{APP_LAUNCH_CMD}}`
- [ ] No broken imports or missing modules

## Story Completion

- [ ] All acceptance criteria verified
- [ ] Story status updated to `✅ Complete`
- [ ] Completion date added
- [ ] Definition of Done checkboxes marked
- [ ] Completion Notes section added with:
  - Files changed
  - Tests added
  - Implementation decisions

## Git

- [ ] Changes committed with story reference
- [ ] Commit message follows convention: `feat(epic): story description`

---

**Work is NOT complete until all checks pass.**
