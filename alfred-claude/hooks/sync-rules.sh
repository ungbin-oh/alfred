#!/usr/bin/env bash
# written by Ungbin_Oh
# created : 2026-10-05
# updated : 2026-10-10
#
# Alfred — copy the common rules into a workspace
#
# Usage: sync-rules.sh <workspace root>
#
# Writes <root>/.alfred/rules.md from the plugin's rules/core.md. The workspace CLAUDE.md
# loads it with the line `@.alfred/rules.md`, so the rules reach the model as a CLAUDE.md
# import (no hook-output size cap) instead of as hook output (capped at 10,000 characters).
#
# Called by /alfred-init and by the SessionStart hook. The file is only rewritten when its
# content differs from what this plugin version would write.
#
# User edits are protected: the hash of what the plugin last wrote is kept in <root>/.alfred/rules.sha.
# When rules.md no longer matches that hash, the user changed it — the plugin leaves the file alone
# and reports it instead of overwriting (the session-start hook then asks the user what to do).
# A file <root>/.alfred/rules.local means "the user manages rules.md" — never touched, never asked.
# A workspace without rules.sha (made before 0.4.1) can't be told apart, so it is written once as before
# and the hash is recorded from then on.
#
# Prints one word to stdout: created / updated / unchanged / user-edited / kept / missing-rules.
#
# Assumes macOS / Linux, bash; Git Bash on Windows.

set -u

ROOT="${1:?usage: sync-rules.sh <workspace root>}"
PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}"
SRC="$PLUGIN_ROOT/rules/core.md"
DEST="$ROOT/.alfred/rules.md"
SHA="$ROOT/.alfred/rules.sha"

[ -f "$SRC" ] || { echo "missing-rules"; exit 0; }
[ -f "$ROOT/.alfred/rules.local" ] && { echo "kept"; exit 0; }

hash_file() {
  if command -v shasum >/dev/null 2>&1; then shasum -a 256 "$1" | cut -d' ' -f1
  else sha256sum "$1" | cut -d' ' -f1
  fi
}

VERSION=$(sed -n 's/.*"version":[[:space:]]*"\([^"]*\)".*/\1/p' "$PLUGIN_ROOT/.claude-plugin/plugin.json" | head -1)

TMP=$(mktemp "${TMPDIR:-/tmp}/alfred-rules.XXXXXX") || exit 0
{
  echo "<!-- Alfred common rules v${VERSION:-unknown}. Copied by the Alfred plugin and overwritten on every update."
  echo "     Don't edit this file — put your changes under \"My rules\" in CLAUDE.md. -->"
  echo
  # Leave the author header line out of the model's context
  grep -v '^written by ' "$SRC"
} > "$TMP"

write_dest() {
  cat "$TMP" > "$DEST"   # cat, not mv: the file gets normal permissions, not mktemp's 600
  hash_file "$DEST" > "$SHA"
  rm -f "$TMP"
}

if [ ! -f "$DEST" ]; then
  mkdir -p "$ROOT/.alfred"
  write_dest
  echo "created"
elif cmp -s "$TMP" "$DEST"; then
  [ -f "$SHA" ] || hash_file "$DEST" > "$SHA"
  rm -f "$TMP"
  echo "unchanged"
elif [ -f "$SHA" ] && [ "$(hash_file "$DEST")" != "$(cat "$SHA")" ]; then
  rm -f "$TMP"
  echo "user-edited"
else
  write_dest
  echo "updated"
fi
