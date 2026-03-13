# BMAD Framework

**Story-driven development for Claude Code.** BMAD (Breakthrough Method of Agile AI-Driven Development) structures AI-assisted development through epics, stories, specialist agents, and quality gates — enforcing a disciplined workflow that scales across any project.

## Quick Start

```bash
# 1. Install the framework
git clone https://github.com/ulrimi/bmad-framework.git ~/bmad-framework
cd ~/bmad-framework && ./install.sh
source ~/.zshrc   # or open a new terminal

# 2. Bootstrap BMAD in your project
cd /path/to/your-project
git init           # if needed
init-bmad          # interactive — asks about your stack, architecture, frameworks

# 3. Open Claude Code and auto-configure
claude
> /configure       # auto-detects settings from your codebase
> /epic my-feature # start building
```

**New to BMAD?** Read the [Team Guide](TEAM_GUIDE.md) for a short primer on how the two-layer architecture works, symlink vs copy mode, and corporate repo setup.

## What It Does

BMAD adds slash commands to Claude Code that orchestrate multi-agent, story-driven development:

| Command | Purpose |
|---------|---------|
| `/bmad <topic>` | Full 5-phase orchestration with parallel agents |
| `/epic <name>` | Create new epic with context gathering |
| `/story <path>` | Create or implement a story |
| `/implement <path>` | Execute stories to completion (multi-phase cycle) |
| `/configure` | Auto-detect project settings from codebase |
| `/explore <topic>` | Deep codebase exploration |
| `/think <question>` | Sequential reasoning without BMAD structure |
| `/review [depth]` | Code review with auto-detected depth |
| `/simplify [path]` | Analyze and reduce code complexity |
| `/maintain` | Repository-wide quality and consistency checks |
| `/score` | Per-domain quality scoring and tracking |
| `/plan` | Create execution plans for complex work |
| `/refine <epic>` | Gap analysis on existing epic |
| `/pr` | Create pull request |
| `/push` | Git push with upstream tracking |
| `/sync` | Git sync (fetch + rebase) |
| `/status` | Project status dashboard |

## Prerequisites

- [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code) installed and authenticated
- Git
- Bash or Zsh

## Install

```bash
git clone https://github.com/ulrimi/bmad-framework.git ~/bmad-framework
cd ~/bmad-framework
./install.sh          # symlink mode (recommended — git pull updates everything)
# or
./install.sh --copy   # copy mode (standalone, no repo dependency)
```

Then open a new terminal (or `source ~/.zshrc`).

### What Gets Installed

| Location | Contents |
|----------|---------|
| `~/.claude/commands/` | 20 slash-command skill definitions |
| `~/.claude/bmad-template/` | Project scaffold templates |
| `~/.claude/scripts/init-bmad` | Project bootstrapper (added to PATH) |
| `~/.claude/scripts/claude-feature` | Worktree-based parallel development (added to PATH) |
| `~/.claude/CLAUDE.md` | Global BMAD instructions for Claude Code |

### Uninstall

```bash
cd ~/bmad-framework
./uninstall.sh
```

Removes only BMAD components from `~/.claude/`. Your projects are not affected.

## Bootstrap a New Project

```bash
cd /path/to/your-project
git init                    # if not already a repo
init-bmad                   # interactive setup
```

`init-bmad` will prompt for:
- **Project name** (defaults to directory name)
- **Description** (one-liner)
- **Language/stack** (Python, TypeScript, Go, or other — sets up lint/test/format commands)
- **Specialists** (backend, frontend, data, qa, infra — creates agent personas)
- **Architecture pattern** (monolith, monorepo, microservices, serverless, library)
- **Frameworks** (conditional on specialists — e.g., FastAPI for backend, React for frontend)
- **Database** (postgres, mysql, sqlite, mongodb, dynamodb, or none)
- **Key directories** (auto-detected from existing code)
- **Gitignore BMAD files** (recommended for existing/corporate repos)

