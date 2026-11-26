# logviser

written by Ungbin_Oh · created 2026-11-15 · updated 2026-11-26

> **한국어 번역본이다.** 정본은 `alfred-claude/skills/logviser/SKILL.md` (영어) 이고 Claude Code 는 이 파일을 읽지 않는다.
> 정본이 바뀌면 이 파일도 같은 커밋에서 맞춘다. Codex 판(`alfred-codex/skills/logviser/SKILL.md`)은 호출 이름만 `$logviser` 로 다르다.

스킬 설명: 로그 권고 토글 (on / lite / auto / off / status / report / reset). 사용자가 /logviser 를 입력할 때만 쓴다. 켜 두면 프로젝트의
log.md 로 안 옮긴 trace 가 임계를 넘을 때 비서가 log 저장을 묻는다. auto 에서는 비서가 항목을 직접 쓴다.

## logviser

로그 권고. 일하는 동안 trace 는 쌓이고 log.md 는 "저장해" 할 때만 쓰여서, 며칠씩 저장 없이 지나가기 쉽다. 켜 두면 플러그인의
UserPromptSubmit 훅이 프로젝트마다 log.md 에 아직 없는 trace 수를 세고, 임계를 넘은 프로젝트가 있으면 비서에게 물으라고 한다 — auto 에서는 항목을 쓰라고 한다.

상태는 워크스페이스의 `.alfred/logviser` 파일 한 줄(`on` · `lite` · `auto`)이다. 파일이 없으면 꺼짐.
워크스페이스 루트 = 작업 폴더 또는 `.alfred/workspace` 가 있는 가장 가까운 상위 폴더. 없으면 "Alfred 워크스페이스가 아니다" 라고 하고 멈춘다.

## 인자별

| 인자 | 하는 일 |
|---|---|
| `on` | `.alfred/logviser` 에 `on` 을 쓴다. 켜졌다는 것과 하는 일 한 줄 (아래) |
| `lite` | `.alfred/logviser` 에 `lite` 를 쓴다. lite 로 켜졌다는 것과 하는 일 한 줄 |
| `auto` | `.alfred/logviser` 에 `auto` 를 쓴다. auto 로 켜졌다는 것과 하는 일 (아래) — 이제부터 log 항목을 묻지 않고 쓰고, 항목마다 `**Auto:**` 줄이 붙는다는 것을 분명히 말한다 |
| `off` | `.alfred/logviser` 를 지운다. 꺼졌다고 알린다 |
| `status` | 켜짐(어느 단계) 또는 꺼짐, 그리고 표 |
| `report` | 표만 |
| `reset` | `.alfred/logviser-seen` 을 지운다. 임계를 넘은 프로젝트는 다음 턴부터 다시 묻는다고 알린다 |
| (없음) | 사용법 한 줄: `/logviser on \| lite \| auto \| off \| status \| report \| reset` |
| 그 밖 | 모르는 인자라고 하고 위 사용법 |

**표** — 이번 턴에 훅이 넣어 준다 ("LOGVISER — table for the logviser skill this turn"). 그대로 보여 준다.
컨텍스트에 없으면 이 세션에 훅이 안 붙은 것이라고 말한다. 손으로 세지 않는다.

## 단계

- **on** — 프로젝트가 임계를 넘으면, 비서가 사용자 요청을 먼저 처리하고 질문 창을 띄운다: 무엇을 했는지 (trace 헤더에서),
  "어떤 판단 · 의도로 진행하셨나요?", 선택지 "지금 log 로 저장" / "스킵". 직접 입력 칸에 적은 판단은 log 항목의 Decision & Reason 이 되고, 쓰기 전에 초안을 보여 준다
- **lite** — 답 끝에 한 줄 (`📝 <code>: log 안 된 trace N건`), 창 없음
- **auto** — 질문도 초안도 없다: 프로젝트가 임계를 넘으면 비서가 사용자 요청을 먼저 처리하고, trace 를 읽어 log 항목을 직접 쓴 뒤
  답 끝에 무엇을 저장했는지 알린다. 확인 절차가 번거로운 사람을 위한 단계다 — auto 를 켠 것이 미리 준 확정이다
  - 이런 항목은 `**Trace:**` 바로 아래에 `**Auto:** written by logviser auto — not confirmed by the user` 줄을 단다.
    사용자가 확정한 항목과 구분하기 위해서다
  - 사용자의 의도는 trace 에 적힌 만큼만 넣는다: 결정은 trace 에 그 결정과 판단 주체가 적혀 있을 때만 쓴다. 이유를 지어내지 않는다.
    질의응답만 한 구간은 Problem 과 Result 만 쓴다
  - 아직 진행 중인 주제는 다음으로 미룬다. 단, 수가 임계의 두 배에 이르면 미루지 않는다
  - `next_action` · `objective` · `status` 는 건드리지 않는다. open.md · decision.md 는 여기서 쓰지 않는다
  - 틀린 auto 항목은 고치지 않고 (log 는 덧붙이기만) 정정 항목을 덧붙인다
  - 사용자가 요청한 저장("저장해")은 지금처럼 초안을 보이고 기다린다

## 세는 법

- log 안 된 수 = 가장 새 trace 파일의 가장 큰 `<code>-trace<N>` − log 의 `**Trace:**` 줄에 걸린 가장 큰 번호. 그 프로젝트 code 의 것만 센다
- 임계: 8, 또는 그 프로젝트 log.md frontmatter 의 `logviser: N`
- 스킵하면 같은 프로젝트는 임계만큼 더 쌓인 뒤에만 다시 묻는다 (8 → 16 → 24 …)
- 하루 끝: 켜져 있는 동안 사용자가 하루가 끝났다고 하면 ("퇴근" · "오늘 끝" · "wrap up the day" …) 훅이 표를 넣고, 비서는 답 끝에 표를 보여 주며 저장할지 묻는다. auto 에서는 묻는 대신 표의 모든 프로젝트 항목을 쓴다 (진행 중인 주제 포함)

Codex 에서는 상태가 thread 이름에 보인다: `[ALFRED] [LOGVISER INC 9] 2026-11-15 #2`, 단계에 따라 `LOGVISER-lite` · `LOGVISER-auto` (훅이 바꾼다. `codex --remote unix://` 로 띄우면 바로, 아니면 /resume 뒤).

훅은 권고할 턴에 자세한 규칙을 넣는다 (auto 도). 이번 턴(켜고 끄는 턴)에는 표만 넣는다.
