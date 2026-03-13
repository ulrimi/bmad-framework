# Custom Lints

> Structural validation scripts that enforce architectural invariants.
> These complement standard linters (ruff, eslint) with project-specific checks.

## Purpose

Standard linters catch syntax and style issues. Custom lints catch **architectural** issues:
- Files growing too large (sign of mixed responsibilities)
- Import direction violations (lower layers importing upper layers)
- Boundary crossings without validation
- Naming convention drift

## Agent-Friendly Error Messages

Every lint error **must** include remediation instructions. The error message _is_ the agent's prompt — if the message doesn't say what to do, the agent will guess.

### Required Error Format

```
VIOLATION: [Rule Name]
FILE: path/to/file.py:42
RULE: [What the rule requires]
WHY: [Why this rule exists — the architectural invariant it protects]
FIX: [What to do instead — specific enough for an agent to act on]
```

### Example

```
VIOLATION: File Size Limit
FILE: src/services/auth.py:312
RULE: Source files must be under 300 lines
WHY: Large files indicate mixed responsibilities. They are harder for agents to reason about and more likely to cause merge conflicts.
FIX: Extract related functions into a new module. Consider splitting by responsibility (e.g., auth_tokens.py, auth_middleware.py).
```

## Adding New Checks

1. Create a new script in the appropriate stack directory (`python/`, `typescript/`)
2. Follow the error format above — every violation must include RULE, WHY, and FIX
3. Exit with code 0 if no violations, non-zero if violations found
4. Wire the check into `core-config.yaml` under `structural_validation`:

```yaml
structural_validation:
  enabled: true
  checks:
    - name: "your-check-name"
      command: "python lints/python/your_check.py"
      description: "What this check enforces"
```

## Included Starter Scripts

### Python

| Script | Purpose |
|--------|---------|
| `check_file_sizes.py` | Flag source files exceeding a configurable line limit |
| `check_imports.py` | Validate import direction between architectural layers |

### TypeScript

| Script | Purpose |
|--------|---------|
| `check-file-sizes.js` | Flag source files exceeding a configurable line limit |
| `check-imports.js` | Validate import direction between architectural layers |

## Running Checks

```bash
# Run individual checks (scripts are copied flat into lints/ by init-bmad)
python lints/check_file_sizes.py
python lints/check_imports.py

# Or via structural validation in /implement (Phase 6.5)
# Checks run automatically when configured in core-config.yaml
```
