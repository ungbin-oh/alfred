#!/usr/bin/env bash
# written by Ungbin_Oh
# created : 2026-09-26
# updated : 2026-10-06
#
# Alfred — SessionStart hook
#
# Runs only when the working directory (or a parent) has the .alfred/workspace marker.
# Without the marker it prints nothing — so it never pollutes sessions unrelated to Alfred.
#
# With the marker it prints the following to stdout (Claude Code adds it to the session context):
#   1. Current date, time and weekday (the model has no clock)
#   2. Workspace root path
#   3. Workspace language (the `language:` line in the marker; en if missing)
#   4. A notice only when something needs the model's attention (see below)
#
# The common rules themselves are NOT printed here. Hook output is capped at 10,000 characters
# and the rules are longer. Instead sync-rules.sh keeps a copy in .alfred/rules.md, and the
# workspace CLAUDE.md loads it with the line `@.alfred/rules.md`.
#
# CLAUDE.md and its imports are read before this hook runs, so a copy this hook creates or
# updates only loads by itself from the next session. For this session the notice asks the
# model to read the file. The hook never edits the user's CLAUDE.md.
#
# Assumes macOS / Linux, bash. Not tested on Windows.

set -u

PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}"
START_DIR="${CLAUDE_PROJECT_DIR:-$PWD}"

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

SYNC=$(bash "$PLUGIN_ROOT/hooks/sync-rules.sh" "$ROOT")

echo "ALFRED ACTIVE"
echo "Current time: $(date '+%Y-%m-%d %H:%M (%a)')"
echo "Workspace root: $ROOT"
echo "Language: $LANG_LINE"
echo "Common rules: .alfred/rules.md, loaded by the line @.alfred/rules.md in the workspace CLAUDE.md"

HAS_IMPORT=no
[ -f "$ROOT/CLAUDE.md" ] && grep -q '^@\.alfred/rules\.md[[:space:]]*$' "$ROOT/CLAUDE.md" && HAS_IMPORT=yes

if [ "$SYNC" = "missing-rules" ]; then
  echo
  echo "ALFRED — could not find rules/core.md in the plugin ($PLUGIN_ROOT). Check the plugin installation."
elif [ "$HAS_IMPORT" = "no" ]; then
  echo
  echo "NOTICE — the workspace CLAUDE.md has no line \`@.alfred/rules.md\`, so the common rules were not loaded."
  echo "Before anything else: read $ROOT/.alfred/rules.md in full and follow it for this session."
  echo "Then ask the user through the question window whether to add the line \`@.alfred/rules.md\` on its own line"
  echo "near the top of CLAUDE.md (add it / leave CLAUDE.md as it is). Never edit CLAUDE.md without that answer."
elif [ "$SYNC" = "created" ] || [ "$SYNC" = "updated" ]; then
  echo
  echo "NOTICE — the plugin just $SYNC .alfred/rules.md. The copy loaded into this session is older or missing."
  echo "Before anything else: read $ROOT/.alfred/rules.md in full and follow it for this session."
  echo "From the next session it loads by itself."
fi
