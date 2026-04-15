#!/usr/bin/env bash
#
# Install script for WezTerm + Neovim dotfiles.
#
# Behavior:
#   - Verifies prerequisites (nvim >= 0.10, git, ripgrep, node, wezterm).
#   - Backs up any existing configs to *.backup-TIMESTAMP.
#   - Symlinks wezterm/.wezterm.lua → ~/.wezterm.lua
#   - Symlinks nvim/ → ~/.config/nvim
#   - Runs nvim --headless to bootstrap lazy.nvim plugins.
#
# Usage:
#   bash scripts/install.sh
#
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"

info()  { printf "\033[1;34m[info]\033[0m  %s\n" "$*"; }
warn()  { printf "\033[1;33m[warn]\033[0m  %s\n" "$*"; }
error() { printf "\033[1;31m[error]\033[0m %s\n" "$*" >&2; }

check_cmd() {
  local cmd="$1"
  local min="${2:-}"
  if ! command -v "$cmd" >/dev/null 2>&1; then
    error "$cmd is not installed."
    return 1
  fi
  info "$cmd found: $(command -v "$cmd")"
}

check_nvim_version() {
  if ! command -v nvim >/dev/null 2>&1; then
    error "Neovim is not installed. Required: >= 0.10"
    return 1
  fi
  local version
  version="$(nvim --version | head -1 | sed 's/[^0-9.]*\([0-9][0-9.]*\).*/\1/')"
  info "Neovim version: $version"

  # Compare major.minor: 0.10 required
  local major minor
  IFS='.' read -r major minor _ <<< "$version"
  if [[ "$major" -lt 1 && "$minor" -lt 10 ]]; then
    error "Neovim version $version is too old. Please install 0.10 or newer."
    return 1
  fi
}

link_config() {
  local src="$1"
  local dest="$2"

  if [[ -L "$dest" ]]; then
    info "Removing old symlink: $dest"
    rm "$dest"
  elif [[ -e "$dest" ]]; then
    local backup="${dest}.backup-${TIMESTAMP}"
    warn "Backing up existing $dest → $backup"
    mv "$dest" "$backup"
  fi

  mkdir -p "$(dirname "$dest")"
  ln -s "$src" "$dest"
  info "Linked $src → $dest"
}

main() {
  info "Repo: $REPO_DIR"

  info "Checking prerequisites..."
  check_nvim_version || exit 1
  check_cmd git      || exit 1
  check_cmd rg       || warn "ripgrep missing — Telescope live grep will not work."
  check_cmd node     || warn "Node.js missing — LSP servers may fail to install."
  check_cmd wezterm  || warn "WezTerm not found in PATH — OK if you run it from a GUI."

  info "Linking WezTerm config..."
  link_config "$REPO_DIR/wezterm/.wezterm.lua" "$HOME/.wezterm.lua"

  info "Linking Neovim config..."
  link_config "$REPO_DIR/nvim" "$HOME/.config/nvim"

  info "Bootstrapping Neovim plugins (this may take a minute)..."
  nvim --headless "+Lazy! sync" +qa 2>&1 | tail -5 || warn "Lazy sync returned non-zero; inspect with :Lazy inside Neovim."

  info "Done. Launch Neovim with 'nvim' to verify."
}

main "$@"
