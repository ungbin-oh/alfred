# alfred-init — Codex 판에서 다른 점

written by Ungbin_Oh · created 2026-10-05 · updated 2026-10-06

> **한국어 번역본이다.** 정본은 `alfred-codex/skills/alfred-init/SKILL.md` (영어) 이고 Codex 는 이 파일을 읽지 않는다.
> 대부분은 Claude 판([alfred-init.md](alfred-init.md))과 같다. 여기에는 다른 점만 적는다.

- **설정 파일은 `AGENTS.md`** — `templates/<lang>/AGENTS.md` 로 만든다. 이미 있으면 덮어쓰지 않고, 끝에 Alfred 설정 절을 덧붙일지 / 멈출지 묻는다
- **규약을 워크스페이스에 복사하지 않는다** — `.alfred/rules.md` 도, `@.alfred/rules.md` 줄도 없다. 세션 시작 훅이 규약을 세션마다 넣는다
- **질문 창** — `request_user_input` 이 켜져 있으면 그것으로 (`codex --enable default_mode_request_user_input`), 없으면 채팅으로 한 번에 하나씩, 선택지를 적어서 묻는다
- **질문 창 규칙 하나** — 질문 창으로 묻는 단계에서는 `request_user_input` 호출이 바로 다음 행동이다. 그 전에 채팅에 아무것도 쓰지 않는다
  (요약 · 선택지 · "창에서 답해 주세요" 모두). 사이에 다른 도구도 돌리지 않고, 질문 뒤의 말은 답을 받은 뒤에 쓴다.
  선택지를 채팅에 먼저 썼을 때 창이 그 뒤로 밀리거나("Queued follow-up inputs", shift+← 로만 답함) 아예 안 열렸다
- **git 질문도 창으로** — 만든 직후 `request_user_input` 으로 `git 사용` / `지금은 안 함` 을 묻는다. 채팅에는 먼저 아무것도 쓰지 않는다.
  `git 사용` 일 때만 `git init`. 마무리 안내는 답을 받은 뒤 한 번에
- **창 하나에 질문 셋까지** — 그래서 2번 창은 사용자 이름 · 호칭 · 비서 이름, 3번 창은 카테고리 · 저작 헤더
- **상태줄 배지 절이 없다** — Codex 는 사용자 상태줄을 지원하지 않는다. 그래서 "마무리 안내" 가 5절이 된다
- **마무리 안내** — 같은 폴더에서 Codex 를 같은 명령(`codex --enable default_mode_request_user_input`)으로 다시 열어야 한다. 옵션이 없으면 질문 창이 안 뜬다. 처음 열 때 Codex 가 플러그인 훅을 검토 · 신뢰하라고 묻고, 신뢰 전에는 규약이 들어가지 않는다
- 마커 `.alfred/workspace` 의 version 은 0.1.11
