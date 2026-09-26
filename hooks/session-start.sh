#!/usr/bin/env bash
# written by Ungbin_Oh
# created : 2026-09-26
# updated : 2026-09-26
#
# Alfred — SessionStart hook
#
# 작업 폴더(또는 그 상위)에 .alfred/workspace 마커가 있을 때만 동작한다.
# 마커가 없으면 아무것도 출력하지 않는다 — Alfred 와 상관없는 세션을 오염시키지 않기 위해서다.
#
# 마커가 있으면 stdout 으로 다음을 내보낸다 (Claude Code 가 세션 컨텍스트로 넣는다):
#   1. 현재 날짜·시각·요일 (모델에게는 시계가 없다)
#   2. 워크스페이스 루트 경로
#   3. rules/core.md 본문 (공통 규약)
#
# 가정: macOS / Linux, bash. Windows 는 검증하지 않았다.

set -u

PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}"
START_DIR="${CLAUDE_PROJECT_DIR:-$PWD}"

# 상위로 올라가며 마커를 찾는다
find_root() {
  local d="$1"
  while [ -n "$d" ] && [ "$d" != "/" ]; do
    if [ -f "$d/.alfred/workspace" ]; then
      printf '%s' "$d"
      return 0
    fi
    d=$(dirname "$d")
  done
  return 1
}

ROOT=$(find_root "$START_DIR") || exit 0

RULES="$PLUGIN_ROOT/rules/core.md"
[ -f "$RULES" ] || { echo "ALFRED — rules/core.md 를 찾지 못했다 ($RULES). 플러그인 설치를 확인할 것."; exit 0; }

echo "ALFRED ACTIVE"
echo "현재 시각: $(date '+%Y-%m-%d %H:%M (%a)')"
echo "워크스페이스 루트: $ROOT"
echo
echo "아래는 Alfred 공통 규약이다. 워크스페이스 CLAUDE.md 와 부딪히면 CLAUDE.md 가 이긴다."
echo
# 저작 헤더 줄은 세션에 넣지 않는다
grep -v '^written by ' "$RULES"
