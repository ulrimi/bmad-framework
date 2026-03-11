# BMAD Framework

**Story-driven development for Claude Code.** BMAD (Breakthrough Method of Agile AI-Driven Development) structures AI-assisted development through epics, stories, specialist agents, and quality gates — enforcing a disciplined workflow that scales across any project.

## What It Does

BMAD adds slash commands to Claude Code that orchestrate multi-agent, story-driven development:

| Command | Purpose |
|---------|---------|
| `/bmad <topic>` | Full 5-phase orchestration with parallel agents |
| `/epic <name>` | Create new epic with context gathering |
| `/story <path>` | Create or implement a story |
| `/implement <path>` | Execute stories to completion (10-phase cycle) |
| `/explore <topic>` | Deep codebase exploration |
| `/think <question>` | Sequential reasoning without BMAD structure |
| `/review [depth]` | Code review with auto-detected depth |
| `/simplify [path]` | Analyze and reduce code complexity |
| `/refine <epic>` | Gap analysis on existing epic |
| `/dev` | Development environment control |
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
git clone https://github.com/YOUR_USERNAME/bmad-framework.git ~/bmad-framework
cd ~/bmad-framework
./install.sh          # symlink mode (recommended — git pull updates everything)
# or
./install.sh --copy   # copy mode (standalone, no repo dependency)
```

Then open a new terminal (or `source ~/.zshrc`).

### What Gets Installed

| Location | Contents |
|----------|---------|
| `~/.claude/commands/` | 17 slash-command skill definitions |
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

### What It Creates

```
your-project/
├── CLAUDE.md                       ← Project instructions (EDIT THIS)
└── bmad/
    ├── qf-bmad/
    │   ├── core-config.yaml        ← Project config (commands, specialists)
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

1. **Edit `CLAUDE.md`** — Fill in architecture summary, tech stack details, code style, env vars
2. **Edit specialist agents** — Customize `bmad/qf-bmad/agents/active/*.md` for your domain
3. **Create `ARCHITECTURE.md`** (optional) — Document target architecture
4. **Start working:**

```bash
claude
> /epic my-first-feature
> /implement my-first-feature
```

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
          [--non-interactive]
```

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
  8. Code review
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

Available specialist stubs: `backend`, `frontend`, `data`, `qa`, `infra`. You can create custom specialists by adding `.md` files to `bmad/qf-bmad/agents/active/`.

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
git clone https://github.com/YOUR_USERNAME/bmad-framework.git ~/bmad-framework
cd ~/bmad-framework && ./install.sh

# Machine 2: Same thing
git clone https://github.com/YOUR_USERNAME/bmad-framework.git ~/bmad-framework
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
