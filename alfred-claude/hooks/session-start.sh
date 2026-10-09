#!/usr/bin/env bash
# written by Ungbin_Oh
# created : 2026-09-26
# updated : 2026-10-10
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
#   4. A notice only when something needs the model's attention (see below). One case: sync-rules.sh found that
#      the user edited .alfred/rules.md — the plugin did not overwrite it, and the model asks the user whether to
#      move the edits into CLAUDE.md or keep the file as their own (.alfred/rules.local)
#   5. Version notices: when the plugin version differs from the `version:` line in the marker, the
#      workspace just moved to a new Alfred (first session on it) — the hook says so, points at the
#      changelog and rewrites the marker line. And when GitHub has a newer version than the one installed,
#      the hook says an update is available and gives the update commands. The remote check is one
#      curl with a 3-second cap (Claude Code itself needs the network, so there is no offline case to
#      handle; a slow or failed fetch just prints nothing).
#
# The common rules themselves are NOT printed here. Hook output is capped at 10,000 characters
# and the rules are longer. Instead sync-rules.sh keeps a copy in .alfred/rules.md, and the
# workspace CLAUDE.md loads it with the line `@.alfred/rules.md`.
#
# CLAUDE.md and its imports are read before this hook runs, so a copy this hook creates or
# updates only loads by itself from the next session. For this session the notice asks the
# model to read the file. The hook never edits the user's CLAUDE.md.
#
# Session name: on a fresh start (source "startup") with no name set yet (no --name / -n), the hook also
# names the session with today's date (YYYY-MM-DD) through `sessionTitle` — same effect as /rename.
# Then everything above goes out as JSON (additionalContext + sessionTitle) instead of plain text.
#
# On Windows, Claude Code runs this on Git Bash (Git for Windows is required).

set -u

INPUT=$(cat)

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

# ---- Versions ------------------------------------------------------------------------------------
# Installed version: plugin.json. Workspace version: the marker. Latest published version: plugin.json on GitHub main.
REMOTE_PLUGIN_JSON="https://raw.githubusercontent.com/ungbin-oh/alfred/main/alfred-claude/.claude-plugin/plugin.json"
CHANGELOG_URL="https://github.com/ungbin-oh/alfred/blob/main/CHANGELOG.md"

PLUGIN_VERSION=$(sed -n 's/.*"version":[[:space:]]*"\([^"]*\)".*/\1/p' "$PLUGIN_ROOT/.claude-plugin/plugin.json" | head -1)
MARKER_VERSION=$(sed -n 's/^version:[[:space:]]*\([^[:space:]]*\).*/\1/p' "$ROOT/.alfred/workspace" | head -1)
REMOTE_VERSION=$(curl -fsS --max-time 3 "$REMOTE_PLUGIN_JSON" 2>/dev/null | sed -n 's/.*"version":[[:space:]]*"\([^"]*\)".*/\1/p' | head -1)

# The marketplace clone has the changelog (the plugin cache holds only hooks/rules/skills)
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

context() {
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
elif [ "$SYNC" = "user-edited" ]; then
  echo
  echo "NOTICE — .alfred/rules.md was edited by hand (it no longer matches what the plugin last wrote), so the plugin did NOT"
  echo "overwrite it. The installed rules are v$PLUGIN_VERSION ($PLUGIN_ROOT/rules/core.md); the file in the workspace may be older."
  echo "Tell the user in one line, show them the difference (diff the file against the plugin's core.md, ignoring the header lines),"
  echo "and ask through the question window which they want:"
  echo "  (a) move their edits into the \"My rules\" section of CLAUDE.md (section 0 of the rules: CLAUDE.md wins anyway), then"
  echo "      delete .alfred/rules.md and run: bash \"$PLUGIN_ROOT/hooks/sync-rules.sh\" \"$ROOT\"  — a fresh copy is written"
  echo "  (b) keep .alfred/rules.md as their own: create the empty file $ROOT/.alfred/rules.local — the plugin leaves it alone from then on"
  echo "Do neither without the answer."
elif [ "$SYNC" = "kept" ]; then
  echo "Note: .alfred/rules.local exists — the user manages .alfred/rules.md themselves; the plugin's v$PLUGIN_VERSION rules are not applied to it."
elif [ "$SYNC" = "created" ] || [ "$SYNC" = "updated" ]; then
  echo
  echo "NOTICE — the plugin just $SYNC .alfred/rules.md. The copy loaded into this session is older or missing."
  echo "Before anything else: read $ROOT/.alfred/rules.md in full and follow it for this session."
  echo "From the next session it loads by itself."
fi

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
  echo "  claude plugin marketplace update alfred"
  echo "  claude plugin update alfred@alfred"
  echo "Don't run them yourself. What changed: $CHANGELOG_URL"
fi
}

# Name the session by date only on a fresh start that has no name yet
SOURCE=$(printf '%s' "$INPUT" | tr -d '\r\n' | sed -n 's/.*"source"[[:space:]]*:[[:space:]]*"\([a-z]*\)".*/\1/p')
HAS_TITLE=no
printf '%s' "$INPUT" | tr -d '\r\n' | grep -q '"session_title"[[:space:]]*:[[:space:]]*"[^"]' && HAS_TITLE=yes

if [ "$SOURCE" = "startup" ] && [ "$HAS_TITLE" = "no" ]; then
  # JSON string escape: backslash (Windows paths), double quote, CR dropped, newline as \n
  CTX=$(context | tr -d '\r' | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g' | awk 'BEGIN{ORS=""} NR>1{print "\\n"} {print}')
  printf '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"%s","sessionTitle":"%s"}}\n' \
    "$CTX" "$(date '+%Y-%m-%d')"
else
  context
fi
