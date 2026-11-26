#!/usr/bin/env bash
# written by Ungbin_Oh
# created : 2026-11-15
# updated : 2026-11-26
#
# Alfred — logviser UserPromptSubmit hook (log advisor)
#
# While the workspace's .alfred/logviser state file exists (one line: on | lite | auto), counts per project how many
# trace entries have not been carried into log.md yet. When a project passes its threshold, it injects an
# instruction into this turn's context: finish the user's request, then ask about saving the log.
#   on   — a question window: what was done (from the trace headers) + "what judgment or intent was behind it?",
#          options "Save to the log now" / "Skip"
#   lite — one line at the end of the reply, no window
#   auto — no question: the assistant writes the log entries itself from the traces, each marked with an
#          "**Auto:**" line. For users who find the confirmation step a chore. Turning auto on is the confirmation
# If the file doesn't exist, prints nothing (mode off).
#
# Counting, per project (a folder under project-logs/ with a log.md that has a `code:` line):
#   not logged = (largest <code>-trace<N> header in the newest trace file)
#              − (largest <code>-trace<N> cited on the **Trace:** lines of log.md)
# Only the project's own code is counted, so a cited trace of another project doesn't count.
# Threshold: `logviser: N` in the log.md frontmatter, else 8.
# Once a project was asked about, it is asked again only after another threshold's worth of traces
# (.alfred/logviser-seen, one "<code><TAB><largest trace when asked>" line per project).
#
# End of the day: when the prompt says the day is over ("wrap up the day", "done for the day", "퇴근", "오늘 끝" …),
# the table of every project with traces not logged is injected, and the assistant shows it and asks whether to save.
# In auto the assistant writes the entries for all of them instead of asking.
#
# Toggling is done by the logviser skill (it writes and deletes the state file). On a logviser call this turn the
# hook only injects the table for the skill (status / report) and nothing else.
#
# Also runs as a tool: `bash logviser.sh report <workspace root>` prints the table.
#
# Codex only — the state in the thread name. The Codex footer has no slot for a badge (AWP-log47), but the thread name
# shows in the open screen, the footer and the window title (at once when Codex runs on the shared daemon,
# `codex --remote unix://`; otherwise after /resume). So every turn the hook compares the thread name with the state and,
# when they differ, renames it in the background like session-start.sh does:
#   on   "[ALFRED] [LOGVISER] 2026-11-15 #2" · over a threshold "[ALFRED] [LOGVISER INC 9 · THS 12] 2026-11-15 #2"
#   lite "[ALFRED] [LOGVISER-lite …] …"      · off "[ALFRED] 2026-11-15 #2"
#   auto "[ALFRED] [LOGVISER-auto …] …"
# Only names that start with "[ALFRED]" are touched — a name the user gave is left alone. The current name is read from
# ~/.codex/session_index.jsonl (last line for this session). On a toggle turn the skill writes the state file after this
# hook, so the level is taken from the prompt ("$logviser on" …). Log: ${TMPDIR:-/tmp}/alfred-logviser-name.log
#
# No python / jq: the prompt is matched on the raw hook input.
# Assumes bash. On Windows, Codex runs it through hooks/run-windows.ps1 with Git Bash (Git for Windows).

set -u

DEFAULT_THRESHOLD=8

find_root() {
  local d="$1" p
  while [ -n "$d" ] && [ "$d" != "/" ] && [ "$d" != "." ]; do
    if [ -f "$d/.alfred/workspace" ]; then
      printf '%s' "$d"
      return 0
    fi
    # Stop when going up changes nothing (a Windows path never reaches "/")
    p=$(dirname "$d")
    [ "$p" = "$d" ] && return 1
    d="$p"
  done
  return 1
}

