<p align="center">
  <img src="https://em-content.zobj.net/source/apple/391/top-hat_1f3a9.png" width="110" />
</p>

<h1 align="center">Alfred</h1>

<p align="center">
  <strong>판단은 주인님께, 정리는 제게.</strong>
</p>

<p align="center">
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-blue?style=flat" alt="License"></a>
  <img src="https://img.shields.io/badge/Claude%20Code-plugin-D97757?style=flat" alt="Claude Code plugin">
  <a href="https://github.com/ungbin-oh/alfred/stargazers"><img src="https://img.shields.io/github/stars/ungbin-oh/alfred?style=flat&color=yellow" alt="Stars"></a>
</p>

<p align="center">
  <a href="#설치">설치</a> •
  <a href="#제가-드리는-것">제가 드리는 것</a> •
  <a href="#일하는-방식">일하는 방식</a> •
  <a href="#자주-쓰시는-말씀">자주 쓰시는 말씀</a> •
  <a href="#업데이트-히스토리">업데이트 히스토리</a> •
  <a href="README.md">English</a>
</p>

written by Ungbin_Oh · created 2026-09-26 · updated 2026-10-03

---

안녕하십니까, 주인님. Alfred 입니다.

저는 Claude Code 를 **개인 비서**로 쓰시도록 돕는 플러그인입니다.
세션을 여시면 모든 프로젝트의 형편을 표로 여쭙고, 무엇을 **왜** 그렇게 정하셨는지 기록해 두며,
작업 도중의 시도와 실패는 제가 곁에서 받아 적습니다.

다만 한 가지는 분명히 해 두겠습니다. **결정은 언제나 주인님의 몫입니다.**
저는 묻지 않으신 제안을 드리지 않고, 무언가를 실행하기 전에는 먼저 여쭙니다.
구현도 제가 먼저 완성해 내밀지 않습니다 — 주인님께서 먼저 시도하시면, 저는 곁에서 살피겠습니다.

> 상태: **v0.1.3.** macOS 에서 로컬 설치 · 초기화 · 브리핑을 시험했습니다 (v0.1.2). v0.1.3 의 규약 변경은 아직 실제 세션에서 시험하지 않았습니다. Linux · Windows 는 아직 시험하지 않았습니다.

## 설치

Claude Code 안에서 이렇게 말씀해 주십시오.

```
/plugin marketplace add ungbin-oh/alfred
/plugin install alfred@alfred
```

그다음 제가 머물 방을 하나 마련해 주시면 됩니다.

1. 전용 폴더를 만들고 그곳에서 Claude Code 를 여십시오
   ```
   mkdir ~/ALFRED && cd ~/ALFRED && claude
   ```
2. `/alfred-init` 이라고 불러 주십시오. 먼저 언어(기본 English, 또는 **한국어**)를 여쭙고, 이어서 성함 · 호칭 · 카테고리를 질문 창으로 여쭙니다.
   만들 파일 목록을 보여 드린 뒤 허락을 받고서야 만듭니다.
   마지막으로 상태줄에 하늘색 `[ALFRED]` 배지를 띄울지 여쭙니다
   (전역 `~/.claude/settings.json` 의 `statusLine` 을 고칩니다. 이미 쓰시는 상태줄이 있으면 옆에 나란히 둘 수 있습니다)
3. **같은 폴더에서 Claude Code 를 한 번 다시 여십시오.** 그때부터 세션마다 제가 먼저 인사를 드립니다
4. "Research 에 Thesis-Experiment 프로젝트 만들어줘" 처럼 첫 프로젝트를 일러 주십시오

## 제가 드리는 것

| 무엇 | 하는 일 |
|---|---|
| **부팅 브리핑** | 세션을 여시면 카테고리별 프로젝트 표 — 상태 · 마지막 갱신 · 방치 일수 · 다음 할 일. 14일 넘게 손대지 않은 active 프로젝트는 🔴 neglected 로 표시만 합니다 |
| **결정 로그** `log.md` | 결과보다 **"그때 왜 그렇게 판단했는가"**. 판단 주체(주인님 / 저)를 항목마다 적습니다 |
| **작업 원장** `trace/` | 명령 · 에러 원문 · 가설과 배제 근거를 작업 도중 제가 바로 적습니다. 저장하실 때 이것을 추려 log 로 올립니다 |
| **판단 문서** `decision.md` | 프로젝트의 방향을 정한 판단만 — 이전 상황 · 계기 · 주인님 말씀 그대로의 생각 · 정하신 방향 · 목적과의 비교. 제가 여쭈어 받아 적습니다. 처음 목적에서 벗어나지 않았는지 스스로 보실 수 있게 |
| **미결 문서** `open.md` | 아직 정하지 않으신 것 — 후보안과 근거. 결정되면 log 에 기록하고 파일 위쪽 '닫힌 것' 표로 옮깁니다 |
| **보관함** `Archive/` | 끝났지만 버리지 않을 산출물과 기록을 브리핑 밖으로. 말씀하실 때만 옮깁니다 |
| **일기** `daily/` | 날짜별 서사와 잡생각. "하루를 정리하자" 하시면 trace 로 타임라인을 씁니다 |
| **질문 창** | 짧게 고르실 것은 텍스트 대신 객관식 질문 창으로 여쭙니다. 답이 질문마다 하나씩 남습니다. 긴 초안은 채팅으로 확인받습니다 |
| **두 언어** | `/alfred-init` 에서 English 또는 한국어를 고르십니다. 규약은 어느 쪽이든 한 벌입니다 |
| `/alfred-init` | 워크스페이스를 차립니다. 만들어지는 파일은 전부 주인님 것입니다 |
| `/manual-mode lite\|medium\|full` | 제 손을 묶는 수동 모드 — 명령 · 코드를 주인님께서 직접 치십니다 |
| `[ALFRED]` 배지 | Alfred 워크스페이스에서만 상태줄에 뜹니다 |

