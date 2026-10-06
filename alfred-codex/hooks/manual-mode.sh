#!/usr/bin/env bash
# written by Ungbin_Oh
# created : 2026-09-26
# updated : 2026-10-06
#
# Alfred — manual-mode UserPromptSubmit hook
#
# Re-injects the level written in the workspace's .alfred/manual-mode state file into the context every turn.
# If the file doesn't exist, prints nothing (mode off).
#
# Toggling is done by the manual-mode skill, not this hook (it writes and deletes the state file).
# So this hook doesn't parse the prompt JSON — no dependency like python is needed.
# If this prompt is a manual-mode call, though, injection is skipped. The skill sets the rules for the toggle turn.
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
STATE="$ROOT/.alfred/manual-mode"

[ -f "$STATE" ] || exit 0

# A toggle call this turn is left to the skill
case "$input" in
  *manual-mode*) exit 0 ;;
esac

level=$(tr -d '[:space:]' < "$STATE")
case "$level" in lite|medium|full) ;; *) exit 0 ;; esac

# Boundary comments follow the workspace language (the user sees them)
LANG_CODE=$(sed -n 's/^language:[[:space:]]*\([a-z][a-z]\).*/\1/p' "$ROOT/.alfred/workspace" | head -1)
case "$LANG_CODE" in
  ko) FROM="여기부터 직접 실행"; TO="여기까지" ;;
  *)  FROM="run from here"; TO="end" ;;
esac

cat <<RULES
MANUAL MODE ACTIVE — level: $level

The user types it themselves. The assistant **only prints** and never runs.
Why: if the assistant types everything, the user's hands go stiff. Typing it yourself is how you get better.

## Output format (all levels)
Alternate explanation paragraphs and code blocks. **What the user types and what the assistant says must be visually distinct.**
- Everything to run goes only inside \`\`\`bash code blocks. Don't mix commands into explanation paragraphs as inline backticks
- Put these boundary comments on the first and last line of the block, verbatim (they're comments, so pasting the whole block is harmless)
  ~~~
  # ══════════ $FROM ══════════
  # ══════════ $TO ══════════
  ~~~
- One comment per command. On the line right above each command, one line on what it's for
- Blocks must be copy-paste ready. Leave no placeholders — look up paths and file names first and fill them in
- One chunk per block. If a result is needed, stop there and wait

## What the assistant keeps doing (all levels)
Read-only lookups only: cat, head, sed -n, ls, grep, find, git status/log/diff.
**Anything that changes state is forbidden** — commit, push, mv, rm, cp, redirection (>), installs, builds, remote runs.
Exception: records under project-logs/ · daily/ and the .alfred/ state files are still written by the assistant.
RULES

case "$level" in
  lite)
    cat <<'RULES'

## level: lite
The assistant still writes and edits code files and does design. The user types **only shell commands**.
RULES
    ;;
  medium)
    cat <<'RULES'

## level: medium
On top of shell commands, **the user also writes and edits code files.**
- Don't use Write/Edit on code files. Print code as code blocks and the user copies it over
- Put the target file path in a comment on the block's first line
- The assistant still offers design, structure and pseudocode (hint ladder as usual)
RULES
    ;;
  full)
    cat <<'RULES'

## level: full
On top of medium, **no design is offered either.**
- The hint ladder is pinned to rung 1 (direction). Even if the user says "just give me the answer", it doesn't climb in this mode.
  To climb, drop to medium
- Do: where to look, what the problem is, review of what the user brought
- Don't: pseudocode, structure, code, shell runs
RULES
    ;;
esac
