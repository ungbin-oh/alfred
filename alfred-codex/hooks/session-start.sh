#!/usr/bin/env bash
# written by Ungbin_Oh
# created : 2026-09-26
# updated : 2026-10-10
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
#   4. Version notices: when the plugin version differs from the `version:` line in the marker, the
#      workspace just moved to a new Alfred (first session on it) — the hook says so, points at the
#      changelog and rewrites the marker line. And when GitHub has a newer version than the one installed,
#      the hook says an update is available and gives the update commands. The remote check is one
#      curl with a 3-second cap (Codex itself needs the network; a slow or failed fetch just prints nothing)
#   5. The full common rules (rules/core.md)
#
# Codex has no import in AGENTS.md, so the rules are printed here. Codex caps hook output at about
# 2,500 tokens by default; hooks/hooks.json raises this hook's additionalContextLimit (in tokens)
# so the rules are not cut.
#
# Assumes bash. On Windows, Codex runs it through hooks/run-windows.ps1 with Git Bash (Git for Windows).

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

# ---- Versions ------------------------------------------------------------------------------------
# Installed version: plugin.json. Workspace version: the marker. Latest published version: plugin.json on GitHub main.
REMOTE_PLUGIN_JSON="https://raw.githubusercontent.com/ungbin-oh/alfred/main/alfred-codex/.claude-plugin/plugin.json"
CHANGELOG_URL="https://github.com/ungbin-oh/alfred/blob/main/CHANGELOG.md"

PLUGIN_VERSION=$(sed -n 's/.*"version":[[:space:]]*"\([^"]*\)".*/\1/p' "$PLUGIN_ROOT/.claude-plugin/plugin.json" | head -1)
MARKER_VERSION=$(sed -n 's/^version:[[:space:]]*\([^[:space:]]*\).*/\1/p' "$ROOT/.alfred/workspace" | head -1)
REMOTE_VERSION=$(curl -fsS --max-time 3 "$REMOTE_PLUGIN_JSON" 2>/dev/null | sed -n 's/.*"version":[[:space:]]*"\([^"]*\)".*/\1/p' | head -1)

# A marketplace clone next to the cache has the changelog; otherwise point at GitHub
CHANGELOG="${PLUGIN_ROOT%/cache/*}/marketplaces/alfred/CHANGELOG.md"
[ -f "$CHANGELOG" ] || CHANGELOG="$CHANGELOG_URL"

# ver_gt A B — true when A is newer than B (numbers compared part by part: 0.4.0 > 0.3.12)
ver_gt() {
  local a b i x y
  IFS=. read -r -a a <<< "$1"
  IFS=. read -r -a b <<< "$2"
  for i in 0 1 2; do
    x=${a[$i]:-0}; y=${b[$i]:-0}
    [ "$x" -gt "$y" ] 2>/dev/null && return 0
    [ "$x" -lt "$y" ] 2>/dev/null && return 1
  done
  return 1
}

# Rewrite the marker's version line so the "updated" notice shows once, in the first session on the new version
UPDATED_FROM=""
if [ -n "$PLUGIN_VERSION" ] && [ -n "$MARKER_VERSION" ] && [ "$MARKER_VERSION" != "$PLUGIN_VERSION" ]; then
  UPDATED_FROM="$MARKER_VERSION"
  TMP=$(mktemp "${TMPDIR:-/tmp}/alfred-marker.XXXXXX") && {
    sed "s/^version:.*/version: $PLUGIN_VERSION/" "$ROOT/.alfred/workspace" > "$TMP" && cat "$TMP" > "$ROOT/.alfred/workspace"
    rm -f "$TMP"
  }
fi

echo "ALFRED ACTIVE"
echo "Current time: $(date '+%Y-%m-%d %H:%M (%a)')"
echo "Workspace root: $ROOT"
echo "Language: $LANG_LINE"

if [ -n "$UPDATED_FROM" ]; then
  echo
  echo "NOTICE — Alfred was updated: $UPDATED_FROM → $PLUGIN_VERSION. This is the first session on the new version."
  echo "In the boot briefing, tell the user in one line (workspace language) that Alfred is now $PLUGIN_VERSION and what changed."
  echo "Read the changelog sections newer than $UPDATED_FROM, up to $PLUGIN_VERSION: $CHANGELOG"
fi

if [ -n "$REMOTE_VERSION" ] && [ -n "$PLUGIN_VERSION" ] && ver_gt "$REMOTE_VERSION" "$PLUGIN_VERSION"; then
  echo
  echo "NOTICE — a newer Alfred is available: $REMOTE_VERSION (installed: $PLUGIN_VERSION)."
  echo "In the boot briefing, tell the user in one line (workspace language) and give the two update commands as they are:"
  echo "  codex plugin marketplace upgrade alfred"
  echo "  codex plugin add alfred-codex@alfred"
  echo "Don't run them yourself. What changed: $CHANGELOG_URL"
fi

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