## 일하는 방식

1. **플러그인 훅이 세션마다 공통 규약(`rules/core.md`)을 제게 쥐여 줍니다.** 플러그인을 업데이트하시면 규약도 함께 새로워집니다
2. **`/alfred-init` 은 주인님의 파일을 만듭니다** — 설정이 담긴 `CLAUDE.md` 와 폴더 뼈대. 마음대로 고치셔도 됩니다
3. **둘이 어긋나면 주인님의 것이 이깁니다.** 프로젝트 `log.md` 의 `## 형식` > 워크스페이스 `CLAUDE.md` > 공통 규약
4. **`.alfred/workspace` 표식이 없는 폴더에서는 저는 아무것도 하지 않습니다.** 다른 작업에 끼어들지 않습니다
5. 시각은 제가 지어내지 않고 셸의 `date` 로 채웁니다 — 제게는 시계가 없으니까요

```
~/ALFRED/
├── CLAUDE.md              주인님의 설정과 규칙
├── .alfred/workspace      제가 머무는 방이라는 표식 (언어 설정도 여기에)
├── project-logs/          프로젝트별 log.md · decision.md · open.md · trace/
├── project-workspace/     실제 코드 · 산출물
├── daily/                 날짜별 일기
└── Archive/               안 쓰지만 버리지 않는 것 — 브리핑은 여기를 보지 않습니다
```

언어를 나중에 바꾸시려면 `.alfred/workspace` 의 `language:` 줄을 `ko` 또는 `en` 으로 고치고 Claude Code 를 다시 여십시오.

## 자주 쓰시는 말씀

| 말씀 | 제가 하는 일 |
|---|---|
| `X 이어서` | 프로젝트 X 로 들어가 지금까지의 흐름을 브리핑 |
| `저장해` | 오늘 한 일과 결정을 요약해 보여 드리고, 허락을 받은 뒤 log.md 에 기록 |
| `하루를 정리하자` | 오늘 trace 로 daily 의 Timeline 작성 |
| `전체 히스토리 봐` | 해당 프로젝트 로그 통독 |

## 새 버전을 받으시려면

```
/plugin marketplace update alfred
/plugin uninstall alfred@alfred
/plugin install alfred@alfred
```

그다음 Claude Code 를 한 번 다시 여십시오. 워크스페이스의 로그와 설정은 그대로입니다.

## 업데이트 히스토리

버전마다 무엇이 바뀌었는지는 [docs/ko/CHANGELOG.md](docs/ko/CHANGELOG.md) 에 적어 두었습니다 (정본은 영어 [CHANGELOG.md](CHANGELOG.md)).
최신: **0.1.3** (2026-10-03) — open.md 닫힌 것 표 · Timeline 요약 표 · neglected 표시 · Archive · decision.md.

## 물러나게 하시려면

```
/plugin uninstall alfred@alfred
```

워크스페이스의 로그와 일기는 그대로 남습니다. 모두 주인님의 것이니까요.

상태줄 배지를 켜셨다면 따로 되돌려 주십시오. `~/.claude/settings.json` 의 `statusLine` 을 지우시거나,
나란히 띄우기로 켜셨다면 `~/.claude/.alfred-statusline-chain` 에 저장된 원래 명령으로 되돌린 뒤
`~/.claude/alfred-statusline.sh` 와 `.alfred-statusline-chain` 을 지우시면 됩니다.

## 한국어 규약

제가 따르는 규약의 정본은 영어 한 벌(`rules/core.md`)입니다. 주인님께서 읽으실 한국어 번역본은 [`docs/ko/`](docs/ko/) 에 두었습니다.

## 필요한 것

- Claude Code (플러그인 지원 버전)
- macOS 또는 Linux (훅이 bash 스크립트입니다. Windows 에서는 아직 시험해 보지 못했습니다)

## License

[MIT](LICENSE) © 2026 Ungbin Oh
