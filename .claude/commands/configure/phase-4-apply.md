# Phase 4: Apply

After user confirms, apply changes using the Edit tool.

### 4.1 Update CLAUDE.md

For each TODO marker in CLAUDE.md:
1. Read the current file
2. Find the `<!-- TODO: ... -->` comment
3. Replace it with the detected content using the Edit tool
4. For table sections, also remove the surrounding HTML comment markers if present

**Important**: For sections wrapped in `<!-- TODO: ... -->` comments, replace the entire comment block with the detected content. For inline TODOs, replace just the TODO marker.

### 4.2 Update Specialist Files

For each specialist in `bmad/config/agents/active/`:
1. Read the file
2. Find `<!-- TODO: ... -->` markers
3. Replace with detected values using Edit tool

### 4.3 Update Workflow Files

For any remaining TODOs in `bmad/config/workflows/`:
1. Read each file
2. Replace TODO markers with detected values

### 4.4 Report Results

```
## Configuration Complete

| File | TODOs Filled | Remaining |
|------|-------------|-----------|
| CLAUDE.md | 4 | 1 |
| backend-specialist.md | 3 | 0 |
| frontend-specialist.md | 2 | 1 |

**Filled**: X settings auto-detected and applied
**Remaining**: Y settings need manual input
**Skipped**: Z settings already configured

Remaining TODO markers (need manual input):
- CLAUDE.md:67 — Code style rules (no linter config detected)
- frontend-specialist.md:28 — Frontend patterns to enforce
```

---

## Edge Cases

- **No CLAUDE.md**: Error — "Run init-bmad first to scaffold the project."
- **No dependency files**: Skip tech stack detection, note in output.
- **Multiple languages**: Detect all, group in tech stack table.
- **Monorepo**: Detect multiple package files, build broader tech stack.
- **Already configured**: Skip filled sections unless `--force`. Report as "already configured."
- **Conflicting signals**: Prefer explicit config files over inferred patterns. Note confidence level.

---

## Quality Rules

- Never invent settings — only report what's actually detected in the codebase
- Prefer specific file paths over generic descriptions
- Keep descriptions concise — one line per entry where possible
- Follow existing CLAUDE.md formatting (markdown tables, heading levels)
- Don't modify anything outside CLAUDE.md and bmad/config/ directories
