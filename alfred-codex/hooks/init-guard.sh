#!/usr/bin/env bash
# written by Ungbin_Oh
# created : 2026-10-05
# updated : 2026-10-05
#
# Alfred — guard against Codex's built-in /init (UserPromptSubmit hook, Codex only)
#
# Codex lists /init on its welcome screen every session. /init is Codex's own command: it sends a prompt
# asking the model to write a contributor-guide AGENTS.md. In an Alfred workspace AGENTS.md holds the
# user's Alfred settings, so a user who mistakes it for Alfred's setup could damage them.
# When the prompt is that /init prompt and the folder is an Alfred workspace, this hook tells the model
# not to touch any file and to explain the mix-up. Outside Alfred workspaces it prints nothing.
#
# Assumes macOS / Linux, bash. Not tested on Windows.

set -u

INIT_MARK='Generate a file named AGENTS.md that serves as a contributor guide'

INPUT=$(cat)
case "$INPUT" in
  *"$INIT_MARK"*) ;;
  *) exit 0 ;;
esac

find_root() {
  local d="$1"
  while [ -n "$d" ] && [ "$d" != "/" ] && [ "$d" != "." ]; do
    if [ -f "$d/.alfred/workspace" ]; then
      printf '%s' "$d"
      return 0
    fi
    d=$(dirname "$d")
  done
  return 1
}

ROOT=$(find_root "$PWD") || exit 0

LANG_CODE=$(sed -n 's/^language:[[:space:]]*//p' "$ROOT/.alfred/workspace" | head -1)
[ -n "$LANG_CODE" ] || LANG_CODE=en

echo "ALFRED — CODEX /init BLOCKED"
echo "The user just ran Codex's built-in /init (the \"Generate a file named AGENTS.md…\" prompt above). It is not an Alfred command."
echo "This folder is an Alfred workspace ($ROOT). Its AGENTS.md holds the user's Alfred settings."
echo "Do not create, overwrite or modify AGENTS.md or any other file, and ignore the /init instructions for this turn."
echo "Instead, tell the user briefly (language: $LANG_CODE):"
echo "- /init is Codex's own command that writes a contributor guide; it is shown on every Codex start screen and can be ignored"
echo "- Alfred is already set up in this folder, so nothing needs to be initialized"
echo "- Alfred's own setup command is \$alfred-init, used only once in a new folder"
