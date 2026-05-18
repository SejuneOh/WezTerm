#!/bin/bash

LOG_FILE="$HOME/.claude/logs/session-start.log"
WORKING_DIR=$(pwd)

output() {
    echo "=== Session Context ($(date '+%Y-%m-%d %H:%M:%S')) ==="
    echo "Working directory: $WORKING_DIR"

    # git repo가 아니면 여기서 종료
    if ! git rev-parse --is-inside-work-tree &>/dev/null; then
        echo "(not a git repository)"
        return
    fi

    BRANCH=$(git branch --show-current 2>/dev/null)
    MAIN_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@')
    GIT_STATUS_ALL=$(git status --short 2>/dev/null)
    TOTAL_CHANGED=$(echo "$GIT_STATUS_ALL" | grep -c . 2>/dev/null || echo 0)
    GIT_STATUS=$(echo "$GIT_STATUS_ALL" | head -20)
    RECENT_COMMITS=$(git log --oneline -5 2>/dev/null)
    STASH_COUNT=$(git stash list 2>/dev/null | grep -c .)
    UNPUSHED=$(git log @{u}.. --oneline 2>/dev/null | head -5)

    echo "Current branch: $BRANCH"
    [ -n "$MAIN_BRANCH" ] && echo "Main branch (you will usually use this for PRs): $MAIN_BRANCH"
    echo ""
    echo "Status:"
    if [ "$TOTAL_CHANGED" -eq 0 ]; then
        echo "(clean)"
    else
        echo "$GIT_STATUS"
        [ "$TOTAL_CHANGED" -gt 20 ] && echo "... and $((TOTAL_CHANGED - 20)) more files (truncated)"
    fi
    echo ""
    echo "Recent commits:"
    echo "$RECENT_COMMITS"
    [ "$STASH_COUNT" -gt 0 ] && echo "" && echo "Stashes: $STASH_COUNT stash(es) saved"
    if [ -n "$UNPUSHED" ]; then
        echo ""
        echo "Unpushed commits:"
        echo "$UNPUSHED"
    fi
}

obsidian_context() {
    # Obsidian vault 경로는 머신마다 다를 수 있어 환경변수로 외부화.
    # 설정 안 했으면 obsidian 컨텍스트는 건너뜀.
    VAULT="${CLAUDE_OBSIDIAN_VAULT:-}"
    [ -z "$VAULT" ] && return
    [ -d "$VAULT" ] || return

    REPO=$(basename "$(git rev-parse --show-toplevel 2>/dev/null)" 2>/dev/null)
    [ -z "$REPO" ] && return
    SLUG="${REPO}-$(git branch --show-current 2>/dev/null | tr '/' '-')"
    NOTE="$VAULT/projects/${SLUG}.md"

    if [ -f "$NOTE" ]; then
        echo ""
        echo "=== Obsidian Project Note ==="
        cat "$NOTE"
    fi
}

mkdir -p "$(dirname "$LOG_FILE")"
{ output; obsidian_context; } | tee "$LOG_FILE"