# ---- One project: "<code>\t<largest trace>\t<largest logged>\t<not logged>\t<threshold>\t<dir under project-logs>" ----
measure() {
  local logmd="$1" dir code thr tfile maxtr logged
  dir=$(dirname "$logmd")
  code=$(awk 'NR>1&&/^---/{exit} /^code:/{sub(/^code:[[:space:]]*/,""); sub(/[[:space:]]+$/,""); print; exit}' "$logmd")
  [ -n "$code" ] || return 0
  thr=$(awk 'NR>1&&/^---/{exit} /^logviser:/{sub(/^logviser:[[:space:]]*/,""); sub(/[[:space:]]+$/,""); print; exit}' "$logmd")
  case "$thr" in ''|*[!0-9]*) thr=$DEFAULT_THRESHOLD ;; esac
  [ "$thr" -gt 0 ] 2>/dev/null || thr=$DEFAULT_THRESHOLD
  [ -d "$dir/trace" ] || return 0
  tfile=$(ls "$dir"/trace/*.md 2>/dev/null | sort | tail -1)
  [ -n "$tfile" ] || return 0
  maxtr=$(grep -o "^## ${code}-trace[0-9]*" "$tfile" | grep -o '[0-9]*$' | sort -n | tail -1)
  [ -n "$maxtr" ] || return 0
  logged=$(grep '^\*\*Trace:\*\*' "$logmd" | grep -o "${code}-trace[0-9]*\(~[0-9]*\)\{0,1\}" \
           | sed 's/.*trace//; s/.*~//' | sort -n | tail -1)
  [ -n "$logged" ] || logged=0
  printf '%s\t%s\t%s\t%s\t%s\t%s\n' "$code" "$maxtr" "$logged" "$(( maxtr - logged ))" "$thr" "${dir#$LOGS/}"
}

measure_all() {
  local f
  [ -d "$LOGS" ] || return 0
  find "$LOGS" -name log.md -not -path '*/Archive/*' 2>/dev/null | sort | while IFS= read -r f; do measure "$f"; done
}

seen_of() {
  [ -f "$SEEN" ] && awk -F'\t' -v c="$1" '$1==c{v=$2} END{if (v!="") print v}' "$SEEN"
  return 0
}

mark_seen() {
  touch "$SEEN"
  { awk -F'\t' -v c="$1" '$1!=c' "$SEEN"; printf '%s\t%s\n' "$1" "$2"; } > "$SEEN.tmp" && mv "$SEEN.tmp" "$SEEN"
}

# Due: not logged ≥ threshold, and a threshold's worth more since the last time this project was asked about
due_rows() {
  local code maxtr logged unlogged thr dir last
  measure_all | while IFS=$'\t' read -r code maxtr logged unlogged thr dir; do
    [ "$unlogged" -ge "$thr" ] || continue
    last=$(seen_of "$code"); last=${last:-0}
    [ "$maxtr" -ge $(( last + thr )) ] || continue
    printf '%s\t%s\t%s\t%s\t%s\t%s\n' "$code" "$maxtr" "$logged" "$unlogged" "$thr" "$dir"
  done
}

report() {
  local code maxtr logged unlogged thr dir rows
  rows=$(measure_all | awk -F'\t' '$4>0')
  if [ "$LANG_CODE" = "ko" ]; then
    printf '| 프로젝트 | log 안 된 trace | 범위 | 임계 |\n|---|---|---|---|\n'
  else
    printf '| Project | Traces not logged | Range | Threshold |\n|---|---|---|---|\n'
  fi
  if [ -z "$rows" ]; then
    if [ "$LANG_CODE" = "ko" ]; then printf '| (없음) | | | |\n'; else printf '| (none) | | | |\n'; fi
    return 0
  fi
  printf '%s\n' "$rows" | while IFS=$'\t' read -r code maxtr logged unlogged thr dir; do
    printf '| %s | %s | %s-trace%s~%s | %s |\n' "$code" "$unlogged" "$code" "$(( logged + 1 ))" "$maxtr" "$thr"
  done
}

set_root() {
  ROOT="$1"
  LOGS="$ROOT/project-logs"
  STATE="$ROOT/.alfred/logviser"
  SEEN="$ROOT/.alfred/logviser-seen"
  LANG_CODE=$(sed -n 's/^language:[[:space:]]*\([a-z][a-z]\).*/\1/p' "$ROOT/.alfred/workspace" 2>/dev/null | head -1)
}

# ---- As a tool ------------------------------------------------------------------------------------
if [ "${1:-}" = "report" ]; then
  R=$(find_root "${2:-${CLAUDE_PROJECT_DIR:-$PWD}}") || { echo "Not an Alfred workspace."; exit 0; }
  set_root "$R"
  report
  exit 0
fi

# ---- UserPromptSubmit hook ------------------------------------------------------------------------
input=$(cat)

R=$(find_root "${CLAUDE_PROJECT_DIR:-$PWD}") || exit 0
set_root "$R"

