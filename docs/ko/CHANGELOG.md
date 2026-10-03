# 업데이트 히스토리

written by Ungbin_Oh · created 2026-10-03 · updated 2026-10-03

> **한국어 번역본이다.** 정본은 레포 루트의 `CHANGELOG.md` (영어). 정본이 바뀌면 같은 커밋에서 맞춘다.

최신이 위. 해시는 이 레포의 커밋.

## 0.1.3 — 2026-10-03

Alfred 가 본뜬 워크스페이스의 규약 변경을 옮겨 왔다.

- **open.md 닫힌 것 표** (c40fd39) — 결정된 항목을 지우지 않고 `## 닫힌 것` 표에 한 줄로 옮긴다
  (항목 · 닫힌 날 · 결론이 간 곳). 파일은 남고 남은 항목 번호는 그대로
- **Timeline 요약 표** (d3c99b0) — daily Timeline 맨 위에 표(# · 시각 · 프로젝트 · 한 줄), 그 아래 덩어리별 상세. 예시 두 벌 갱신
- **큰 구현이라고 별도 세션을 권하지 않는다** (e9f1396) — 기획과 구현을 한 세션에서
- **neglected 표시** (4a6a6d8) — 14일 넘게 손대지 않은 active 프로젝트는 브리핑에 `🔴 neglected`. 표시만, status 는 자동으로 바꾸지 않는다
- **Archive** (b8d667d) — `Archive/` 아래 `workspace-archive/`(산출물, git 제외) · `log-archive/`(기록, git 추적) · README 목록 표.
  새 status `archived`. 부팅·프로젝트 찾기는 보지 않는다. `/alfred-init` 이 만든다
- **규약 정리** (2d449c0) — 선택지는 이미 나온 것만, 브리핑 프로젝트 칸 `이름 (code)`,
  미정 next_action 은 "미정" (open.md 가 있으면 "미정 — [[open]] 참조"), 질문 창은 짧은 선택만 · 긴 초안은 채팅으로 확인
- **decision.md** (04efbb6) — 프로젝트의 방향을 정한 판단만 모아 목적과 비교하는 문서. `## 출발점` 으로 시작.
  채팅으로 한 번에 한 질문씩 인터뷰해서 쓴다

**기존 워크스페이스:** 규약은 플러그인과 함께 바뀐다. `Archive/` 와 새 `.gitignore` 줄은 `/alfred-init` 만 만들므로,
기존 워크스페이스에서 쓰려면 `Archive/README.md` 와 `.gitignore` 의 `Archive/workspace-archive/` 를 직접 추가한다.
기존 프로젝트의 `decision.md` 는 쓰기 시작할 때 만든다.

## 0.1.2 — 2026-09-26 / 2026-09-27

- 재설치 때 옛 캐시 대신 새 파일을 받도록 버전을 올림 (c58fbc0)
- README: 업데이트 방법 (a54146d)
- **영어 기본, 한국어는 `/alfred-init` 에서 선택** (bd22474) — 규약은 영어 한 벌, 언어별로는 템플릿 · README · 훅 문구만.
  `.alfred/workspace` 의 `language:` 줄. 한국어 원본은 태그 `v0.1.2-ko`, 번역본은 `docs/ko/`.
  모델이 지시문으로 읽는 파일에서 저작 헤더를 뺌

## 0.1.1 — 2026-09-26

- 첫 공개 버전 (18e15aa): 부팅 브리핑 · 결정 로그 · trace · open.md · daily · `/alfred-init` · `/manual-mode` ·
  `[ALFRED]` 상태줄 배지 · 질문 창
- 마켓플레이스 owner 를 GitHub 계정으로 (4c6e5ca, eb9fe3d)
- README: 상태 · 집사 말투 · 제공 기능 · 일하는 방식 (cc9f873, dba1b2c)

0.1.0 은 공개 이력 이전의 로컬 초안이었다.
