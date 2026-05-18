#!/usr/bin/env bash
# Claude Code statusLine — two lines.
#
# Line 1: ~/dir · branch [+42 -10 ↑3 ↓1 ?2 ●1] · Model · 5h:3h22m · 7d:4d12h [· extra $X.XX/$50]
# Line 2: ctx ▰▰▱▱▱▱▱▱▱▱ 23%  ·  5h ▰▰▰▱▱▱▱▱▱▱ 31%  ·  7d ▰▱▱▱▱▱▱▱▱▱  8%
#
# Data sources:
#   ctx          context tokens from active transcript (last assistant turn usage)
#   5h / 7d %    Anthropic /api/oauth/usage → {five_hour,seven_day}.utilization
#   5h / 7d time reset countdown from {five_hour,seven_day}.resets_at
#   extra        extra_usage.used_credits / monthly_limit (shown only when > 0)
#   git counts   diff --shortstat (+/-), status --porcelain (?), rev-list (↑↓), diff --cached (●)
#                — all omit zero, so a clean repo shows nothing
#
# Usage values come from ~/.claude/usage-fetch.py, which calls
# https://api.anthropic.com/api/oauth/usage with the OAuth token from
# ~/.claude/.credentials.json. Cached under $XDG_CACHE_HOME/claude-statusline/.
# Ported from ccstatusline (sirmalloc/ccstatusline, MIT) — see usage-fetch.py.
#
# Tunable via env (set in your shell rc):
#   CC_CONTEXT_LIMIT   context window (default 200000; auto-bumps to 1000000 for [1m] models)
#   CC_USAGE_REFRESH   usage cache TTL in seconds (default 180)

set -u

CONTEXT_LIMIT="${CC_CONTEXT_LIMIT:-200000}"
USAGE_TTL="${CC_USAGE_REFRESH:-180}"

CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/claude-statusline"
mkdir -p "$CACHE_DIR" 2>/dev/null

input=$(cat)

# --- JSON parsing (jq-free) --------------------------------------------------
# read_json "<dotted.path>" -> echoes the string value or empty
read_json() {
  CC_INPUT="$input" CC_PATH="$1" python3 - <<'PY'
import json, os
try:
    d = json.loads(os.environ.get("CC_INPUT", ""))
    for k in os.environ["CC_PATH"].split("."):
        if not isinstance(d, dict): d = None; break
        d = d.get(k)
    print("" if d is None else d)
except Exception:
    print("")
PY
}

cwd=$(read_json "workspace.current_dir")
[ -z "$cwd" ] && cwd=$(read_json "cwd")
model=$(read_json "model.display_name")
model_id=$(read_json "model.id")
transcript=$(read_json "transcript_path")

# Auto-bump context limit for 1M-context models if user hasn't overridden.
if [ -z "${CC_CONTEXT_LIMIT:-}" ] && [[ "$model_id" == *"[1m]"* || "$model" == *"1M"* ]]; then
  CONTEXT_LIMIT=1000000
fi

# --- LINE 1: dir · branch · model · time -------------------------------------
home="$HOME"
if [[ "$cwd" == "$home" ]]; then
  dir_display="~"
elif [[ -n "$cwd" && "$cwd" == "$home/"* ]]; then
  dir_display="~${cwd#$home}"
else
  dir_display="${cwd:-?}"
fi

branch=""
if [ -n "$cwd" ] && git -C "$cwd" rev-parse --is-inside-work-tree --no-optional-locks &>/dev/null; then
  branch=$(git --no-optional-locks -C "$cwd" symbolic-ref --short HEAD 2>/dev/null \
           || git --no-optional-locks -C "$cwd" rev-parse --short HEAD 2>/dev/null)
fi

# Git status: insertions/deletions, ahead/behind, untracked, staged.
# Each count is hidden when zero — a clean repo shows nothing extra.
git_ins=0; git_del=0; git_ahead=0; git_behind=0; git_untracked=0; git_staged=0
if [ -n "$branch" ]; then
  # Insertions/deletions (unstaged + uncommitted)
  shortstat=$(git --no-optional-locks -C "$cwd" diff --shortstat 2>/dev/null)
  if [ -n "$shortstat" ]; then
    git_ins=$(echo "$shortstat" | awk '{for(i=1;i<=NF;i++) if($i~/insertion/){print $(i-1); exit}}')
    git_del=$(echo "$shortstat" | awk '{for(i=1;i<=NF;i++) if($i~/deletion/){print $(i-1); exit}}')
    : "${git_ins:=0}"; : "${git_del:=0}"
  fi

  # Ahead/behind vs upstream  ("<behind>\t<ahead>")
  upstream_count=$(git --no-optional-locks -C "$cwd" rev-list --left-right --count "@{upstream}...HEAD" 2>/dev/null)
  if [ -n "$upstream_count" ]; then
    git_behind=$(echo "$upstream_count" | awk '{print $1+0}')
    git_ahead=$(echo "$upstream_count"  | awk '{print $2+0}')
  fi

  # Untracked file count (porcelain rows starting with "??")
  porcelain=$(git --no-optional-locks -C "$cwd" status --porcelain 2>/dev/null)
  if [ -n "$porcelain" ]; then
    git_untracked=$(echo "$porcelain" | awk '/^\?\?/{c++} END{print c+0}')
  fi

  # Staged file count
  git_staged=$(git --no-optional-locks -C "$cwd" diff --cached --name-only 2>/dev/null | awk 'END{print NR}')
