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
  <a href="#새-버전을-받으시려면">새 버전 받기</a> •
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

OS 를 고르시고 번호를 따라가십시오. 단계마다 다음에 어디로 갈지 적어 두었습니다 — 이미 있는 것은 건너뛰십시오.

|  | 🍎 [macOS](#-macos) | 🪟 [Windows](#-windows) |
|---|---|---|
| 터미널 | 터미널 (zsh) | PowerShell |
| Claude Code 를 쓰시면 | MAC-Step1 → MAC-Step2 → MAC-Step3 | Windows-Step1 → Windows-Step2 → Windows-Step3 → Windows-Step4 |
| Codex 를 쓰시면 | MAC-Step1 → MAC-Step4 → MAC-Step5 → MAC-Step6 | Windows-Step1 → Windows-Step2 → Windows-Step5 → Windows-Step6 → Windows-Step7 |

---

### 🍎 macOS

**MAC-Step1 · 어떤 도구를 쓰시나요?**
- Claude Code → **MAC-Step2**
- Codex → **MAC-Step4**
- 둘 다 → MAC-Step2 → MAC-Step3 을 마친 뒤 MAC-Step4 → MAC-Step6

**MAC-Step2 · Claude Code 설치** — `claude --version` 이 이미 되면 → **MAC-Step3** 으로

```bash
curl -fsSL https://claude.ai/install.sh | bash
```

➡️ 터미널을 새로 여시고 `claude` 를 한 번 실행해 로그인하신 뒤 → **MAC-Step3**

**MAC-Step3 · Claude Code 용 Alfred**

```bash
claude plugin marketplace add ungbin-oh/alfred
claude plugin install alfred@alfred
mkdir ~/ALFRED
cd ~/ALFRED
claude
```

➡️ 세션에서 `/alfred-init` 을 입력하십시오. 끝나면 나갔다가 `claude` 를 다시 실행하십시오. ✅ 끝 (Codex 도 쓰시면 → **MAC-Step4**)

**MAC-Step4 · Node.js 설치** (Codex 에 필요) — `node --version` 이 이미 되면 → **MAC-Step5** 로

```bash
brew install node
```

➡️ Homebrew 가 없으시면 [nodejs.org](https://nodejs.org) 에서 받으십시오. 그다음 → **MAC-Step5**

**MAC-Step5 · Codex 설치** — `codex --version` 이 이미 되면 → **MAC-Step6** 으로

```bash
npm install -g @openai/codex
```

➡️ `codex` 를 한 번 실행해 로그인하신 뒤 → **MAC-Step6**

**MAC-Step6 · Codex 용 Alfred**

```bash
codex plugin marketplace add ungbin-oh/alfred
codex plugin add alfred-codex@alfred
codex features enable default_mode_request_user_input
mkdir ~/ALFRED
cd ~/ALFRED
codex
```

➡️ 훅 신뢰를 물으면 신뢰하시고 `$alfred-init` 을 입력하십시오. 끝나면 나갔다가 `codex` 를 다시 실행하십시오. ✅ 끝
`features enable` 줄은 한 번만 치시면 됩니다 — 질문 창을 계속 켜 둡니다.

---

### 🪟 Windows

> [!IMPORTANT]
> 아래에서 무언가를 설치할 때마다 **PowerShell 을 완전히 닫고 새로 여십시오** — 새 탭으로는 부족합니다. 그 전에는 새 명령을 찾지 못합니다.

**Windows-Step1 · Git for Windows** (제 훅이 그 안의 Git Bash 로 돕니다) — `git --version` 이 이미 되면 → **Windows-Step2** 로

```powershell
winget install --id Git.Git -e
```

➡️ PowerShell 을 닫고 새로 여시고 `git --version` 확인 → **Windows-Step2**. (이미 깔려 있어도 다시 치시면 괜찮습니다. `winget` 이 없으면 [git-scm.com](https://git-scm.com/download/win) 에서 받으십시오.)

**Windows-Step2 · 어떤 도구를 쓰시나요?**
- Claude Code → **Windows-Step3**
- Codex → **Windows-Step5**
- 둘 다 → Windows-Step3 → Windows-Step4 를 마친 뒤 Windows-Step5 → Windows-Step7

**Windows-Step3 · Claude Code 설치** — `claude --version` 이 이미 되면 → **Windows-Step4** 로

```powershell
irm https://claude.ai/install.ps1 | iex
$bin = "$env:USERPROFILE\.local\bin"
$p = [Environment]::GetEnvironmentVariable('Path','User')
if (($p -split ';') -notcontains $bin) { [Environment]::SetEnvironmentVariable('Path', "$p;$bin", 'User') }
```

위 코드의 뒤 세 줄은 Claude Code 폴더(`.local\bin`)를 PATH 에 넣습니다 — 설치기가 늘 넣어 주지는 않습니다. 다시 실행해도 바뀌는 것이 없습니다.

➡️ PowerShell 을 닫고 새로 여시고 `claude --version` 확인, `claude` 를 한 번 실행해 로그인 → **Windows-Step4**

**Windows-Step4 · Claude Code 용 Alfred**

```powershell
claude plugin marketplace add ungbin-oh/alfred
claude plugin install alfred@alfred
mkdir ~\ALFRED
cd ~\ALFRED
claude
```

➡️ 세션에서 `/alfred-init` 을 입력하십시오. 끝나면 나갔다가 `claude` 를 다시 실행하십시오. ✅ 끝 (Codex 도 쓰시면 → **Windows-Step5**)

**Windows-Step5 · Node.js 설치** (Codex 에 필요) — `node --version` 이 이미 되면 → **Windows-Step6** 으로

```powershell
winget install --id OpenJS.NodeJS.LTS -e
```

➡️ PowerShell 을 닫고 새로 여시고 `node --version` 확인 → **Windows-Step6**

**Windows-Step6 · Codex 설치** — `codex --version` 이 이미 되면 → **Windows-Step7** 로

```powershell
npm install -g @openai/codex
```

➡️ PowerShell 을 닫고 새로 여시고 `codex --version` 확인, `codex` 를 한 번 실행해 로그인 → **Windows-Step7**

**Windows-Step7 · Codex 용 Alfred**

```powershell
codex plugin marketplace add ungbin-oh/alfred
codex plugin add alfred-codex@alfred
codex features enable default_mode_request_user_input
mkdir ~\ALFRED
cd ~\ALFRED
codex
```

➡️ 훅 신뢰를 물으면 신뢰하시고 `$alfred-init` 을 입력하십시오. 끝나면 나갔다가 `codex` 를 다시 실행하십시오. ✅ 끝
`features enable` 줄은 한 번만 치시면 됩니다 — 질문 창을 계속 켜 둡니다.

**막히면 (Windows)**
- "이 시스템에서 스크립트를 실행할 수 없으므로" (npm · codex): `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned` 후 다시 실행
- 다시 열어도 `git` 을 찾을 수 없다면: Git 은 깔렸는데 PATH 에 없는 것입니다 — Git 의 `cmd` 폴더(예: `C:\Program Files\Git\cmd`)를 같은 방법으로 사용자 PATH 에 넣고 다시 열기

## 새 버전을 받으시려면

**Claude Code**

```
claude plugin marketplace update alfred
claude plugin update alfred@alfred
```

**Codex**

```
codex plugin marketplace upgrade alfred
codex plugin add alfred-codex@alfred
```

워크스페이스의 로그와 설정은 그대로입니다. 업데이트가 주인님 파일을 바꿔야 할 때(새 폴더, 템플릿)는 다음 세션 시작에 말씀드리고, 손대기 전에 여쭙습니다 — 업데이트 내역의 `[Workspace]` 표시입니다.

## 제가 드리는 것

| 무엇 | 하는 일 |
|---|---|
| **부팅 브리핑** | 세션을 여시면 카테고리별 프로젝트 표 — 상태 · 마지막 갱신 · 방치 일수 · 다음 할 일. 14일 넘게 손대지 않은 active 프로젝트는 🔴 neglected 로 표시만 합니다 |
| **결정 로그** `log.md` | 결과보다 **"그때 왜 그렇게 판단했는가"**. 판단 주체(주인님 / 저)를 항목마다 적습니다 |
| **작업 원장** `trace/` | 명령 · 에러 원문 · 가설과 배제 근거를 작업 도중 제가 바로 적습니다. 저장하실 때 이것을 추려 log 로 올립니다 |
| **판단 문서** `decision.md` | 프로젝트의 방향을 정한 판단만 — 이전 상황 · 계기 · 주인님 말씀 그대로의 생각 · 정하신 방향 · 목적과의 비교. 제가 여쭈어 받아 적습니다. 처음 목적에서 벗어나지 않았는지 스스로 보실 수 있게 |
| **열어둔 것** `open.md` | 지금 궁금하거나 하고 싶지만 아직 시작하지 않으실 것 — 잊히지 않게 담아 둡니다. 시작하시거나 접으시면 log 에 기록하고 파일 위쪽 '닫힌 것' 표로 옮깁니다 |
| **인큐베이터** `project-logs/Incubator/` | 지금 어느 프로젝트에도 속하지 않는 질문 · 공부 · 잡생각을 두는 곳. 실제로 하게 되면 그 아래 하위 프로젝트로 띄우고, 자라면 카테고리로 옮깁니다 |
| **보관함** `Archive/` | 끝났지만 버리지 않을 산출물과 기록을 브리핑 밖으로. 말씀하실 때만 옮깁니다 |
| **일기** `daily/` | 날짜별 서사와 잡생각. "하루를 정리하자" 하시면 trace 로 타임라인을 씁니다 |
| **질문 창** | 짧게 고르실 것은 텍스트 대신 객관식 질문 창으로 여쭙니다. 답이 질문마다 하나씩 남습니다. 긴 초안은 채팅으로 확인받습니다 |
| **두 언어** | `/alfred-init` 에서 English 또는 한국어를 고르십니다. 규약은 어느 쪽이든 한 벌입니다 |
| `/alfred-init` | 워크스페이스를 차립니다. 만들어지는 파일은 전부 주인님 것입니다 |
| `/manual-mode lite\|medium\|full` | 제 손을 묶는 수동 모드 — 명령 · 코드를 주인님께서 직접 치십니다 |
| `/guide-mode on\|off` | 처음 쓰실 때: 제가 일하는 방식을 짧게 소개하고, 그 뒤로 가끔 사용법 팁을 하나씩 드립니다 (Codex 는 `$guide-mode`) |
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
├── .alfred/rules.md       공통 규약 복사본, 플러그인이 관리합니다 — 고치지 마십시오 (고치시면 덮지 않고 여쭙니다)
├── project-logs/          프로젝트별 log.md · decision.md · open.md · trace/
│   └── Incubator/            질문과 덜 익은 생각, 띄우기 전의 하위 프로젝트
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

## 물러나게 하시려면

```
claude plugin uninstall alfred@alfred      # Claude Code
codex plugin remove alfred-codex@alfred    # Codex
```

로그와 일기는 그대로 남습니다 — 모두 주인님의 것입니다. 상태줄 배지를 켜셨다면 `~/.claude/settings.json` 의 `statusLine` 을 지워 주십시오.

## 한국어 규약

제가 따르는 규약의 정본은 영어 한 벌(`alfred-claude/rules/core.md`, `alfred-codex/` 에도 같은 사본)입니다. 주인님께서 읽으실 한국어 번역본은 [`docs/ko/`](docs/ko/) 에 두었습니다.

## 필요한 것

- Claude Code (플러그인 지원 버전), 또는 플러그인을 지원하는 Codex CLI (0.160 에서 확인)
- macOS, Linux 또는 Windows. Windows 에서는 Git for Windows (Git Bash) — 훅이 bash 스크립트입니다

## License

[MIT](LICENSE) © 2026 Ungbin Oh

## 업데이트 히스토리

두 플러그인은 버전 번호 하나를 같이 씁니다. 바뀐 것은 모두 [docs/ko/CHANGELOG.md](docs/ko/CHANGELOG.md) 에 [Claude] · [Codex] · [공통] 을 붙여 적었습니다 (정본은 영어 [CHANGELOG.md](CHANGELOG.md)).

| 버전 | 날짜 | 바뀐 것 |
|---|---|---|
| **0.4.3** | 2026-10-10 | Claude Code: 같은 날 연 세션에 `YYYY-MM-DD #1`, `#2` … 로 번호가 붙습니다 (`.alfred/session-count` 로 셉니다) |
| 0.4.2 | 2026-10-10 | 워크스페이스 변경은 제안만: 업데이트 내역에 `[Workspace]` 가 붙은 항목은 업데이트 뒤 하나씩 여쭙습니다 (적용 / 건너뜀). `~/.claude` 의 상태줄 배지 복사본이 오래되면 새 복사본을 제안합니다 |
| 0.4.1 | 2026-10-10 | `.alfred/rules.md` 를 고치셔도 더 이상 덮어쓰지 않습니다: 플러그인이 마지막에 쓴 내용의 해시(`.alfred/rules.sha`)를 두고, 달라진 파일을 알아채면 여쭙니다 — 고친 것을 `CLAUDE.md` 로 옮기거나, 파일을 주인님 것으로 두거나(`.alfred/rules.local`) |
| 0.4.0 | 2026-10-10 | 세션 시작 버전 알림: 새 판의 첫 세션에 "Alfred 가 X → Y 로 바뀌었습니다" 한 번 (마커의 `version:` 줄을 최신으로 맞춤), GitHub 에 더 새 판이 있으면 "업데이트가 있습니다" 와 업데이트 명령 |
| 0.3.5 | 2026-10-06 | 가이드 모드: 소개를 Incubator 추천 줄로 끝냅니다 — 뒤에 질문 창 없음 |
| 0.3.4 | 2026-10-06 | 버그 수정 (Claude): 가이드 모드가 소개 열 줄을 실제로 보여 줍니다. 도구 호출 사이 글이 안 보인다고 가정하던 규칙을 뺐습니다 |
| 0.3.3 | 2026-10-06 | 버그 수정: 긴 글 바로 뒤에도 질문 창을 띄웁니다 (막는 규칙 때문에 Claude 가이드 소개가 한 줄로 줄었음). 짧게 둘 것은 미리보기 칸뿐. `open.md` 를 "아직 시작하지 않을 것을 담는 곳" 으로 고쳐 설명 |
| 0.3.2 | 2026-10-06 | `alfred-init` 이 "지금 다시 시작" 을 맨 끝에 굵게 두고 가이드 모드는 다시 시작한 뒤라고 알립니다. 가이드 모드는 Incubator 에서 시작하기를 권합니다 |
| 0.3.1 | 2026-10-06 | 가이드 모드: `/guide-mode on` 이면 짧은 소개와 가끔 사용법 팁. `alfred-init` 끝에 알려 줍니다 |
| 0.3.0 | 2026-10-06 | 인큐베이터(Incubator): 질문 · 공부 · 잡생각을 두고, 하위 프로젝트가 카테고리로 가기 전에 자라는 곳. `alfred-init` 이 늘 만듭니다 |
| 0.2.3 | 2026-10-06 | 버그 수정: `alfred-init` 의 비서 이름 질문에 선택지가 늘 둘이라, 영어 설정에서도 빠지지 않습니다 |
| 0.2.2 | 2026-10-06 | Claude Code: Alfred 워크스페이스에서 새로 연 세션에 날짜 이름이 붙습니다 |
| 0.2.1 | 2026-10-06 | Codex: `alfred-init` 이 생성 확인과 git 을 채팅으로 묻고(Codex 가 이 둘엔 창을 띄우지 않습니다), 무엇을 입력할지 굵게 적습니다 |
| 0.2.0 | 2026-10-06 | Windows (Codex): 훅을 Git Bash 로 돌립니다. Windows 에서는 Git for Windows 가 필요하고, 질문 창은 셋업 때 한 번 켭니다 |
| 0.1.10 – 0.1.11 | 2026-10-06 | 버그 수정: Windows 에서 워크스페이스 밖 훅 멈춤, Codex 질문 창 |
| 0.1.5 – 0.1.9 | 2026-10-05 | 규약 문장 정리, Codex 플러그인 · 레포 분리, `alfred-init` 수정 |

**상태: v0.3.5** — macOS · Windows 11 의 Claude Code · Codex 에서 시험했습니다 (0.2.3 까지). 인큐베이터(0.3.0)과 가이드 모드(0.3.1)는 실제 세션에서 아직 써 보지 않았습니다. Linux 는 아직입니다.
