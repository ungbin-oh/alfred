#!/usr/bin/env bash
# written by Ungbin_Oh
# created : 2026-09-26
# updated : 2026-09-27
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
#   4. Body of rules/core.md (common rules)
#
# Assumes macOS / Linux, bash. Not tested on Windows.

set -u

PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}"
START_DIR="${CLAUDE_PROJECT_DIR:-$PWD}"

# Walk up looking for the marker
find_root() {
  local d="$1"
  while [ -n "$d" ] && [ "$d" != "/" ]; do
    if [ -f "$d/.alfred/workspace" ]; then
      printf '%s' "$d"
      return 0
    fi
    d=$(dirname "$d")
  done
  return 1
}

ROOT=$(find_root "$START_DIR") || exit 0

RULES="$PLUGIN_ROOT/rules/core.md"
[ -f "$RULES" ] || { echo "ALFRED — could not find rules/core.md ($RULES). Check the plugin installation."; exit 0; }

LANG_CODE=$(sed -n 's/^language:[[:space:]]*\([a-z][a-z]\).*/\1/p' "$ROOT/.alfred/workspace" | head -1)
case "$LANG_CODE" in
  ko) LANG_LINE="ko — speak to the user in Korean (합쇼체) and write logs, traces and notes in Korean" ;;
  *)  LANG_LINE="en — speak to the user in English and write logs, traces and notes in English" ;;
esac

echo "ALFRED ACTIVE"
echo "Current time: $(date '+%Y-%m-%d %H:%M (%a)')"
echo "Workspace root: $ROOT"
echo "Language: $LANG_LINE"
echo
echo "Below are the Alfred common rules. Where they conflict with the workspace CLAUDE.md, CLAUDE.md wins."
echo
# Leave the author header line out of the session
grep -v '^written by ' "$RULES"