fi

# Placeholder; populated below after USAGE_CACHE is guaranteed to exist.
block_remaining=""
weekly_remaining=""
extra_display=""

CYAN=$'\033[36m'; YELLOW=$'\033[33m'; MAGENTA=$'\033[35m'
GREEN=$'\033[32m'; RED=$'\033[31m';   BLUE=$'\033[34m'
GRAY=$'\033[90m'; RESET=$'\033[0m'
SEP="${RESET}  ·  "

line1="${CYAN}${dir_display}${RESET}"
if [ -n "$branch" ]; then
  line1+="${SEP}${YELLOW}${branch}${RESET}"
  # Git indicators: only non-zero shown, space-separated (no SEP between them).
  [ "$git_ins" -gt 0 ]       && line1+=" ${GREEN}+${git_ins}${RESET}"
  [ "$git_del" -gt 0 ]       && line1+=" ${RED}-${git_del}${RESET}"
  [ "$git_ahead" -gt 0 ]     && line1+=" ${YELLOW}↑${git_ahead}${RESET}"
  [ "$git_behind" -gt 0 ]    && line1+=" ${RED}↓${git_behind}${RESET}"
  [ "$git_untracked" -gt 0 ] && line1+=" ${GRAY}?${git_untracked}${RESET}"
  [ "$git_staged" -gt 0 ]    && line1+=" ${CYAN}●${git_staged}${RESET}"
fi
[ -n "$model"  ] && line1+="${SEP}${MAGENTA}${model}${RESET}"
# block_remaining, weekly_remaining, extra_display are appended after cache is populated.

# --- helpers: stale-while-revalidate caching ---------------------------------
file_age() {
  local f="$1"
  [ -f "$f" ] || { echo 999999999; return; }
  local mtime
  mtime=$(stat -c %Y "$f" 2>/dev/null || stat -f %m "$f" 2>/dev/null || echo 0)
  echo $(( $(date +%s) - mtime ))
}

refresh_async() {
  # refresh_async <cache_file> <cmd...>
  local f="$1"; shift
  local lock="${f}.lock"
  # nonblocking: skip if another refresh is already running
  ( flock -n 9 || exit 0
    "$@" > "${f}.tmp" 2>/dev/null && mv "${f}.tmp" "$f"
  ) 9>"$lock" </dev/null >/dev/null 2>&1 &
  disown 2>/dev/null || true
}

ensure_cache() {
  # ensure_cache <cache_file> <ttl> <cmd...>
  local f="$1" ttl="$2"; shift 2
  local age; age=$(file_age "$f")
  if [ ! -f "$f" ]; then
    # cold start — run synchronously so first render has data (slow once)
    "$@" > "${f}.tmp" 2>/dev/null && mv "${f}.tmp" "$f"
  elif [ "$age" -gt "$ttl" ]; then
    refresh_async "$f" "$@"
  fi
}

USAGE_CACHE="$CACHE_DIR/usage.json"

ensure_cache "$USAGE_CACHE" "$USAGE_TTL" python3 "$HOME/.claude/usage-fetch.py"

# --- context %: parse transcript tail ----------------------------------------
context_pct=0
context_tokens=0
if [ -n "$transcript" ] && [ -f "$transcript" ]; then
  read context_tokens context_pct <<<"$(
    CC_FILE="$transcript" CC_LIMIT="$CONTEXT_LIMIT" python3 - <<'PY'
import json, os
total = 0
try:
    with open(os.environ["CC_FILE"], "r", encoding="utf-8", errors="ignore") as fh:
        lines = fh.readlines()[-200:]
    for line in reversed(lines):
        try:
            obj = json.loads(line)
        except Exception:
            continue
        msg = obj.get("message") or {}
        usage = msg.get("usage") or obj.get("usage")
        if usage:
            total = (
                int(usage.get("input_tokens") or 0)
                + int(usage.get("cache_read_input_tokens") or 0)
                + int(usage.get("cache_creation_input_tokens") or 0)
            )
            if total > 0:
                break
except Exception:
    pass
