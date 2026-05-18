#!/usr/bin/env bash
#
# install-claude.sh — symlink this repo's claude/ tree into ~/.claude/.
#
# Mirrors the nvim/wezterm setup pattern: source of truth lives in this repo,
# the user's actual Claude config (~/.claude/) is symlinks pointing back here.
#
# Idempotent. Backs up any pre-existing real file/dir as <name>.bak-<timestamp>
# before replacing it with a symlink.
#
# Special handling:
#   - settings.json is COPIED (not symlinked) so the install can substitute
#     __HOME__ tokens with the user's actual $HOME. Re-run this script after
#     editing claude/settings.json to refresh ~/.claude/settings.json.
#   - skills/project-launcher/projects.json is COPIED from .example on first
#     run only; subsequent runs leave the user's edited registry alone.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SRC="$REPO_DIR/claude"
DEST="$HOME/.claude"
TS="$(date +%Y%m%d-%H%M%S)"

DRY_RUN=0
for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=1 ;;
    -h|--help)
      cat <<USAGE
install-claude.sh — link this repo's claude/ tree into ~/.claude/.

Usage: $0 [--dry-run]

What it does:
  - Symlinks: CLAUDE.md, statusline-command.sh, usage-fetch.py,
              agents/, hooks/, skills/ (each skill folder individually)
  - Copies (with __HOME__ -> \$HOME substitution): settings.json
  - Seeds skills/project-launcher/projects.json from .example on first run

Existing real files in ~/.claude/ are backed up as <name>.bak-YYYYmmdd-HHMMSS
before being replaced.

After install, ensure these env vars are set in your shell rc (only if you
use the corresponding skill / hook):
  export CLAUDE_OBSIDIAN_VAULT="/mnt/c/dev/note/Obsidian"     # obsidian skill, session-start hook
  export CLAUDE_PR_TEMPLATE_PATH="/path/to/PR_template.md"     # pr-draft skill
  export CLAUDE_PR_OUTPUT_DIR="/path/to/PR/output/dir"         # pr-draft skill
USAGE
      exit 0
      ;;
    *) echo "unknown arg: $arg" >&2; exit 2 ;;
  esac
done

run() {
  if [ "$DRY_RUN" -eq 1 ]; then
    echo "[dry-run] $*"
  else
    eval "$@"
  fi
}

# Back up an existing file/dir at $1 if it's a real (non-symlink) entry,
# or if it's a symlink that doesn't already point at $2.
backup_if_needed() {
  local target="$1" desired_link="$2"
  if [ -L "$target" ]; then
    local current
    current="$(readlink "$target")"
    if [ "$current" = "$desired_link" ]; then
      return 1  # already correct, caller can skip
    fi
    echo "  backing up existing symlink: $target -> $target.bak-$TS"
    run "mv \"$target\" \"$target.bak-$TS\""
  elif [ -e "$target" ]; then
    echo "  backing up existing file/dir: $target -> $target.bak-$TS"
    run "mv \"$target\" \"$target.bak-$TS\""
  fi
  return 0
}

link_into_dest() {
  local src_rel="$1"
  local src="$SRC/$src_rel"
  local target="$DEST/$src_rel"
  local target_parent
  target_parent="$(dirname "$target")"

  [ -e "$src" ] || { echo "skip (source missing): $src_rel"; return; }

  run "mkdir -p \"$target_parent\""
  if backup_if_needed "$target" "$src"; then
    run "ln -s \"$src\" \"$target\""
    echo "  linked: ~/.claude/$src_rel"
  else
    echo "  already linked: ~/.claude/$src_rel"
  fi
}

echo "Installing Claude config from $REPO_DIR/claude/ into $DEST/"
[ "$DRY_RUN" -eq 1 ] && echo "(dry-run — no changes will be made)"

run "mkdir -p \"$DEST\""

# 1. Symlinks (single files at the top level)
echo
echo "[1/4] Linking top-level files..."
link_into_dest "CLAUDE.md"
link_into_dest "statusline-command.sh"
link_into_dest "usage-fetch.py"

# 2. Symlinks (whole directories)
echo
echo "[2/4] Linking directories (agents, hooks)..."
link_into_dest "agents"
link_into_dest "hooks"

# 3. Symlinks per skill (so user can mix repo skills with extra local skills)
echo
echo "[3/4] Linking skills..."
run "mkdir -p \"$DEST/skills\""
for skill_dir in "$SRC/skills"/*/; do
  [ -d "$skill_dir" ] || continue
  skill_name="$(basename "$skill_dir")"
  link_into_dest "skills/$skill_name"
done

# 4. settings.json — copy with __HOME__ substitution (NOT symlink)
echo
echo "[4/4] Installing settings.json (with \$HOME substitution)..."
settings_src="$SRC/settings.json"
settings_dest="$DEST/settings.json"
if [ ! -f "$settings_src" ]; then
  echo "  skip: $settings_src not found"
else
  if [ -e "$settings_dest" ] && [ ! -L "$settings_dest" ]; then
    echo "  backing up existing settings.json -> settings.json.bak-$TS"
    run "cp \"$settings_dest\" \"$settings_dest.bak-$TS\""
  elif [ -L "$settings_dest" ]; then
    echo "  removing existing settings.json symlink"
    run "rm \"$settings_dest\""
  fi
  # Substitute __HOME__ -> $HOME. Use # as sed delimiter so / in $HOME is fine.
  run "sed \"s#__HOME__#$HOME#g\" \"$settings_src\" > \"$settings_dest\""
  echo "  wrote: ~/.claude/settings.json"
fi

# 5. project-launcher: seed projects.json from .example on first run
echo
example="$SRC/skills/project-launcher/projects.json.example"
real_in_dest="$DEST/skills/project-launcher/projects.json"
if [ -f "$example" ] && [ ! -e "$real_in_dest" ]; then
  # We can't write into the symlinked skill dir directly because the dir
  # itself is a symlink to the repo. So drop the real file into the repo
  # (it's .gitignored).
  real_in_repo="$SRC/skills/project-launcher/projects.json"
  if [ ! -e "$real_in_repo" ]; then
    echo "Seeding project-launcher/projects.json from .example"
    run "cp \"$example\" \"$real_in_repo\""
    echo "  edit it at: $real_in_repo"
  fi
fi

echo
echo "Done."
echo
echo "Reminder: set these in your shell rc (only the ones you use):"
echo "  export CLAUDE_OBSIDIAN_VAULT=\"/path/to/Obsidian/vault\""
echo "  export CLAUDE_PR_TEMPLATE_PATH=\"/path/to/PR_template.md\""
echo "  export CLAUDE_PR_OUTPUT_DIR=\"/path/to/PR/output/dir\""