### What It Creates

```
your-project/
├── CLAUDE.md                       ← Project instructions (EDIT THIS)
├── ARCHITECTURE.md                 ← System architecture (EDIT THIS)
└── bmad/
    ├── config/
    │   ├── core-config.yaml        ← Project config (commands, specialists)
    │   ├── golden-principles.md    ← Code taste rules (CUSTOMIZE)
    │   ├── agents/
    │   │   ├── bmad-master.md      ← Master orchestrator
    │   │   └── active/             ← Specialist agents (CUSTOMIZE THESE)
    │   ├── workflows/              ← BMAD lifecycle protocols
    │   ├── tasks/                  ← Task definitions
    │   ├── templates/              ← Epic & story templates
    │   └── checklists/             ← Pre/post work quality gates
    └── epics/                      ← Empty, ready for first epic
```

### After Bootstrap

1. **Open Claude Code** and run `/configure` — auto-detects frameworks, env vars, code style, and key files from your codebase
2. **Review `CLAUDE.md`** — verify and adjust the detected settings
3. **Review `ARCHITECTURE.md`** — customize the scaffolded template for your project
4. **Start building:**

```bash
claude
> /configure                # auto-detect project settings
> /epic my-first-feature    # create your first epic
> /implement my-first-feature
```

`/configure` analyzes your dependency files, directory structure, linter configs, and environment variable usage to fill remaining TODO markers in CLAUDE.md and specialist agent files. Run it again after adding new dependencies.

## Using BMAD in Existing / Corporate Repos

BMAD creates two things in your project: `CLAUDE.md` and a `bmad/` directory. For existing or corporate repos where you don't want to commit these, use `--gitignore`:

```bash
cd /path/to/corporate-repo
init-bmad --gitignore       # adds CLAUDE.md and bmad/ to .gitignore
```

This adds the following to `.gitignore`:
```
# BMAD framework (local dev tooling)
CLAUDE.md
bmad/
```

Each developer runs `init-bmad` locally. BMAD files stay out of the shared repo.

**When to gitignore vs. commit:**

| Approach | Use when |
|----------|----------|
| `--gitignore` | Existing/corporate repos, teams with mixed tooling, strict repo policies |
| Default (commit) | New projects, entire team uses BMAD, want shared epics/stories |

If you gitignore BMAD files, each team member runs `init-bmad` in their local clone. Settings are personal. If you commit them, the team shares CLAUDE.md, specialist agents, and epic/story history.

## CLI Options

### install.sh

```
./install.sh [--link | --copy] [--force]

  --link    Symlink to repo (default). git pull updates all projects.
  --copy    Copy files. Standalone, no repo dependency.
  --force   Overwrite without prompting.
```

### init-bmad

```
init-bmad [--name NAME] [--stack python|typescript|go|other]
          [--specialists LIST] [--desc DESCRIPTION]
          [--arch monolith|monorepo|microservices|serverless|library]
          [--backend-framework FRAMEWORK] [--frontend-framework FRAMEWORK]
          [--data-tools TOOLS] [--database DB]
          [--full] [--upgrade] [--dry-run]
          [--gitignore | --no-gitignore]
          [--non-interactive]

  --full              Scaffold complete docs/ knowledge base (design-docs, exec-plans, references)
  --upgrade           Non-destructive upgrade for existing BMAD projects (detects and adds missing artifacts)
  --dry-run           Show what --upgrade would do without making changes
```

All flags are optional. In interactive mode, you'll be prompted for anything not provided via flags. In `--non-interactive` mode, sensible defaults are used (BMAD files are committed by default).

## How BMAD Works

### The Core Loop

```
/epic → creates epic overview + story breakdown
  ↓
/implement → for each story:
  1. Context loading
  2. Codebase exploration
  3. Implementation planning
  4. Implementation
  5. Testing
  6. Lint & validation
  7. Code simplification
  8. Self-review
  9. Commit
  10. Story completion
  ↓
Repeat until epic is complete
```

