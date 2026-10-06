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
  <img src="https://img.shields.io/badge/Codex-plugin-10A37F?style=flat" alt="Codex plugin">
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

written by Ungbin_Oh · created 2026-09-26 · updated 2026-10-06

---

### 당신의 모든 일을 기록하고, 추적하세요.

프로젝트 다섯 개를 동시에 굴리고 계신가요? Alfred 가 하나하나 놓치지 않고 붙잡아 둡니다.
무엇을 했고, 무엇을 정했고, **왜** 그렇게 정했는지 — 언제 돌아와도 멈춘 그 자리에서 바로 이어 가세요.

- 🎩 **세션을 열면 모든 프로젝트가 한눈에** — 상태 · 마지막 작업 · 다음 할 일을 표 하나로
- 📝 **모든 결정을, 그 이유와 함께** — 나중에 떠올리는 게 아니라 일하는 그 순간에 기록
- 🧭 **결정은 당신이, 정리는 Alfred 가** — 묻지 않은 제안 없이, 허락 없이는 아무것도 실행하지 않습니다

멀티태스킹을 도와, 당신이 일하는 방식을 완전히 바꿔 드리겠습니다.

## 설치

Windows 에서는 [Git for Windows](https://git-scm.com/download/win) 를 먼저 설치해 주십시오 (`winget install --id Git.Git -e`). 제 훅이 그 안의 Git Bash 로 돕니다.

**Claude Code**
```
claude plugin marketplace add ungbin-oh/alfred
claude plugin install alfred@alfred
mkdir ~/ALFRED
cd ~/ALFRED
claude
# 세션에서: /alfred-init  → 끝나면 Claude Code 다시 열기
```

**Codex**
```
codex plugin marketplace add ungbin-oh/alfred
codex plugin add alfred-codex@alfred
codex features enable default_mode_request_user_input   # 한 번만: 질문 창을 계속 켜 둔다
mkdir ~/ALFRED
cd ~/ALFRED
codex
# 훅 신뢰를 물으면 신뢰 → $alfred-init  → 끝나면 Codex 다시 열기
```

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

1. **플러그인이 공통 규약(`alfred-claude/rules/core.md`)의 복사본을 `.alfred/rules.md` 에 두고, 주인님의 `CLAUDE.md` 가 `@.alfred/rules.md` 한 줄로 그것을 불러옵니다.** 플러그인을 업데이트하시면 복사본도 함께 새로워집니다
2. **`/alfred-init` 은 주인님의 파일을 만듭니다** — 설정이 담긴 `CLAUDE.md` 와 폴더 뼈대. 마음대로 고치셔도 됩니다
3. **둘이 어긋나면 주인님의 것이 이깁니다.** 프로젝트 `log.md` 의 `## 형식` > 워크스페이스 `CLAUDE.md` > 공통 규약
4. **`.alfred/workspace` 표식이 없는 폴더에서는 저는 아무것도 하지 않습니다.** 다른 작업에 끼어들지 않습니다
5. 시각은 제가 지어내지 않고 셸의 `date` 로 채웁니다 — 제게는 시계가 없으니까요

```
~/ALFRED/
├── CLAUDE.md              주인님의 설정과 규칙
├── .alfred/workspace      제가 머무는 방이라는 표식 (언어 설정도 여기에)
├── .alfred/rules.md       공통 규약 복사본, 플러그인이 관리합니다 — 고치지 마십시오
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
claude plugin marketplace update alfred && claude plugin update alfred@alfred      # Claude Code
codex plugin marketplace upgrade alfred && codex plugin add alfred-codex@alfred    # Codex
```

워크스페이스의 로그와 설정은 그대로입니다.

## 물러나게 하시려면

```
claude plugin uninstall alfred@alfred      # Claude Code
codex plugin remove alfred-codex@alfred    # Codex
```

로그와 일기는 그대로 남습니다 — 모두 주인님의 것입니다. 상태줄 배지를 켜셨다면 `~/.claude/settings.json` 의 `statusLine` 을 지워 주십시오.

## 한국어 규약

제가 따르는 규약의 정본은 영어 한 벌(`alfred-claude/rules/core.md`, `alfred-codex/` 에도 같은 사본)입니다. 주인님께서 읽으실 한국어 번역본은 [`docs/ko/`](docs/ko/) 에 두었습니다.

## 필요한 것

- Claude Code (플러그인 지원 버전), 또는 플러그인을 지원하는 Codex CLI (0.160.0 에서 확인)
- macOS, Linux 또는 Windows. 훅이 bash 스크립트라서, Windows 에서는 Claude Code · Codex 모두 Git for Windows (Git Bash) 가 있어야 합니다 — `winget install --id Git.Git -e` 또는 [git-scm.com](https://git-scm.com/download/win)

## License

[MIT](LICENSE) © 2026 Ungbin Oh

## 업데이트 히스토리

버전마다 무엇이 바뀌었는지는 [docs/ko/CHANGELOG.md](docs/ko/CHANGELOG.md) 에 적어 두었습니다 (정본은 영어 [CHANGELOG.md](CHANGELOG.md)). 두 플러그인은 버전 번호 하나를 같이 쓰고, 바뀐 것마다 [Claude] · [Codex] · [공통] 을 붙입니다.
최신: **0.1.15** (2026-10-06) — 버그 수정: `alfred-init` 의 비서 이름 질문에 선택지가 늘 둘이라, 영어 설정에서도 빠지지 않습니다. 그 전 **0.1.14** (2026-10-06) — Claude Code: Alfred 워크스페이스에서 새로 연 세션에 날짜 이름이 붙습니다. 그 전 **0.1.13** (2026-10-06) — Codex: `alfred-init` 이 생성 확인과 git 을 일부러 채팅으로 묻고(Codex 가 이 둘엔 창을 띄우지 않습니다), 무엇을 입력할지 굵게 적습니다. 그 전 **0.1.12** (2026-10-06) — Windows (Codex): 훅을 Git Bash 로 돌려 Windows 의 Codex 에서도 동작하고, Windows 에서는 Git for Windows 가 필요하며, 질문 창은 셋업 때 한 번 켭니다. 그 전 **0.1.11** (2026-10-06) — 버그 수정 (Codex): `alfred-init` 질문 창이 바로 뜨고, Codex 를 다시 열 때도 질문 창 옵션을 붙입니다. 그 전 **0.1.10** — 버그 수정 (Windows): Alfred 워크스페이스 밖에서 훅이 5초씩 멈추지 않습니다. 그 전 **0.1.9** — 버그 수정: `alfred-init` 이 다시 질문 창으로 확인하고, 만들 것의 요약을 질문 안에 넣습니다. 그 전 **0.1.8** — 버그 수정 (Codex): Codex 자체 `/init` 이 Alfred 워크스페이스를 건드리지 않습니다. 그 전 **0.1.7** — 버그 수정: `alfred-init` 이 파일 목록을 질문 창 밑이 아니라 채팅으로 보여 줍니다. 그 전 **0.1.6** — 레포를 `alfred-claude/` 와 `alfred-codex/` 로 나누고 Codex 전용 플러그인을 더했습니다. 그 전 **0.1.5** — 규약을 읽히는 문장으로 다시 쓰고, 부팅 때 어제 To do 를 묻고, 무엇이 판단인지는 사용자가 정하게 했으며, 개인 정보를 뺐습니다.

- 상태: **v0.1.9** — macOS 의 Claude Code · Codex 에서 시험했습니다. Linux · Windows 는 아직입니다
