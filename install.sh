#!/usr/bin/env bash
# install.sh — Install BMAD framework into ~/.claude/
# Usage: ./install.sh [--link | --copy] [--force]
#
# --link   Symlink back to this repo (recommended for maintainers — git pull updates everything)
# --copy   Copy files (for users who just want the framework, decoupled from this repo)
# --force  Overwrite existing files without prompting
#
# Default: --link

set -euo pipefail

# ─── Colors ───────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

info()    { echo -e "${BLUE}[bmad]${NC} $*"; }
success() { echo -e "${GREEN}[bmad]${NC} $*"; }
warn()    { echo -e "${YELLOW}[bmad]${NC} $*"; }
error()   { echo -e "${RED}[bmad] ERROR:${NC} $*" >&2; exit 1; }

# ─── Resolve script location ─────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR="${SCRIPT_DIR}/.claude"

if [[ ! -d "${SOURCE_DIR}" ]]; then
  error "Missing .claude/ directory in repo. Run from bmad-framework root."
fi

# ─── Argument parsing ─────────────────────────────────────────────────────────
MODE="link"
FORCE=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --link)  MODE="link"; shift ;;
    --copy)  MODE="copy"; shift ;;
    --force) FORCE=true; shift ;;
    -h|--help)
      echo "Usage: ./install.sh [--link | --copy] [--force]"
      echo ""
      echo "Options:"
      echo "  --link    Symlink to this repo (default, updates with git pull)"
      echo "  --copy    Copy files (standalone, no repo dependency)"
      echo "  --force   Overwrite existing files without prompting"
      echo ""
      echo "Installs BMAD commands, templates, and init-bmad into ~/.claude/"
      exit 0
      ;;
    *) warn "Unknown option: $1"; shift ;;
  esac
done

# ─── Target directory ─────────────────────────────────────────────────────────
TARGET_DIR="${HOME}/.claude"
mkdir -p "${TARGET_DIR}"

# ─── Conflict detection ──────────────────────────────────────────────────────
check_conflict() {
  local target="$1"
  if [[ -e "${target}" ]] && [[ "${FORCE}" == false ]]; then
    # If it's already a symlink pointing to our source, no conflict
    if [[ -L "${target}" ]]; then
      local link_target
      link_target="$(readlink "${target}")"
      if [[ "${link_target}" == "${SOURCE_DIR}"* ]] || [[ "${link_target}" == "${SCRIPT_DIR}"* ]]; then
        return 0  # Our own symlink, safe to overwrite
      fi
    fi
    return 1  # Real conflict
  fi
  return 0
}

# ─── Install a directory (link or copy) ──────────────────────────────────────
install_dir() {
  local src="$1"
  local dest="$2"
  local label="$3"

  if [[ "${MODE}" == "link" ]]; then
    # For link mode: symlink the entire directory
    if [[ -L "${dest}" ]]; then
      rm "${dest}"  # Remove old symlink
    elif [[ -d "${dest}" ]]; then
      if check_conflict "${dest}"; then
        rm -rf "${dest}"
      else
        warn "${label} already exists at ${dest}"
        read -r -p "  Overwrite? [y/N] " confirm
        if [[ "${confirm}" =~ ^[Yy]$ ]]; then
          rm -rf "${dest}"
        else
          warn "  Skipped ${label}"
          return
        fi
      fi
    fi
    ln -s "${src}" "${dest}"
    success "  Linked ${label} -> ${src}"
  else
    # For copy mode: copy the directory
    if [[ -d "${dest}" ]] || [[ -L "${dest}" ]]; then
      if check_conflict "${dest}"; then
        rm -rf "${dest}"
      else
        warn "${label} already exists at ${dest}"
        read -r -p "  Overwrite? [y/N] " confirm
        if [[ "${confirm}" =~ ^[Yy]$ ]]; then
          rm -rf "${dest}"
        else
          warn "  Skipped ${label}"
          return
        fi
      fi
    fi
    cp -R "${src}" "${dest}"
    success "  Copied ${label}"
  fi
}

# ─── Install a file (link or copy) ───────────────────────────────────────────
install_file() {
  local src="$1"
  local dest="$2"
  local label="$3"

  if [[ "${MODE}" == "link" ]]; then
    if [[ -L "${dest}" ]]; then
      rm "${dest}"
    elif [[ -f "${dest}" ]]; then
      if check_conflict "${dest}"; then
        rm "${dest}"
      else
        warn "${label} already exists at ${dest}"
        read -r -p "  Overwrite? [y/N] " confirm
        if [[ "${confirm}" =~ ^[Yy]$ ]]; then
          rm "${dest}"
        else
          warn "  Skipped ${label}"
          return
        fi
      fi
    fi
    ln -s "${src}" "${dest}"
    success "  Linked ${label}"
  else
    if [[ -f "${dest}" ]] || [[ -L "${dest}" ]]; then
      if check_conflict "${dest}"; then
        rm -f "${dest}"
      else
        warn "${label} already exists at ${dest}"
        read -r -p "  Overwrite? [y/N] " confirm
        if [[ "${confirm}" =~ ^[Yy]$ ]]; then
          rm -f "${dest}"
        else
          warn "  Skipped ${label}"
          return
        fi
      fi
    fi
    cp "${src}" "${dest}"
    success "  Copied ${label}"
  fi
}

