#!/usr/bin/env bash
#
# Install script for WezTerm + Neovim dotfiles.
#
# Behavior:
#   - Verifies prerequisites (nvim >= 0.10, git, ripgrep, node, wezterm).
#   - Warns about optional tools (dotnet for C# LSP, lazygit for git UI).
#   - Backs up any existing configs to *.backup-TIMESTAMP.
#   - Symlinks wezterm/.wezterm.lua → ~/.wezterm.lua
#   - Symlinks nvim/ → ~/.config/nvim
#   - Runs nvim --headless to bootstrap lazy.nvim plugins.
#
# Usage:
#   bash scripts/install.sh               # normal install
#   bash scripts/install.sh --dry-run     # show planned actions only
#   bash scripts/install.sh --uninstall   # remove symlinks (keeps backups)
#   bash scripts/install.sh --help
#
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
DRY_RUN=0
MODE="install"

info()  { printf "\033[1;34m[info]\033[0m  %s\n" "$*"; }
warn()  { printf "\033[1;33m[warn]\033[0m  %s\n" "$*"; }
error() { printf "\033[1;31m[error]\033[0m %s\n" "$*" >&2; }
plan()  { printf "\033[1;36m[plan]\033[0m  %s\n" "$*"; }

usage() {
  sed -n '2,17p' "$0" | sed 's/^# \{0,1\}//'
  exit 0
}

parse_args() {
  for arg in "$@"; do
    case "$arg" in
      --dry-run)   DRY_RUN=1 ;;
      --uninstall) MODE="uninstall" ;;
      -h|--help)   usage ;;
      *)           error "Unknown option: $arg"; exit 2 ;;
    esac
  done
}

run() {
  # Executes a command, or prints it when --dry-run is set.
  if [[ "$DRY_RUN" -eq 1 ]]; then
    plan "$*"
  else
    eval "$@"
  fi
}

check_cmd() {
  local cmd="$1"
  if ! command -v "$cmd" >/dev/null 2>&1; then
    error "$cmd is not installed."
    return 1
  fi
  info "$cmd found: $(command -v "$cmd")"
}

check_cmd_optional() {
  # Like check_cmd but emits a warn (with install hint) instead of failing.
  local cmd="$1"
  local hint="$2"
  if ! command -v "$cmd" >/dev/null 2>&1; then
    warn "$cmd not found — $hint"
    return 0
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

  local major minor
  IFS='.' read -r major minor _ <<< "$version"
  # Reject only 0.x with x < 10. Any 1.0+ passes.
  if (( major == 0 && minor < 10 )); then
    error "Neovim version $version is too old. Please install 0.10 or newer."
    return 1
  fi
}

link_config() {
  local src="$1"
  local dest="$2"

  if [[ -L "$dest" ]]; then
    info "Removing old symlink: $dest"
    run "rm '$dest'"
  elif [[ -e "$dest" ]]; then
    local backup="${dest}.backup-${TIMESTAMP}"
    warn "Backing up existing $dest → $backup"
    run "mv '$dest' '$backup'"
  fi

  run "mkdir -p '$(dirname "$dest")'"
  run "ln -s '$src' '$dest'"
  info "Linked $src → $dest"
}

unlink_config() {
  local dest="$1"
  if [[ -L "$dest" ]]; then
    info "Removing symlink: $dest"
    run "rm '$dest'"
  elif [[ -e "$dest" ]]; then
    warn "Not a symlink, skipping: $dest (leave user files alone)"
  else
    info "Nothing to remove at: $dest"
  fi
}

do_install() {
  info "Repo: $REPO_DIR"
  [[ "$DRY_RUN" -eq 1 ]] && info "DRY-RUN mode: no files will be modified."

  info "Checking required prerequisites..."
  check_nvim_version || exit 1
  check_cmd git      || exit 1

  info "Checking optional prerequisites..."
  check_cmd_optional rg      "Telescope live grep will not work. Install: sudo apt install ripgrep"
  check_cmd_optional node    "LSP servers may fail to install. Install via nvm (see README)."
  check_cmd_optional wezterm "OK if you launch WezTerm from a GUI (Windows/macOS)."
  check_cmd_optional dotnet  "C# LSP (omnisharp) and formatter (csharpier) will not work. Install: sudo apt install dotnet-sdk-8.0"
  check_cmd_optional lazygit "Lazygit keybinding (<leader>gg) will not work. Install: https://github.com/jesseduffield/lazygit#installation"

  info "Linking WezTerm config..."
  link_config "$REPO_DIR/wezterm/.wezterm.lua" "$HOME/.wezterm.lua"

  info "Linking Neovim config..."
  link_config "$REPO_DIR/nvim" "$HOME/.config/nvim"

  info "Bootstrapping Neovim plugins (this may take a minute)..."
  if [[ "$DRY_RUN" -eq 1 ]]; then
    plan "nvim --headless '+Lazy! sync' +qa"
  else
    nvim --headless "+Lazy! sync" +qa 2>&1 | tail -5 \
      || warn "Lazy sync returned non-zero; inspect with :Lazy inside Neovim."
  fi

  info "Done. Launch Neovim with 'nvim' to verify."
}

do_uninstall() {
  info "Uninstalling symlinks (backups from previous installs are preserved)..."
  [[ "$DRY_RUN" -eq 1 ]] && info "DRY-RUN mode: no files will be modified."

  unlink_config "$HOME/.wezterm.lua"
  unlink_config "$HOME/.config/nvim"

  info "Done. Restore a backup manually if needed:"
  info "  ls -la ~/.wezterm.lua.backup-* ~/.config/nvim.backup-* 2>/dev/null"
}

main() {
  parse_args "$@"
  case "$MODE" in
    install)   do_install ;;
    uninstall) do_uninstall ;;
  esac
}

main "$@"
