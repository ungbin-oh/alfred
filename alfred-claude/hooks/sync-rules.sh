#!/usr/bin/env bash
# written by Ungbin_Oh
# created : 2026-10-05
# updated : 2026-10-05
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
# Prints one word to stdout: created / updated / unchanged / missing-rules.
#
# Assumes macOS / Linux, bash. Not tested on Windows.

set -u

ROOT="${1:?usage: sync-rules.sh <workspace root>}"
PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}"
SRC="$PLUGIN_ROOT/rules/core.md"
DEST="$ROOT/.alfred/rules.md"

[ -f "$SRC" ] || { echo "missing-rules"; exit 0; }

VERSION=$(sed -n 's/.*"version":[[:space:]]*"\([^"]*\)".*/\1/p' "$PLUGIN_ROOT/.claude-plugin/plugin.json" | head -1)

TMP=$(mktemp "${TMPDIR:-/tmp}/alfred-rules.XXXXXX") || exit 0
{
  echo "<!-- Alfred common rules v${VERSION:-unknown}. Copied by the Alfred plugin and overwritten on every update."
  echo "     Don't edit this file — put your changes under \"My rules\" in CLAUDE.md. -->"
  echo
  # Leave the author header line out of the model's context
  grep -v '^written by ' "$SRC"
} > "$TMP"

if [ ! -f "$DEST" ]; then
  mkdir -p "$ROOT/.alfred"
  cat "$TMP" > "$DEST"; rm -f "$TMP"   # cat, not mv: the file gets normal permissions, not mktemp's 600
  echo "created"
elif cmp -s "$TMP" "$DEST"; then
  rm -f "$TMP"
  echo "unchanged"
else
  cat "$TMP" > "$DEST"; rm -f "$TMP"
  echo "updated"
fi
