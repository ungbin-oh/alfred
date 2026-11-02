#!/usr/bin/env bash
# written by Ungbin_Oh
# created : 2026-09-26
# updated : 2026-11-02
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
#      workspace just moved to a new Alfred (first session on it) — the hook says so, puts the changelog sections
#      since the old version into the notice (the model shows them in a question window) and rewrites the marker line. And when GitHub has a newer version than the one installed,
#      the hook says an update is available and gives the update commands. The remote check is one
#      curl with a 3-second cap (Codex itself needs the network; a slow or failed fetch just prints nothing).
#      Changelog items tagged [Workspace] are changes to the user's files that the plugin never makes by
#      itself — the model offers each one (question window)
#   5. The full common rules (rules/core.md)
#   6. Session name (new sessions only, source = startup): "[ALFRED] YYYY-MM-DD #N" (N = today's Alfred session number) — the [ALFRED] badge for the Codex
#      footer's thread-name item. Codex hook output has no name field, so a background job asks an app-server for
#      thread/name/set: the shared daemon first (shows at once when the TUI runs on it, `codex --remote unix://`),
#      else a separate stdio server after 6 s (shows after /resume). See the section near the end (AWP-trace394 · 395 · 408).
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

# Hook input (JSON on stdin): session_id · source (startup / resume / clear / compact / fork) · cwd …
# Read it only when stdin is not a terminal, so running the script by hand doesn't wait for input
HOOK_INPUT=""
[ -t 0 ] || HOOK_INPUT=$(cat)
json_field() {
  printf '%s' "$HOOK_INPUT" | sed -n "s/.*\"$1\"[[:space:]]*:[[:space:]]*\"\([^\"]*\)\".*/\1/p" | head -1
}
SESSION_ID=$(json_field session_id)
SESSION_SOURCE=$(json_field source)

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

# The marketplace clone has the changelog. Codex keeps it in <codex home>/.tmp/marketplaces/alfred
# (PLUGIN_ROOT is <codex home>/plugins/cache/alfred/alfred-codex/<version>); the older guess next to the cache is kept second.
# Neither found → point at GitHub
CHANGELOG=""
for c in "${PLUGIN_ROOT%/plugins/cache/*}/.tmp/marketplaces/alfred/CHANGELOG.md" \
         "${PLUGIN_ROOT%/cache/*}/marketplaces/alfred/CHANGELOG.md"; do
  [ -f "$c" ] && { CHANGELOG="$c"; break; }
done
[ -n "$CHANGELOG" ] || CHANGELOG="$CHANGELOG_URL"

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

