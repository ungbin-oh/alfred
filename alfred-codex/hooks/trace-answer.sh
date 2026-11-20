#!/usr/bin/env bash
# written by Ungbin_Oh
# created : 2026-11-20
# updated : 2026-11-20
#
# Alfred — trace-answer Stop hook, launcher
#
# Runs hooks/trace-answer.py with the hook's stdin: when a reply ends, the final answer of the turn is put
# below the trace entry written in that turn, as a folded quote box. What it does and where is described
# at the top of trace-answer.py.
#
# The work needs python 3 (the transcript is JSON lines). Without python3 / python on PATH this prints
# nothing and exits 0 — the session goes on, only the answer is not copied into the trace.
# Prints nothing either way: a Stop hook's output is not for the model.
# Assumes bash. On Windows, Codex runs it through hooks/run-windows.ps1 with Git Bash (Git for Windows).

input=$(cat)
dir=$(cd "$(dirname "$0")" && pwd)
for py in python3 python; do
  command -v "$py" >/dev/null 2>&1 || continue
  printf '%s' "$input" | "$py" -I "$dir/trace-answer.py" >/dev/null 2>&1
  exit 0
done
exit 0