# ─── Main install ─────────────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}BMAD Framework Installer${NC}"
echo -e "Mode: ${CYAN}${MODE}${NC}"
echo -e "Source: ${SCRIPT_DIR}"
echo -e "Target: ${TARGET_DIR}"
echo ""

info "Installing BMAD components..."

# 1. Commands (slash-command skill definitions)
install_dir "${SOURCE_DIR}/commands" "${TARGET_DIR}/commands" "commands/"

# 2. Templates (project scaffold)
install_dir "${SOURCE_DIR}/bmad-template" "${TARGET_DIR}/bmad-template" "bmad-template/"

# 3. Scripts (init-bmad, claude-feature)
mkdir -p "${TARGET_DIR}/scripts"
install_file "${SOURCE_DIR}/scripts/init-bmad" "${TARGET_DIR}/scripts/init-bmad" "scripts/init-bmad"
chmod +x "${TARGET_DIR}/scripts/init-bmad"
install_file "${SOURCE_DIR}/scripts/claude-feature" "${TARGET_DIR}/scripts/claude-feature" "scripts/claude-feature"
chmod +x "${TARGET_DIR}/scripts/claude-feature"

# 4. Global CLAUDE.md
install_file "${SOURCE_DIR}/CLAUDE.md" "${TARGET_DIR}/CLAUDE.md" "CLAUDE.md"

# ─── PATH setup ──────────────────────────────────────────────────────────────
SCRIPTS_PATH="${TARGET_DIR}/scripts"
PATH_LINE="export PATH=\"\${HOME}/.claude/scripts:\${PATH}\""

# Detect shell config file
if [[ -f "${HOME}/.zshrc" ]]; then
  SHELL_RC="${HOME}/.zshrc"
elif [[ -f "${HOME}/.bashrc" ]]; then
  SHELL_RC="${HOME}/.bashrc"
else
  SHELL_RC=""
fi

if [[ -n "${SHELL_RC}" ]]; then
  if ! grep -qF '/.claude/scripts' "${SHELL_RC}" 2>/dev/null; then
    echo "" >> "${SHELL_RC}"
    echo "# BMAD framework — init-bmad on PATH" >> "${SHELL_RC}"
    echo "${PATH_LINE}" >> "${SHELL_RC}"
    success "Added ~/.claude/scripts to PATH in $(basename "${SHELL_RC}")"
    info "Run: source ${SHELL_RC}  (or open a new terminal)"
  else
    info "PATH already configured in $(basename "${SHELL_RC}")"
  fi
else
  warn "Could not detect shell RC file. Add this to your shell profile:"
  echo "  ${PATH_LINE}"
fi

# ─── Verify ───────────────────────────────────────────────────────────────────
echo ""
info "Verifying installation..."
ERRORS=0

for item in commands bmad-template scripts/init-bmad scripts/claude-feature CLAUDE.md; do
  if [[ -e "${TARGET_DIR}/${item}" ]]; then
    success "  ${item}"
  else
    error "  MISSING: ${item}"
    ERRORS=$((ERRORS + 1))
  fi
done

if [[ ${ERRORS} -gt 0 ]]; then
  error "Installation incomplete — ${ERRORS} item(s) missing."
fi

# ─── Done ─────────────────────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}${BOLD}BMAD framework installed successfully.${NC}"
echo ""
echo -e "${BOLD}Quick start:${NC}"
echo "  cd /path/to/your-project"
echo "  git init                      # if not already a repo"
echo "  init-bmad                     # bootstrap BMAD in the project"
echo "  claude                        # open Claude Code"
echo "  > /epic my-first-feature      # create your first epic"
echo ""
echo -e "${BOLD}Shell commands:${NC}"
echo "  init-bmad              Bootstrap BMAD in any project"
echo "  claude-feature <name>  Launch Claude Code in an isolated worktree"
echo ""
echo -e "${BOLD}Slash commands (inside Claude Code):${NC}"
echo "  /bmad        Full 5-phase orchestration"
echo "  /epic        Create new epic"
echo "  /story       Create or implement a story"
echo "  /implement   Execute stories to completion"
echo "  /explore     Deep codebase exploration"
echo "  /think       Sequential reasoning"
echo "  /review      Code review"
echo "  /simplify    Code complexity reduction"
echo "  /refine      Gap analysis on existing epic"
echo "  /dev         Development environment control"
echo "  /pr          Create pull request"
echo "  /push        Git push"
echo "  /sync        Git sync (fetch + rebase)"
echo "  /status      Project status"
echo ""
if [[ "${MODE}" == "link" ]]; then
  echo -e "${CYAN}Symlink mode:${NC} Run 'git pull' in this repo to update all projects."
else
  echo -e "${CYAN}Copy mode:${NC} Re-run install.sh to pick up framework updates."
fi
echo ""
