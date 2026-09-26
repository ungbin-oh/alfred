#!/bin/bash
# written by Ungbin_Oh
# created : 2026-09-26
# updated : 2026-09-26
#
# Alfred — statusline badge. Prints a sky-blue [ALFRED] only inside an Alfred
# workspace (.alfred/workspace marker in the session's directory).
#
# If the user already had a statusLine, alfred-init saves that command to
#   ${CLAUDE_CONFIG_DIR:-~/.claude}/.alfred-statusline-chain
# and this script runs it too, so both badges show side by side.
#
# Color: 256-color code, default 117 (sky blue). Override with ALFRED_COLOR
# (e.g. 114 = green).

INPUT=$(cat)
CONF="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
COLOR="${ALFRED_COLOR:-117}"
case "$COLOR" in ''|*[!0-9]*) COLOR=117 ;; esac

# Previous statusline (chained). Refuse symlinks; run as a plain command line.
CHAIN_FILE="$CONF/.alfred-statusline-chain"
PREV=""
if [ -f "$CHAIN_FILE" ] && [ ! -L "$CHAIN_FILE" ]; then
  CHAIN_CMD=$(head -c 1024 "$CHAIN_FILE" | tr -d '\000-\037')
  [ -n "$CHAIN_CMD" ] && PREV=$(printf '%s' "$INPUT" | sh -c "$CHAIN_CMD" 2>/dev/null)
fi

# Session directory from the statusline JSON, without jq/python.
DIR=$(printf '%s' "$INPUT" | tr -d '\n' | sed -n 's/.*"current_dir"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')
[ -z "$DIR" ] && DIR=$(printf '%s' "$INPUT" | tr -d '\n' | sed -n 's/.*"cwd"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')

BADGE=""
if [ -n "$DIR" ] && [ -f "$DIR/.alfred/workspace" ]; then
  BADGE=$(printf '\033[38;5;%sm[ALFRED]\033[0m' "$COLOR")
fi

if [ -n "$PREV" ] && [ -n "$BADGE" ]; then
  printf '%s %s' "$PREV" "$BADGE"
else
  printf '%s%s' "$PREV" "$BADGE"
fi
