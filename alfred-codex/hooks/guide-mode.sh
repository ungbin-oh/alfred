#!/usr/bin/env bash
# written by Ungbin_Oh
# created : 2026-10-06
# updated : 2026-10-06
#
# Alfred — guide-mode UserPromptSubmit hook
#
# While the workspace's .alfred/guide-mode state file exists, injects the tip rules every turn:
# at most one short usage tip per reply, only when it fits. If the file doesn't exist, prints nothing (mode off).
#
# Toggling (and the first tour) is done by the guide-mode skill, which writes and deletes the state file.
# If this prompt is a guide-mode call, injection is skipped — the skill handles that turn.
#
# Assumes bash. On Windows, Codex runs it through hooks/run-windows.ps1 with Git Bash (Git for Windows).

set -u

START_DIR="${CLAUDE_PROJECT_DIR:-$PWD}"

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

input=$(cat)

ROOT=$(find_root "$START_DIR") || exit 0
[ -f "$ROOT/.alfred/guide-mode" ] || exit 0

# A toggle call this turn is left to the skill
case "$input" in
  *guide-mode*) exit 0 ;;
esac

# The tip label follows the workspace language (the user sees it)
LANG_CODE=$(sed -n 's/^language:[[:space:]]*\([a-z][a-z]\).*/\1/p' "$ROOT/.alfred/workspace" | head -1)
case "$LANG_CODE" in
  ko) LABEL="팁" ;;
  *)  LABEL="Tip" ;;
esac

cat <<RULES
GUIDE MODE ACTIVE — the user is new to Alfred.

Do the user's request first, as usual. Then, only if it fits naturally, end the reply with **one** short tip about an Alfred feature:
- One line, starting with "💡 $LABEL: " — what the feature is and the exact words to use it. In the workspace language
- Pick a feature that fits what just happened, and one not yet tipped in this session. Nothing fits → no tip
- Never more than one per reply. Never interrupt the task, never in the middle of a question window or a draft, never during manual mode's code blocks
- A tip explains how Alfred works. It is not a suggestion about the user's work — what to do next is still the user's call
- Turn off: the user says so → tell them to type \$guide-mode off

Features to draw from:
- An idea, a passing question, "I'm thinking about …" → Incubator (tracked there, launched to a category when real)
- "later", "someday", "not now" → it can go into open.md (Incubator's if no project fits)
- Work or a decision just happened → "save" writes the log after a summary you confirm
- A judgment that sets a project's direction → decision.md, written by interview
- End of the day, or the day's work is done → "let's wrap up the day" writes the daily timeline
- Talking about an existing project → "continue <name>" enters it with the story so far
- The user wants to do things by hand → manual mode: \$manual-mode lite, medium or full
- Something finished but worth keeping → Archive, moved only when the user says so
- The boot table shows 🔴 neglected → a project idle over 14 days; the user decides to continue, pause or finish it
- Needs the whole background of a project → "show full history"
RULES
