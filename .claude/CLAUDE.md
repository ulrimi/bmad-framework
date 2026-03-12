# BMAD Orchestration Framework

## Core Principle

Story-driven development in every project. Never implement directly from high-level requests.
Always: Epic → Stories → Implement with `/implement`.

## BMAD Commands (available in all projects)

| Command | Purpose |
|---------|---------|
| `/bmad <topic>` | Full 5-phase orchestration with parallel agents |
| `/epic <name>` | Create new epic with context gathering |
| `/refine <epic>` | Gap analysis on existing epic |
| `/story <path>` | Create or implement a story |
| `/feature <name>` | Create isolated worktree for parallel work |
| `/implement <path>` | Execute stories until complete |
| `/explore <topic>` | Deep codebase exploration |
| `/think <question>` | Sequential reasoning without BMAD structure |
| `/review [depth]` | Code review with auto-detected depth |
| `/configure` | Auto-detect project settings from codebase |
| `/simplify [path]` | Analyze and reduce code complexity |

## Auto-Agent Deployment

Deploy agents proactively for non-trivial work:

| Request Type | Deploy |
|--------------|--------|
| "Add [feature]" | Explore + Plan agents |
| "Fix [bug]" | Explore agent (quick) |
| "Refactor [system]" | Explore + Plan + Think |
| "Research [topic]" | Explore + general-purpose |
| "Design [component]" | Plan + Think |
| "How does [X] work?" | Explore agent (very thorough) |

## Orchestration Rules

- Maintain todos prioritized by customer value and correctness
- All story transitions include impact assessment
- Enforce quality gates: simplification + review before commit
- Never skip story status synchronization
- Story status must match code state before marking complete

## New Project Setup

To bootstrap BMAD in a new project:
```bash
cd /path/to/new-project
git init  # if not already a git repo
init-bmad
```

This scaffolds `bmad/`, `CLAUDE.md`, and specialist agents. Then run `/configure` in Claude Code to auto-detect project settings, and edit `ARCHITECTURE.md` for project specifics.
