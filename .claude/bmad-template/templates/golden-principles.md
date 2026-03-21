# Golden Principles

> Opinionated, mechanical rules about code quality for {{PROJECT_NAME}}.
> These encode team taste so that every agent session produces consistent output.
> Unlike core-beliefs.md (team philosophy), these are concrete code-level rules.

---

## Code Style

1. **Keep functions under 50 lines.** Extract when logic is genuinely reusable (3+ call sites), not preemptively. Three similar lines are better than a premature abstraction.

2. **One responsibility per file.** Split when concerns diverge. A file named `utils.py` is a code smell — name it by what it actually does.

3. **Validate at boundaries, trust internal data shapes.** API handlers, CLI parsers, and external integrations validate. Internal functions trust their callers.

<!-- TODO: Add stack-specific style rules. Examples:
   - Python: Use `X | None` syntax, Google-style docstrings on public functions
   - TypeScript: Strict mode, prefer `interface` over `type` for object shapes
   - Go: Accept interfaces, return structs
-->

## Dependencies

4. **Favor boring technologies.** Composable, API-stable, well-represented in training data. Agents model these correctly; exotic choices cause subtle bugs.

5. **Prefer shared packages over hand-rolled helpers.** If a well-maintained library does what you need, use it. Minimize the surface area of code you own.

6. **External API calls live in a single integration module.** No direct HTTP calls scattered across business logic. Wrap third-party services so they can be swapped or mocked at one point.

## Context Efficiency

7. **Load context incrementally.** A phase transition is the permission to load the next phase file — not a trigger to load all remaining phases. Never embed one command's full logic inside another command; reference it instead.

8. **Commands over 200 lines must use the phase-split pattern.** Index file for argument parsing + dispatch; phase files for self-contained instructions. See ARCHITECTURE.md "Command Design Patterns" section.

## Error Handling

9. **Error messages include remediation instructions.** "File not found: config.yaml" is bad. "File not found: config.yaml — run `cp config.example.yaml config.yaml` to create it" is good.

10. **No silent swallowing of exceptions.** Every `except`/`catch` either re-raises, logs at WARNING+, or has a comment explaining why suppression is intentional.

<!-- TODO: Add stack-specific error handling rules if needed. -->

## Testing

11. **Tests mirror the module structure they validate.** `tests/test_auth.py` tests `src/auth.py`. No monolithic test files.

12. **Mock external services, never internal modules.** Unit tests mock HTTP calls and databases. They never mock your own business logic — that's testing the mock, not the code.

<!-- TODO: Add coverage expectations or test-type ratios if applicable. -->

## Documentation

13. **No print-statement debugging in committed code.** Use structured logging. Debug prints are for local development only.

14. **Comments explain WHY, not WHAT.** If the code needs a comment to explain what it does, the code should be clearer. Comments are for non-obvious rationale, gotchas, and external constraints.

15. **Configuration lives in config files, not scattered across code.** Magic numbers, feature flags, and environment-specific values belong in a config layer, not inline.

<!-- TODO: Add project-specific principles below. Delete any defaults that don't apply. -->