# ---- Codex: logviser state in the thread name -----------------------------------------------------
PLUGIN_ROOT="${PLUGIN_ROOT:-${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}}"
thread_badge() {
  local sid idx cur base lv tag over want sock
  command -v codex >/dev/null 2>&1 || return 0
  sid=$(printf '%s' "$input" | sed -n 's/.*"session_id"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -1)
  [ -n "$sid" ] || return 0
  idx="${CODEX_HOME:-$HOME/.codex}/session_index.jsonl"
  [ -f "$idx" ] || return 0
  cur=$(grep -F "\"id\":\"$sid\"" "$idx" | tail -1 | sed -n 's/.*"thread_name":"\([^"]*\)".*/\1/p')
  case "$cur" in "[ALFRED] "*) ;; *) return 0 ;; esac
  base=$(printf '%s' "$cur" | sed 's/^\[ALFRED\] \[LOGVISER[^]]*\] /[ALFRED] /')
  lv=off
  [ -f "$STATE" ] && lv=$(tr -d '[:space:]' < "$STATE")
  tag=$(printf '%s' "$input" | grep -Eo 'logviser[[:space:]]+(on|lite|auto|off)' | head -1 | awk '{print $2}')
  [ -n "$tag" ] && lv="$tag"
  if [ "$lv" = "on" ] || [ "$lv" = "lite" ] || [ "$lv" = "auto" ]; then
    tag="LOGVISER"
    [ "$lv" = "lite" ] && tag="LOGVISER-lite"
    [ "$lv" = "auto" ] && tag="LOGVISER-auto"
    over=$(measure_all | awk -F'\t' '$4>=$5{printf "%s%s %s", (c++ ? " · " : ""), $1, $4}')
    [ -n "$over" ] && tag="$tag $over"
    want="[ALFRED] [$tag] ${base#\[ALFRED\] }"
  else
    want="$base"
  fi
  [ "$want" = "$cur" ] && return 0
  sock="${CODEX_HOME:-$HOME/.codex}/app-server-control/app-server-control.sock"
  (
    echo "$(date '+%H:%M:%S') set $sid: $cur → $want"
    if command -v python3 >/dev/null 2>&1 && [ -S "$sock" ] &&
       python3 -I "$PLUGIN_ROOT/hooks/set-thread-name.py" "$sock" "$sid" "$want"; then
      echo "$(date '+%H:%M:%S') done (daemon)"
    else
      echo "$(date '+%H:%M:%S') daemon path not used or failed → stdio app-server"
      {
        printf '%s\n' '{"method":"initialize","id":1,"params":{"clientInfo":{"name":"alfred","version":"0"}}}'
        sleep 1
        printf '%s\n' '{"method":"initialized"}'
        printf '%s\n' '{"method":"thread/name/set","id":2,"params":{"threadId":"'"$sid"'","name":"'"$want"'"}}'
        sleep 3
      } | codex app-server --listen stdio:// 2>&1
      echo "$(date '+%H:%M:%S') done (stdio)"
    fi
  ) > "${TMPDIR:-/tmp}/alfred-logviser-name.log" 2>&1 < /dev/null &
}
thread_badge

# A logviser call this turn: the skill does the toggle; give it the table for status / report, nothing else
case "$input" in
  *logviser*)
    echo "LOGVISER — table for the logviser skill this turn (traces not yet carried into log.md, per project)."
    echo "State file .alfred/logviser before this turn: $( [ -f "$STATE" ] && tr -d '[:space:]' < "$STATE" || echo off )"
    echo
    report
    exit 0 ;;
esac

[ -f "$STATE" ] || exit 0
level=$(tr -d '[:space:]' < "$STATE")
case "$level" in on|lite|auto) ;; *) exit 0 ;; esac

# ---- auto: the assistant writes the entries itself, without asking ----
auto_rows() {
  local code maxtr logged unlogged thr dir
  while IFS=$'\t' read -r code maxtr logged unlogged thr dir; do
    echo "- $code: ${unlogged} not logged — ${code}-trace$(( logged + 1 ))~${maxtr} (threshold $thr). Log: project-logs/$dir/log.md · trace files: project-logs/$dir/trace/"
    mark_seen "$code" "$maxtr"
  done
}

auto_rules() {
  cat <<'RULES'

The user turned logviser auto on — that is their confirmation, given ahead, for these entries. So no question window, no
draft in chat, no "shall I save?". How to write them:
1. Read the trace entries in the range — the header and the notes under it. Open a quoted full answer (`> [!quote]-`)
   only when the notes are not enough.
2. Group them by topic and append one log entry per topic to the end of log.md. Read the `## Format` section at the top
   of that log.md first, and follow the entry format in the rules. The header time comes from the shell (`date`).
3. Right under the `**Trace:**` line, add this line as it is, so an entry nobody confirmed can be told from one the user
   confirmed: `**Auto:** written by logviser auto — not confirmed by the user`
4. The user's intent goes in only as far as the trace holds it:
   - A decision goes under Decision & Reason only when the trace records it, with who decided. The user's reason is
     written in the user's own words from the trace
   - Never make up a reason, an intent or a decision to fill the entry. A range that was only questions and answers has
     no Decision & Reason section — Problem (what the user asked or wanted, from the trace) and Result only
   - A choice the assistant made on its own is marked as the assistant's, not the user's
5. A topic still in progress — the latest traces belong to work this turn's request continues — is left out: write up to
   the last finished topic, and cite on the `**Trace:**` lines only the traces that went in. The rest is picked up next
   time. Don't hold back when a project's count above is twice its threshold or more, or at the end of the day — then
   write all of it.
6. Frontmatter: update `updated` only. `next_action`, `objective` and `status` stay as they are — those are the user's.
   Don't close open.md items and don't write decision.md entries from here.
7. Do the user's request first. The final reply is the whole answer to the request, and its last lines say what was
   saved, one line per entry, in the workspace language: `📝 <code>: saved <code>-log<N> — <title> (trace a–b, auto)`.
   If nothing was written (step 5), say that in one line instead.
8. If the user later says an auto entry is wrong, don't edit it (the log is append-only) — append a correcting entry
   that names the one it corrects.
RULES
}