### Two-Layer Architecture

- **Global layer** (`~/.claude/`): Framework methodology — commands, templates, workflows. Shared across all projects.
- **Project layer** (`your-project/bmad/`): Domain-specific — specialist agents, epics, stories, quality gates. Unique per project.

### Specialist Agents

Each project gets customizable specialist agents that define domain expertise. During `/implement`, the relevant specialist is loaded as a persona to guide implementation with domain-specific quality gates.

Available specialist stubs: `backend`, `frontend`, `data`, `qa`, `infra`. You can create custom specialists by adding `.md` files to `bmad/config/agents/active/`.

## Parallel Development with `claude-feature`

`claude-feature` creates isolated git worktrees so you can run multiple Claude Code sessions in parallel — each on its own branch, with its own working directory, sharing the same `.git` backend.

### Basic Usage

```bash
# Create a worktree and launch Claude Code
claude-feature my-feature
# -> Creates project-my-feature/ on feature/my-feature branch
# -> Symlinks .claude/, CLAUDE.md, bmad/, venv/ from main repo
# -> Launches Claude Code interactively

# Inside Claude Code:
> /implement my-feature
```

### Modes

```bash
# HITL (default) — interactive, with permission prompts
claude-feature my-feature

# Yolo — interactive, but skips permission prompts
claude-feature --yolo my-feature

# Ralph — fully autonomous, skips permissions
claude-feature --ralph my-feature
```

### Parallel Loops

Run multiple features simultaneously in separate terminals:

```bash
# Terminal 1
claude-feature frontend-redesign

# Terminal 2
claude-feature api-refactor

# Terminal 3
claude-feature --ralph test-coverage
```

Each terminal gets an isolated worktree with its own branch. Changes don't interfere with each other.

### Management

```bash
claude-feature --list              # Show all active worktrees
claude-feature --remove my-feature # Remove a specific worktree (with safety checks)
claude-feature --clean             # Remove all worktrees
```

### How It Works

1. Creates a git worktree at `../project-name/` (sibling to main repo)
2. Symlinks shared resources (`.claude/`, `CLAUDE.md`, `bmad/`, `venv/`) so Claude Code has full context
3. Sets environment variables (`CLAUDE_FEATURE`, `CLAUDE_WORKTREE`, `CLAUDE_MODE`)
4. Launches `claude` in the worktree directory
5. After work is done: review changes, push, create PR, merge as normal

### CLI Reference

```
claude-feature <name>              HITL worktree (feature/<name> branch)
claude-feature --yolo <name>       HITL worktree (skip permissions)
claude-feature --ralph <name>      Ralph worktree (ralph/<name> branch, autonomous)
claude-feature --list              List all active worktrees
claude-feature --remove <name>     Remove a specific worktree
claude-feature --clean             Remove all non-main worktrees
claude-feature --help              Show help
```

## Updating

### Symlink mode (default)

```bash
cd ~/bmad-framework
git pull
# Done — all projects see the updates immediately
```

### Copy mode

```bash
cd ~/bmad-framework
git pull
./install.sh --copy --force
```

Project-level files (`bmad/` directories, project `CLAUDE.md`) are never touched by updates.

## Multi-Machine Setup

```bash
# Machine 1: Clone and install
git clone https://github.com/ulrimi/bmad-framework.git ~/bmad-framework
cd ~/bmad-framework && ./install.sh

# Machine 2: Same thing
git clone https://github.com/ulrimi/bmad-framework.git ~/bmad-framework
cd ~/bmad-framework && ./install.sh
```

Both machines now have identical BMAD setups. Framework updates propagate via `git pull`.

## Contributing

To modify the framework:

1. Edit files in this repo's `.claude/` directory
2. If using symlink mode, changes are live immediately
3. Test with `init-bmad` in a scratch repo
4. Commit and push

## License

MIT