# What the newer version brings: the sections of the published changelog between the installed version and the latest one
# (one more curl, 3-second cap, only when there is a newer version). Korean workspaces read docs/ko/CHANGELOG.md
NEWER_TEXT=""
if [ -n "$REMOTE_VERSION" ] && [ -n "$PLUGIN_VERSION" ] && ver_gt "$REMOTE_VERSION" "$PLUGIN_VERSION"; then
  REMOTE_CL="https://raw.githubusercontent.com/ungbin-oh/alfred/main/CHANGELOG.md"
  [ "$LANG_CODE" = "ko" ] && REMOTE_CL="https://raw.githubusercontent.com/ungbin-oh/alfred/main/docs/ko/CHANGELOG.md"
  NEWER_TEXT=$(curl -fsS --max-time 3 "$REMOTE_CL" 2>/dev/null | awk -v from="$PLUGIN_VERSION" -v to="$REMOTE_VERSION" '
    /^## [0-9]/ { if ($2 == from) exit; if ($2 == to) on = 1 }
    on { print }' | head -c 6000)
fi

# Changelog text for the update notice: the sections newer than the marker version, up to the installed one (the file is
# newest first). A Korean workspace reads docs/ko/CHANGELOG.md when the clone has it. Capped at 6,000 characters. Empty when
# the local changelog is missing or doesn't have the installed version yet — the notice then points at the file instead
UPDATE_TEXT=""
if [ -n "$UPDATED_FROM" ]; then
  CL_LOCAL="$CHANGELOG"
  CL_KO="$(dirname "$CHANGELOG")/docs/ko/CHANGELOG.md"
  [ "$LANG_CODE" = "ko" ] && [ -f "$CL_KO" ] && CL_LOCAL="$CL_KO"
  if [ -f "$CL_LOCAL" ]; then
    UPDATE_TEXT=$(awk -v from="$UPDATED_FROM" -v to="$PLUGIN_VERSION" '
      /^## [0-9]/ { if ($2 == from) exit; if ($2 == to) on = 1 }
      on { print }' "$CL_LOCAL" | head -c 6000)
  fi
fi

echo "ALFRED ACTIVE"
echo "Current time: $(date '+%Y-%m-%d %H:%M (%a)')"
echo "Workspace root: $ROOT"
echo "Language: $LANG_LINE"

# Newer-version notice — also at the very end (after the update notice), for the same reason
newer_notice() {
  if [ -n "$REMOTE_VERSION" ] && [ -n "$PLUGIN_VERSION" ] && ver_gt "$REMOTE_VERSION" "$PLUGIN_VERSION"; then
    echo
    echo "=== REQUIRED IN THIS REPLY — ALFRED NEW VERSION NOTICE ==="
    echo "A newer Alfred is available: $REMOTE_VERSION (installed: $PLUGIN_VERSION). Do not skip this."
    echo "Tell the user through the question window (request_user_input), as the LAST action of the boot briefing — after the update-notice"
    echo "question if there is one (same window, up to 4 questions) — no chat text after it, and wait:"
    echo "  - header \"Alfred $REMOTE_VERSION\": the question text says a new version is out, then what it adds or changes in 2–5 short lines"
    echo "    (each line starts with its version and Added / Changed / Fixed — e.g. \"0.4.13 Added: …\", the word in the workspace language), from the changelog below. Options: \"Show update commands\" / \"Later\""
    echo "    (in the workspace language)."
    echo "  - On \"Show update commands\": give these two commands as they are, to run in a terminal outside this session, then start a"
    echo "    new session (the update loads only then). Don't run them yourself:"
    echo "      codex plugin marketplace upgrade alfred"
    echo "      codex plugin add alfred-codex@alfred"
    if [ -n "$NEWER_TEXT" ]; then
      echo "  Published changelog after $PLUGIN_VERSION, up to $REMOTE_VERSION:"
      printf '%s\n' "$NEWER_TEXT" | sed 's/^/    | /'
    else
      echo "  What changed: $CHANGELOG_URL"
    fi
  fi
}

# Update notice — printed at the very END of the hook output, after the rules (AWP-trace423: placed before the rules,
# in the middle of the context, Codex wrote the boot briefing and skipped it). Called once, last.
update_notice() {
  if [ -n "$UPDATED_FROM" ]; then
    echo
    echo "=== REQUIRED IN THIS REPLY — ALFRED UPDATE NOTICE ==="
    echo "Alfred was updated: $UPDATED_FROM → $PLUGIN_VERSION. This is the first session on the new version. Do not skip this."
    echo "Show the user what was added and what changed through the question window (request_user_input), as the LAST action of the"
    echo "boot briefing: write the whole briefing first, then call it — no chat text after it, no other tools in between — and wait."
    echo "  - First question, header \"Alfred $PLUGIN_VERSION\": the question text lists the changes since $UPDATED_FROM in 2–5 short"
    echo "    lines, one item per line, each starting with its version and Added / Changed / Fixed — e.g. \"0.4.12 Added: …\" (the word in the workspace language: 0.4.12 추가 · 변경 · 수정)."
    echo "    Options: \"Got it\" / \"Explain more\" (in the workspace language). On \"Explain more\", explain each item briefly in chat."
    echo "  - Then one question per item tagged [Workspace] — a change to the user's files (workspace or ~/.codex) that the plugin does"
    echo "    not make by itself: say what it would change; options apply / skip. At most 4 questions in one window; ask the rest in a"
    echo "    second window. Apply only on yes, show what you changed, and never touch the user's existing content. Untagged items need nothing."
    echo "  (Called mid-reply, Codex queues the question and it closes on its own before it can be answered.)"
    if [ -n "$UPDATE_TEXT" ]; then
      echo "  Changelog sections after $UPDATED_FROM, up to $PLUGIN_VERSION:"
      printf '%s\n' "$UPDATE_TEXT" | sed 's/^/    | /'
    else
      echo "  Read the changelog sections newer than $UPDATED_FROM, up to $PLUGIN_VERSION: $CHANGELOG"
    fi
  fi
}


# Question windows: in Codex's Default mode, request_user_input sits behind the feature flag default_mode_request_user_input.
# If it is off, turn it on once (Codex writes it to ~/.codex/config.toml and it stays on). It takes effect from the next session.
QW_TURNED_ON=""
if command -v codex >/dev/null 2>&1; then
  QW_STATE=$(codex features list 2>/dev/null | awk '$1 == "default_mode_request_user_input" { print $NF }')
  if [ "$QW_STATE" = "false" ] && codex features enable default_mode_request_user_input >/dev/null 2>&1; then
    QW_TURNED_ON=1
  fi
fi
if [ -n "$QW_TURNED_ON" ]; then
  echo
  echo "NOTICE — Alfred just turned on Codex question windows (codex features enable default_mode_request_user_input, saved in"
  echo "~/.codex/config.toml). They work from the next Codex session. In this session request_user_input won't show — ask in chat."
  echo "In the boot briefing, tell the user in one line (workspace language) and that reopening Codex brings the windows."
fi

# ---- Session name "[ALFRED] YYYY-MM-DD #N" (new sessions only) --------------------------------------------------------
# A background job so the hook returns at once (hooks.json timeout 5 s). All output goes to a log, so the job never
# holds the hook's stdout open. Log: ${TMPDIR:-/tmp}/alfred-thread-name.log (last run only)
#   1st try — the shared app-server daemon, right away, through hooks/set-thread-name.py (the daemon's control socket
#     speaks WebSocket; `codex app-server proxy` relays raw bytes only, AWP-trace410). When the TUI was started with
#     `codex --remote unix://` it runs on that daemon, so the daemon tells the open screen the new name at once.
#     Setting it now (before Codex's automatic title, ~2 s later) also keeps the automatic title from replacing it:
#     the TUI writes its generated title only when the thread has no name yet (tui/src/app/event_dispatch.rs).
#   Fallback — no python3, no daemon socket, or the call failed: a separate stdio app-server after 6 s (after the
#     automatic title). The saved name and the /resume list change; the open screen shows it only after /resume.
send_thread_name_stdio() {
  {
    printf '%s\n' '{"method":"initialize","id":1,"params":{"clientInfo":{"name":"alfred","version":"'"${PLUGIN_VERSION:-0}"'"}}}'
    sleep 1
    printf '%s\n' '{"method":"initialized"}'
    printf '%s\n' '{"method":"thread/name/set","id":2,"params":{"threadId":"'"$SESSION_ID"'","name":"'"$THREAD_NAME"'"}}'
    sleep 3
  } | codex app-server --listen stdio:// 2>&1
}
if [ "$SESSION_SOURCE" = "startup" ] && [ -n "$SESSION_ID" ] && command -v codex >/dev/null 2>&1; then
  # #N = today's Alfred session number: sessions already named "[ALFRED] <today>" in Codex's session index, + 1
  #   (session_index.jsonl keeps one line per rename; ids are counted once, this session left out). Read only
  TODAY=$(date '+%Y-%m-%d')
  SESSION_INDEX="${CODEX_HOME:-$HOME/.codex}/session_index.jsonl"
  TODAY_COUNT=0
  if [ -f "$SESSION_INDEX" ]; then
    TODAY_COUNT=$(grep -F "\"thread_name\":\"[ALFRED] $TODAY" "$SESSION_INDEX" \
      | sed -n 's/.*"id":"\([^"]*\)".*/\1/p' | grep -v -F "$SESSION_ID" | sort -u | wc -l | tr -d ' ')
  fi
  THREAD_NAME="[ALFRED] $TODAY #$((TODAY_COUNT + 1))"
  NAME_LOG="${TMPDIR:-/tmp}/alfred-thread-name.log"
  DAEMON_SOCK="${CODEX_HOME:-$HOME/.codex}/app-server-control/app-server-control.sock"
  (
    echo "$(date '+%H:%M:%S') set $SESSION_ID → $THREAD_NAME"
    if command -v python3 >/dev/null 2>&1 && [ -S "$DAEMON_SOCK" ] &&
       ALFRED_VERSION="${PLUGIN_VERSION:-0}" python3 -I "$PLUGIN_ROOT/hooks/set-thread-name.py" "$DAEMON_SOCK" "$SESSION_ID" "$THREAD_NAME"; then
      echo "$(date '+%H:%M:%S') done (daemon)"
    else
      echo "$(date '+%H:%M:%S') daemon path not used or failed → stdio app-server after 6 s"
      sleep 6
      send_thread_name_stdio
      echo "$(date '+%H:%M:%S') done (stdio)"
    fi
  ) > "$NAME_LOG" 2>&1 < /dev/null &
fi

RULES="$PLUGIN_ROOT/rules/core.md"
if [ ! -f "$RULES" ]; then
  echo
  echo "ALFRED — could not find rules/core.md in the plugin ($PLUGIN_ROOT). Check the plugin installation."
  update_notice
  newer_notice
  exit 0
fi

echo
echo "Below are the Alfred common rules. Where they conflict with the workspace AGENTS.md, AGENTS.md wins."
echo "Reading them in Codex: \"CLAUDE.md\" means the workspace AGENTS.md. \"The question window (AskUserQuestion)\" means"
echo "request_user_input when it is available; otherwise ask in chat, one question at a time. Claude Code-only parts"
echo "(the @.alfred/rules.md line and .alfred/rules.md, the statusline badge) don't apply."
echo
cat "$RULES"
update_notice
newer_notice
