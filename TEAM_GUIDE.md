# BMAD Team Guide

A short primer on how BMAD works under the hood, so you know what's happening on your machine and in your repos.

---

## The Two-Layer Architecture

BMAD has exactly two layers. Understanding this is the key to everything else.

### Global Layer: `~/.claude/`

Installed once per machine. Shared across every project. Contains:

```
~/.claude/
├── commands/           ← slash commands (/epic, /implement, /review, etc.)
├── bmad-template/      ← scaffolding templates used by init-bmad
├── scripts/
│   ├── init-bmad       ← project bootstrapper (on your PATH)
│   └── claude-feature  ← worktree launcher (on your PATH)
└── CLAUDE.md           ← global instructions Claude reads in every project
```

**You never edit these directly.** They're the framework itself. Updates come from `git pull` (symlink mode) or re-running `install.sh` (copy mode).

### Project Layer: `your-repo/`

Created per project when you run `init-bmad`. Contains:

```
your-repo/
├── CLAUDE.md           ← project-specific instructions (EDIT THIS)
└── bmad/
    ├── config/
    │   ├── agents/     ← specialist personas (CUSTOMIZE THESE)
    │   ├── workflows/  ← development lifecycle protocols
    │   ├── tasks/      ← task definitions
    │   └── ...
    └── epics/          ← your epics and stories live here
```

**This is yours.** Customize CLAUDE.md, tweak specialist agents, write epics and stories. These files are specific to the project and its tech stack.

---

## Symlink vs Copy Mode

When you run `install.sh`, you choose how the global layer is installed:

| Mode | Command | How it works | Updates |
|------|---------|-------------|---------|
| **Symlink** (default) | `./install.sh` | Creates symlinks from `~/.claude/` back to the cloned repo | `git pull` in the repo updates everything instantly |
| **Copy** | `./install.sh --copy` | Copies files into `~/.claude/` | Must re-run `./install.sh --copy --force` after `git pull` |

**Symlink mode** is recommended if you want automatic updates. The trade-off is you need to keep the cloned repo around (don't delete `~/bmad-framework/`).

**Copy mode** is simpler if you just want the files and don't care about easy updates. The cloned repo can be deleted after install.

To check which mode you're in:
```bash
ls -la ~/.claude/commands  # symlink → shows -> /path/to/bmad-framework/...
```

---

## What Happens When You Run `init-bmad`

1. Detects you're in a git repo
2. Asks about your project (name, stack, architecture, frameworks, database)
3. Copies templates from `~/.claude/bmad-template/` into `your-repo/bmad/`
4. Fills placeholders based on your answers (tech stack, test commands, lint commands)
5. Creates `CLAUDE.md` with project-specific settings
6. Anything it can't fill becomes a `<!-- TODO: ... -->` marker for `/configure` to handle

**It only writes to the current project directory.** It never modifies `~/.claude/` or any other repo.

### Full Scaffold (`--full`)

For projects that want the complete knowledge architecture upfront:

```bash
init-bmad --full
```

This adds everything above plus:
- `ARCHITECTURE.md` — system architecture (codemap, invariants, boundaries)
- `bmad/config/golden-principles.md` — code taste rules
- `docs/` — knowledge base directory (design-docs, exec-plans, product-specs, references)
- `lints/` — custom structural validation scripts

### Upgrading Existing Projects (`--upgrade`)

For projects already using BMAD that want to adopt new features:

```bash
init-bmad --upgrade            # interactive gap analysis
init-bmad --upgrade --dry-run  # preview what would change
```

This detects what's already in place and offers to non-destructively add missing artifacts (ARCHITECTURE.md, golden-principles.md, docs/ layer, etc.). It never overwrites existing files.

---

## Corporate / Existing Repo Setup

For repos where you don't want BMAD files committed:

```bash
cd /path/to/corporate-repo
init-bmad --gitignore
```

This adds `CLAUDE.md` and `bmad/` to `.gitignore`. The files exist locally but never touch the shared repo. Each developer runs `init-bmad` on their own machine.

**What git sees with `--gitignore`:**
```
$ git status
modified: .gitignore     ← only this changes in the shared repo
```

**What's actually on disk:**
```
$ ls
CLAUDE.md    bmad/    src/    package.json    ...
```

---

## The Workflow at a Glance

```
install.sh          ← once per machine
    ↓
init-bmad           ← once per project
    ↓
/configure          ← once per project (auto-detects remaining settings)
    ↓
/epic <feature>     ← creates epic + story breakdown
    ↓
/implement <epic>   ← implements stories one by one with quality gates
    ↓
/maintain           ← periodic quality checks (pattern drift, doc freshness)
/score              ← per-domain quality grades
```

Each `/implement` cycle per story:
1. Context verification (check ARCHITECTURE.md freshness)
2. Load story context and specialist persona
3. Explore codebase
4. Plan changes (shows you, asks approval)
5. Implement
6. Test + lint
7. Structural validation (if configured)
8. Simplify (mandatory)
9. Self-review + multi-agent review (mandatory)
10. Mark story complete + update docs
11. Commit (all changes in one commit)

---

## Common Gotchas

**"Command not found: init-bmad"**
Open a new terminal or run `source ~/.zshrc`. The installer adds `~/.claude/scripts` to your PATH.

**"I deleted ~/bmad-framework and now commands are broken"**
You were in symlink mode. Re-clone and re-run `./install.sh`, or switch to copy mode with `./install.sh --copy`.

**"I ran init-bmad twice"**
Safe. It warns about existing files and asks before overwriting. Epics and agent customizations are preserved.

**"CLAUDE.md has TODO markers in it"**
Expected. Run `/configure` inside Claude Code to auto-detect and fill them from your codebase. Or edit manually.

**"My teammate's CLAUDE.md looks different from mine"**
If you used `--gitignore`, each developer has their own local copy. That's by design. If you want a shared config, don't gitignore and commit CLAUDE.md.

**"Which files should I edit?"**
- `CLAUDE.md` — yes, this is your main config file
- `bmad/config/agents/active/*.md` — yes, customize specialist expertise
- Everything else in `bmad/config/` — generally leave alone unless you know what you're doing

**"How do I update the framework?"**
```bash
cd ~/bmad-framework && git pull
# If copy mode: ./install.sh --copy --force
```
Project-level files are never touched by updates.