# ---- End of the day ----
if printf '%s' "$input" | grep -Eiq '오늘[[:space:]]*(끝|마무리)|퇴근|하루[[:space:]]*(끝|마무리)|wrap(ping)?[[:space:]]+up[[:space:]]+(the|for[[:space:]]+the|my)[[:space:]]+day|done[[:space:]]+for[[:space:]]+(the[[:space:]]+day|today)|call(ing)?[[:space:]]+it[[:space:]]+a[[:space:]]+day'; then
  if [ "$level" = "auto" ]; then
    rows=$(measure_all | awk -F'\t' '$4>0')
    if [ -n "$rows" ]; then
      echo "LOGVISER (auto) — end of the day. Below are the projects whose traces are not all carried into log.md yet."
      echo "**This turn, do the user's request first, then write the log entries for every project below yourself — without"
      echo "asking, topics still in progress included.**"
      echo
      printf '%s\n' "$rows" | auto_rows
      auto_rules
    fi
    exit 0
  fi
  echo "LOGVISER — end of the day. Below are the projects whose traces are not all carried into log.md yet."
  echo "**At the end of this reply, show this table as it is and ask the user whether to save** (in the workspace language)."
  echo "Show the table only — don't suggest what to save."
  echo
  report
  echo
fi

due=$(due_rows)
[ -n "$due" ] || exit 0

if [ "$level" = "auto" ]; then
  echo "LOGVISER (auto) — some projects have more traces not carried into log.md than their threshold."
  echo "**This turn, do the user's request first, then write the log entries for the projects below yourself — without asking.**"
  echo
  printf '%s\n' "$due" | auto_rows
  auto_rules
  exit 0
fi

if [ "$level" = "lite" ]; then
  echo "LOGVISER (lite) — some projects have more traces not carried into log.md than their threshold."
  echo "**At the very end of this reply, add the lines below, one per project, as they are.** No question window, no suggestion"
  echo "to save — only the notice."
  echo
  printf '%s\n' "$due" | while IFS=$'\t' read -r code maxtr logged unlogged thr dir; do
    if [ "$LANG_CODE" = "ko" ]; then
      echo "📝 $code: log 안 된 trace ${unlogged}건 (${code}-trace$(( logged + 1 ))~${maxtr})"
    else
      echo "📝 $code: ${unlogged} traces not logged (${code}-trace$(( logged + 1 ))~${maxtr})"
    fi
    mark_seen "$code" "$maxtr"
  done
  exit 0
fi

echo "LOGVISER — some projects have more traces not carried into log.md than their threshold."
echo "**This turn, do the user's request first, then open one question window (AskUserQuestion) at the end.**"
echo
printf '%s\n' "$due" | while IFS=$'\t' read -r code maxtr logged unlogged thr dir; do
  echo "- $code: ${unlogged} not logged — ${code}-trace$(( logged + 1 ))~${maxtr} (threshold $thr). Trace files: project-logs/$dir/trace/"
  mark_seen "$code" "$maxtr"
done
cat <<'RULES'

How to build the window (one question per project, at most 4), in the workspace language:
1. Read the trace headers in that range (`## <code>-trace<N> HH:MM — title`) and write the question like this:
   "So far in <code> you have <the trace titles, grouped into 2–3 points> (trace N–M, K entries).
    What judgment or intent was behind this work?"
   Only facts written in the trace. No interpretation.
2. Two options: "Save to the log now" / "Skip — ask again after another threshold's worth".
   What the user types in the free-text field is their judgment or intent — material for the entry's Decision & Reason,
   used as written and marked as the user's judgment. **Typing a judgment there counts as choosing "Save to the log now".**
3. On save (typed answer included): in the same reply, show the draft entry with that judgment in chat, and write it only
   after the user confirms. On skip: write nothing. The project is asked about again only after another threshold's worth
   of traces (threshold 8 → asked at the 8th, skipped → asked again at the 16th).
4. **The answer to the user's request goes in full in the final reply, after the window.** The user may see only the final
   reply: text written before a window is folded away once it closes.
   - Order: (tool work) → question window → after the answer, **the final reply = the whole answer to the user's request**,
     then one line on the window's result (skipped, or the save draft below it)
   - Write no answer before the window. Never "answered above" or only a summary — the final reply alone must answer the request
RULES
