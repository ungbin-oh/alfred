#!/bin/bash
# written by Ungbin_Oh
# created : 2026-09-26
# updated : 2026-11-26
#
# Alfred — statusline badge. Prints a sky-blue [ALFRED] only inside an Alfred
# workspace (.alfred/workspace marker in the session's directory).
#
# Default (0.4.5 on): alfred-init copies this script to <workspace>/.alfred/statusline.sh and points the
# workspace's own .claude/settings.local.json statusLine at it, so the global ~/.claude/settings.json is never
# touched and the badge shows only in that workspace. A workspace statusLine replaces the global one there,
# so alfred-init saves the global statusLine command to <workspace>/.alfred/statusline-chain and this script
# runs it first — both show side by side.
#
# Older global setup (before 0.4.5): the global statusLine pointed at ~/.claude/alfred-statusline.sh and the
# previous command was saved to ${CLAUDE_CONFIG_DIR:-~/.claude}/.alfred-statusline-chain. Still honored.
#
# Color: 256-color code, default 117 (sky blue). Override with ALFRED_COLOR
# (e.g. 114 = green).
#
# While logviser is on (.alfred/logviser), an orange [LOGVISER] badge follows, with the projects over their threshold:
# [LOGVISER INC 9 · THS 12] ([LOGVISER-lite …] / [LOGVISER-auto …] for those levels). Counted the same way as hooks/logviser.sh. Color: LOGVISER_COLOR, default 215.

INPUT=$(cat)
CONF="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
COLOR="${ALFRED_COLOR:-117}"
case "$COLOR" in ''|*[!0-9]*) COLOR=117 ;; esac

# Session directory from the statusline JSON, without jq/python.
DIR=$(printf '%s' "$INPUT" | tr -d '\n' | sed -n 's/.*"current_dir"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')
[ -z "$DIR" ] && DIR=$(printf '%s' "$INPUT" | tr -d '\n' | sed -n 's/.*"cwd"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')

# Previous statusline (chained): the workspace's saved global command first, else the older global chain file.
# Refuse symlinks; run as a plain command line; never run a chain that points back at an Alfred badge script.
CHAIN_FILE=""
if [ -n "$DIR" ] && [ -f "$DIR/.alfred/statusline-chain" ]; then
  CHAIN_FILE="$DIR/.alfred/statusline-chain"
elif [ -f "$CONF/.alfred-statusline-chain" ]; then
  CHAIN_FILE="$CONF/.alfred-statusline-chain"
fi
PREV=""
if [ -n "$CHAIN_FILE" ] && [ ! -L "$CHAIN_FILE" ]; then
  CHAIN_CMD=$(head -c 1024 "$CHAIN_FILE" | tr -d '\000-\037')
  case "$CHAIN_CMD" in
    *alfred-statusline.sh*|*.alfred/statusline.sh*) CHAIN_CMD="" ;;
  esac
  [ -n "$CHAIN_CMD" ] && PREV=$(printf '%s' "$INPUT" | sh -c "$CHAIN_CMD" 2>/dev/null)
fi

BADGE=""
if [ -n "$DIR" ] && [ -f "$DIR/.alfred/workspace" ]; then
  BADGE=$(printf '\033[38;5;%sm[ALFRED]\033[0m' "$COLOR")
fi

# logviser badge: projects whose traces not carried into log.md reach the threshold (same count as hooks/logviser.sh)
if [ -n "$BADGE" ] && [ -f "$DIR/.alfred/logviser" ]; then
  LV_COLOR="${LOGVISER_COLOR:-215}"
  case "$LV_COLOR" in ''|*[!0-9]*) LV_COLOR=215 ;; esac
  LV_TAG="LOGVISER"
  [ "$(tr -d '[:space:]' < "$DIR/.alfred/logviser")" = "lite" ] && LV_TAG="LOGVISER-lite"
  [ "$(tr -d '[:space:]' < "$DIR/.alfred/logviser")" = "auto" ] && LV_TAG="LOGVISER-auto"
  OVER=""
  if [ -d "$DIR/project-logs" ]; then
    OVER=$(find "$DIR/project-logs" -name log.md -not -path '*/Archive/*' 2>/dev/null | sort | while IFS= read -r LOGMD; do
      PDIR=$(dirname "$LOGMD")
      CODE=$(awk 'NR>1&&/^---/{exit} /^code:/{sub(/^code:[[:space:]]*/,""); sub(/[[:space:]]+$/,""); print; exit}' "$LOGMD")
      [ -n "$CODE" ] || continue
      THR=$(awk 'NR>1&&/^---/{exit} /^logviser:/{sub(/^logviser:[[:space:]]*/,""); sub(/[[:space:]]+$/,""); print; exit}' "$LOGMD")
      case "$THR" in (''|*[!0-9]*|0) THR=8 ;; esac
      TFILE=$(ls "$PDIR"/trace/*.md 2>/dev/null | sort | tail -1)
      [ -n "$TFILE" ] || continue
      MAXTR=$(grep -o "^## ${CODE}-trace[0-9]*" "$TFILE" | grep -o '[0-9]*$' | sort -n | tail -1)
      [ -n "$MAXTR" ] || continue
      LOGGED=$(grep '^\*\*Trace:\*\*' "$LOGMD" | grep -o "${CODE}-trace[0-9]*\(~[0-9]*\)\{0,1\}" | sed 's/.*trace//; s/.*~//' | sort -n | tail -1)
      N=$(( MAXTR - ${LOGGED:-0} ))
      [ "$N" -ge "$THR" ] && printf '%s %s\n' "$CODE" "$N"
    done | awk 'BEGIN{ORS=""} {print (NR>1 ? " · " : "") $0}')
  fi
  if [ -n "$OVER" ]; then
    BADGE="$BADGE $(printf '\033[38;5;%sm[%s %s]\033[0m' "$LV_COLOR" "$LV_TAG" "$OVER")"
  else
    BADGE="$BADGE $(printf '\033[38;5;%sm[%s]\033[0m' "$LV_COLOR" "$LV_TAG")"
  fi
fi

if [ -n "$PREV" ] && [ -n "$BADGE" ]; then
  printf '%s %s' "$PREV" "$BADGE"
else
  printf '%s%s' "$PREV" "$BADGE"
fi
