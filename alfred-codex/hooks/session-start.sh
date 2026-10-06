#!/usr/bin/env bash
# written by Ungbin_Oh
# created : 2026-09-26
# updated : 2026-10-06
#
# Alfred for Codex — SessionStart hook
#
# Runs only when the working directory (or a parent) has the .alfred/workspace marker.
# Without the marker it prints nothing — so it never pollutes sessions unrelated to Alfred.
#
# With the marker it prints the following to stdout (Codex adds it to the session context):
#   1. Current date, time and weekday (the model has no clock)
#   2. Workspace root path
#   3. Workspace language (the `language:` line in the marker; en if missing)
#   4. The full common rules (rules/core.md)
#
# Codex has no import in AGENTS.md, so the rules are printed here. Codex caps hook output at about
# 2,500 tokens by default; hooks/hooks.json raises this hook's additionalContextLimit (in tokens)
# so the rules are not cut.
#
# Assumes macOS / Linux, bash. Not tested on Windows.

set -u

PLUGIN_ROOT="${PLUGIN_ROOT:-${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}}"
START_DIR="$PWD"

# Walk up looking for the marker
find_root() {
  local d="$1" p
  while [ -n "$d" ] && [ "$d" != "/" ] && [ "$d" != "." ]; do
    if [ -f "$d/.alfred/workspace" ]; then
      printf '%s' "$d"
      return 0
    fi
    # Stop when going up changes nothing. On macOS / Linux the walk ends at "/", but a Windows
    # path (C:\Users\...) never reaches "/" — Git Bash goes C: → . → . — and the loop never ended
    p=$(dirname "$d")
    [ "$p" = "$d" ] && return 1
    d="$p"
  done
  return 1
}

ROOT=$(find_root "$START_DIR") || exit 0

LANG_CODE=$(sed -n 's/^language:[[:space:]]*\([a-z][a-z]\).*/\1/p' "$ROOT/.alfred/workspace" | head -1)
case "$LANG_CODE" in
  ko) LANG_LINE="ko — speak to the user in Korean (합쇼체) and write logs, traces and notes in Korean" ;;
  *)  LANG_LINE="en — speak to the user in English and write logs, traces and notes in English" ;;
esac

echo "ALFRED ACTIVE"
echo "Current time: $(date '+%Y-%m-%d %H:%M (%a)')"
echo "Workspace root: $ROOT"
echo "Language: $LANG_LINE"

RULES="$PLUGIN_ROOT/rules/core.md"
if [ ! -f "$RULES" ]; then
  echo
  echo "ALFRED — could not find rules/core.md in the plugin ($PLUGIN_ROOT). Check the plugin installation."
  exit 0
fi

echo
echo "Below are the Alfred common rules. Where they conflict with the workspace AGENTS.md, AGENTS.md wins."
echo "Reading them in Codex: \"CLAUDE.md\" means the workspace AGENTS.md. \"The question window (AskUserQuestion)\" means"
echo "request_user_input when it is available; otherwise ask in chat, one question at a time. Claude Code-only parts"
echo "(the @.alfred/rules.md line and .alfred/rules.md, the statusline badge) don't apply."
echo
cat "$RULES"
