#!/usr/bin/env bash
# uninstall.sh — Remove BMAD framework from ~/.claude/
# Only removes BMAD-specific items (commands, bmad-template, scripts, CLAUDE.md)
# Does NOT touch ~/.claude/settings.json, memory/, projects/, or other user data

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

info()    { echo -e "\033[0;34m[bmad]${NC} $*"; }
success() { echo -e "${GREEN}[bmad]${NC} $*"; }
warn()    { echo -e "${YELLOW}[bmad]${NC} $*"; }

TARGET_DIR="${HOME}/.claude"

echo ""
echo -e "${BOLD}BMAD Framework Uninstaller${NC}"
echo ""
echo "This will remove from ${TARGET_DIR}:"
echo "  - commands/        (slash-command definitions)"
echo "  - bmad-template/   (project scaffold templates)"
echo "  - scripts/init-bmad"
echo "  - CLAUDE.md        (global BMAD instructions)"
echo ""
echo -e "${YELLOW}Your project-level bmad/ directories and CLAUDE.md files are NOT affected.${NC}"
echo ""
read -r -p "Continue? [y/N] " confirm
[[ "${confirm}" =~ ^[Yy]$ ]] || { info "Aborted."; exit 0; }

# Remove BMAD components
for item in commands bmad-template; do
  if [[ -e "${TARGET_DIR}/${item}" ]] || [[ -L "${TARGET_DIR}/${item}" ]]; then
    rm -rf "${TARGET_DIR}/${item}"
    success "Removed ${item}/"
  fi
done

if [[ -e "${TARGET_DIR}/scripts/init-bmad" ]] || [[ -L "${TARGET_DIR}/scripts/init-bmad" ]]; then
  rm -f "${TARGET_DIR}/scripts/init-bmad"
  success "Removed scripts/init-bmad"
  # Remove scripts/ dir if now empty
  rmdir "${TARGET_DIR}/scripts" 2>/dev/null && success "Removed empty scripts/" || true
fi

if [[ -e "${TARGET_DIR}/CLAUDE.md" ]] || [[ -L "${TARGET_DIR}/CLAUDE.md" ]]; then
  rm -f "${TARGET_DIR}/CLAUDE.md"
  success "Removed CLAUDE.md"
fi

# Clean PATH from shell RC
for rc in "${HOME}/.zshrc" "${HOME}/.bashrc"; do
  if [[ -f "${rc}" ]] && grep -qF '/.claude/scripts' "${rc}"; then
    # Remove the PATH line and the comment above it
    sed -i.bak '/# BMAD framework/d; /\.claude\/scripts/d' "${rc}" && rm -f "${rc}.bak"
    success "Cleaned PATH from $(basename "${rc}")"
  fi
done

echo ""
echo -e "${GREEN}${BOLD}BMAD framework uninstalled.${NC}"
echo "Your project-level bmad/ directories remain intact."
echo ""