limit = int(os.environ.get("CC_LIMIT") or 200000) or 200000
pct = max(0, min(100, total * 100 // limit)) if total else 0
print(f"{total} {pct}")
PY
  )"
fi

# --- 5h block: utilization % AND time remaining ("3h 22m left") --------------
# Both come from Anthropic /api/oauth/usage → five_hour bucket.
read block_pct block_remaining <<<"$(CC_FILE="$USAGE_CACHE" python3 - <<'PY'
import json, os, datetime
def fmt_remaining(secs):
    secs = max(0, int(secs))
    h, rem = divmod(secs, 3600)
    m = rem // 60
    if h and m: return f"{h}h_{m}m"
    if h:       return f"{h}h"
    return f"{m}m"
try:
    with open(os.environ["CC_FILE"]) as f:
        d = json.load(f)
    fh = d.get("five_hour") or {}
    pct = max(0, min(100, int(round(float(fh.get("utilization") or 0)))))
    resets_at = fh.get("resets_at")
    if resets_at:
        e = datetime.datetime.fromisoformat(resets_at.replace("Z", "+00:00"))
        now = datetime.datetime.now(datetime.timezone.utc)
        remaining = fmt_remaining((e - now).total_seconds())
    else:
        remaining = "—"
    print(pct, remaining)
except Exception:
    print(0, "—")
PY
)"
# Restore spaces in the remaining-time label (we used _ to survive `read` splitting).
block_remaining="${block_remaining//_/ }"

# Append 5h block remaining-time to line 1 ("5h:" prefix).
line1+="${SEP}${GRAY}5h:${block_remaining}${RESET}"

# --- 7d %: utilization + reset countdown from seven_day bucket ---------------
read weekly_pct weekly_remaining <<<"$(CC_FILE="$USAGE_CACHE" python3 - <<'PY'
import json, os, datetime
def fmt_remaining(secs):
    secs = max(0, int(secs))
    days, rem = divmod(secs, 86400)
    h, rem = divmod(rem, 3600)
    m = rem // 60
    if days and h: return f"{days}d_{h}h"
    if days:       return f"{days}d"
    if h and m:    return f"{h}h_{m}m"
    if h:          return f"{h}h"
    return f"{m}m"
try:
    with open(os.environ["CC_FILE"]) as f:
        d = json.load(f)
    sd = d.get("seven_day") or {}
    pct = max(0, min(100, int(round(float(sd.get("utilization") or 0)))))
    resets_at = sd.get("resets_at")
    if resets_at:
        e = datetime.datetime.fromisoformat(resets_at.replace("Z", "+00:00"))
        now = datetime.datetime.now(datetime.timezone.utc)
        remaining = fmt_remaining((e - now).total_seconds())
    else:
        remaining = "—"
    print(pct, remaining)
except Exception:
    print(0, "—")
PY
)"
weekly_remaining="${weekly_remaining//_/ }"

# Append 7d weekly reset countdown to line 1 (when API provided it).
[ -n "$weekly_remaining" ] && [ "$weekly_remaining" != "—" ] && line1+="${SEP}${GRAY}7d:${weekly_remaining}${RESET}"

# --- Extra usage (pay-as-you-go overage). Hidden when used_credits == 0. -----
extra_display=$(CC_FILE="$USAGE_CACHE" python3 - <<'PY'
import json, os
try:
    with open(os.environ["CC_FILE"]) as f:
        d = json.load(f)
    eu = d.get("extra_usage") or {}
    if not eu.get("is_enabled"):
        print("")
    else:
        used = float(eu.get("used_credits") or 0)
        if used <= 0:
            print("")
        else:
            limit_cents = eu.get("monthly_limit")
            if limit_cents:
                print(f"extra ${used:.2f}/${limit_cents/100:.0f}")
            else:
                print(f"extra ${used:.2f}")
except Exception:
    print("")
PY
)
[ -n "$extra_display" ] && line1+="${SEP}${YELLOW}${extra_display}${RESET}"

# --- progress bar renderer ---------------------------------------------------
# bar <pct> <base_color>   (yellow at 60+, red at 80+)
bar() {
  local pct=$1 base=$2
  local filled=$(( pct / 10 ))
  (( filled > 10 )) && filled=10
  (( filled < 0  )) && filled=0
  local empty=$(( 10 - filled ))
  local color="$base"
  if   (( pct >= 80 )); then color="$RED"
  elif (( pct >= 60 )); then color="$YELLOW"
  fi
  local out=""
  local i
  for (( i=0; i<filled; i++ )); do out+="▰"; done
  for (( i=0; i<empty;  i++ )); do out+="▱"; done
  printf "%s%s%s" "$color" "$out" "$RESET"
}

# Pad percentage to 3 chars so bars stay aligned (e.g. "  7%", " 23%", "100%").
pct_fmt() { printf "%3d%%" "$1"; }

ctx_bar=$(bar "$context_pct" "$GREEN")
blk_bar=$(bar "$block_pct"   "$BLUE")
wk_bar=$(bar  "$weekly_pct"  "$MAGENTA")

line2="${GRAY}ctx${RESET} ${ctx_bar} ${GRAY}$(pct_fmt "$context_pct")${RESET}"
line2+="${SEP}${GRAY}5h${RESET}  ${blk_bar} ${GRAY}$(pct_fmt "$block_pct")${RESET}"
line2+="${SEP}${GRAY}7d${RESET}  ${wk_bar} ${GRAY}$(pct_fmt "$weekly_pct")${RESET}"

printf "%b\n%b" "$line1" "$line2"
