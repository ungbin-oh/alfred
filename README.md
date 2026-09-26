# Alfred

written by Ungbin_Oh · created 2026-09-26 · updated 2026-09-26

Claude Code 를 **개인 비서**로 쓰는 작업 방식을 담은 플러그인입니다.

- 세션을 열면 모든 프로젝트의 현황을 표로 브리핑합니다
- 프로젝트마다 **"그때 왜 그렇게 판단했는가"** 중심의 결정 로그(log.md)를 남깁니다
- 작업 도중의 시도·에러·가설은 날짜별 작업 원장(trace)에 비서가 바로 적습니다
- 날짜별 일기(daily)와 하루 타임라인을 지원합니다
- **결정은 사용자가, 정리는 비서가.** 비서는 묻지 않은 제안을 하지 않고, 실행 전에 확인하며,
  구현도 먼저 완성해 내놓지 않습니다 (힌트 사다리)

> 상태: **v0.1.1.** macOS 에서 로컬 설치 · 초기화 · 브리핑을 시험했습니다. Linux · Windows 는 아직 시험하지 않았습니다.

## 설치

Claude Code 안에서:

```
/plugin marketplace add ungbin-oh/alfred
/plugin install alfred@alfred
```

## 처음 쓰기

1. Alfred 전용 폴더를 하나 만들고 그 폴더에서 Claude Code 를 엽니다
   ```
   mkdir ~/alfred-workspace && cd ~/alfred-workspace && claude
   ```
2. `/alfred-init` 을 입력합니다. 이름·호칭·카테고리를 객관식 질문 창으로 묻고, 만들 파일 목록을 보여 준 뒤 확인을 받고 만듭니다.
   마지막에 상태줄에 하늘색 `[ALFRED]` 배지를 띄울지 묻습니다 (전역 `~/.claude/settings.json` 의 `statusLine` 을 고칩니다. 기존 상태줄이 있으면 옆에 같이 띄울 수 있습니다)
3. **Claude Code 를 같은 폴더에서 다시 시작합니다.** 이때부터 세션마다 브리핑이 나옵니다
4. "Research 에 Thesis-Experiment 프로젝트 만들어줘" 처럼 첫 프로젝트를 만듭니다

## 자주 쓰는 말

| 말 | 동작 |
|---|---|
| `X 이어서` | 프로젝트 X 로 들어가 지금까지의 흐름을 브리핑 |
| `저장해` | 오늘 한 일·결정을 요약해 보여 주고, 확인받은 뒤 log.md 에 기록 |
| `하루를 정리하자` | 오늘 trace 로 daily 의 Timeline 작성 |
| `전체 히스토리 봐` | 해당 프로젝트 로그 통독 |
| `/manual-mode lite\|medium\|full` | 명령·코드를 직접 치는 수동 모드 |

## 구조

```
~/alfred-workspace/
├── CLAUDE.md              내 설정과 내 규칙 (내 파일, 자유롭게 수정)
├── .alfred/workspace      Alfred 워크스페이스 표시
├── project-logs/          프로젝트별 log.md · open.md · trace/
├── project-workspace/     실제 코드·산출물
└── daily/                 날짜별 일기
```

공통 규약은 플러그인 안(`rules/core.md`)에 있고 세션마다 자동으로 들어갑니다.
플러그인을 업데이트하면 공통 규약도 바뀝니다. **내 `CLAUDE.md` 에 적은 규칙이 공통 규약보다 우선합니다.**

`.alfred/workspace` 가 없는 폴더에서는 Alfred 가 아무것도 하지 않습니다.

## 제거

```
/plugin uninstall alfred@alfred
```

워크스페이스 폴더의 파일(로그·일기)은 지워지지 않습니다. 모두 내 파일입니다.

상태줄 배지를 켰다면 따로 되돌립니다. `~/.claude/settings.json` 의 `statusLine` 을 지우거나,
같이 띄우기로 켰다면 `~/.claude/.alfred-statusline-chain` 에 저장된 원래 명령으로 되돌린 뒤
`~/.claude/alfred-statusline.sh` 와 `.alfred-statusline-chain` 을 지웁니다.

## 요구 사항

- Claude Code (플러그인 지원 버전)
- macOS 또는 Linux (훅이 bash 스크립트입니다. Windows 는 시험하지 않았습니다)

---

## English (short)

Alfred turns Claude Code into a personal assistant with a fixed workflow: a status briefing at session start,
decision-first project logs, per-day work traces, and daily notes. The user makes every decision; Alfred organizes.

Install: `/plugin marketplace add ungbin-oh/alfred` → `/plugin install alfred@alfred`.
Then run `/alfred-init` in an empty folder and restart Claude Code there. Rules are in Korean in v0.1.

## License

[MIT](LICENSE) © 2026 Ungbin Oh
