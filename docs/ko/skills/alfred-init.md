# alfred-init

written by Ungbin_Oh · created 2026-09-26 · updated 2026-10-25

> **한국어 번역본이다.** 정본은 `alfred-claude/skills/alfred-init/SKILL.md` (영어) 이고 Claude Code 는 이 파일을 읽지 않는다.
> 정본이 바뀌면 이 파일도 같은 커밋에서 맞춘다.

스킬 설명: Alfred 워크스페이스를 현재 폴더에 만든다 — CLAUDE.md(개인 설정), project-logs/, daily/ 템플릿, .alfred/workspace 마커. 사용자가 /alfred-init 을 입력하거나 "Alfred 설치/초기화해줘" 라고 명시할 때만 쓴다.

현재 작업 폴더를 Alfred 워크스페이스로 만든다. 만들어지는 파일은 전부 **사용자 소유**다.
공통 규약은 `../../hooks/sync-rules.sh` (이 스킬 기준)가 `.alfred/rules.md` 로 복사하고, 워크스페이스
`CLAUDE.md` 가 `@.alfred/rules.md` 한 줄로 불러온다. 그 복사본은 플러그인의 세션 시작 훅이 최신으로 맞춘다.

템플릿은 이 스킬 디렉토리의 `templates/` 에 있다 (이 SKILL.md 와 같은 위치). 언어별로 한 벌씩:
`templates/en/` 과 `templates/ko/`. `templates/gitignore` 는 공용이다.

## 순서

### 1. 현재 폴더 확인 (읽기만)
- `pwd`, `ls -la` 로 현재 위치와 내용을 본다
- 이미 `.alfred/workspace` 가 있으면 **이미 초기화된 워크스페이스**라고 알리고 멈춘다
- `CLAUDE.md` 가 이미 있으면 덮어쓰지 않는다. 객관식 질문 창(AskUserQuestion)으로 묻는다:
  기존 파일 끝에 Alfred 설정 절을 붙일지 / 중단할지.
  붙이는 절에는 `@.alfred/rules.md` 한 줄을 따로 넣는다 (백틱으로 감싸지 않는다)
- 홈 디렉토리(`~`) 바로 위라면 한 번 더 확인한다 (보통은 전용 폴더를 쓴다)

### 2. 설정 묻기
**객관식 질문 창(AskUserQuestion)으로 묻는다.** 텍스트로 묻지 않는다.
선택지에는 기본값을 두고, 자유 입력은 창이 붙여 주는 "직접 입력(Other)" 으로 받는다.

**창 1 — 언어 하나만.** 이후는 전부 고른 언어로 묻는다.
- 언어: `English` (기본) / `한국어`

**창 2 — 질문 둘, 더 묻지 않는다**
1. 사용자 이름 (로그의 판단 주체 표기에 쓴다). `git config user.name` 이 있으면 그 값을 선택지로 둔다
2. 비서가 부를 호칭 (영어 예: "sir", 사용자 이름 / 한국어 예: "OO님", "주인님")

**나머지는 기본값 — 묻지 않는다:**
- 비서 이름: `Alfred`
- 카테고리 폴더: `Work` 엄격 · `Research` 엄격 · `Life` 완화, 그리고 `Incubator` (엄격)
- 저작 헤더: 끔
- 상태줄 배지: 켬, 이 워크스페이스에서만 (5단계 — 전역 `~/.claude/settings.json` 은 건드리지 않는다)
- git: 안 함 (`git init` 은 나중에 사용자가 원할 때만, 6단계)

마무리 안내에서 이 기본값을 한 줄로 알리고, 말만 하면 바꿀 수 있다고 한다 (6단계).

### 3. 만들 것
확인 창 없이 2단계 뒤 바로 만든다. 사용자가 전체 목록을 보자고 하면 채팅으로 보여 준다.
`<lang>` 은 2단계에서 고른 `en` 또는 `ko`.
```
CLAUDE.md                              ← templates/<lang>/CLAUDE.md 에 설정값을 채움
.alfred/workspace                      ← 마커 (버전·생성일·언어)
.alfred/rules.md                       ← 공통 규약 복사본, ../../hooks/sync-rules.sh 가 씀
.alfred/statusline.sh                  ← 배지 스크립트, ../../hooks/statusline.sh 복사본 (5단계)
.alfred/statusline-chain               ← 전역 statusLine 이 있을 때만 (5단계)
.claude/settings.local.json            ← 이 워크스페이스만의 statusLine (5단계)
.gitignore                             ← templates/gitignore
project-logs/<카테고리>/.gitkeep        ← 카테고리마다
project-workspace/<카테고리>/.gitkeep
project-logs/Incubator/log.md             ← templates/<lang>/Incubator/log.md ({{TODAY}} 채움)
project-logs/Incubator/open.md            ← templates/<lang>/Incubator/open.md
project-logs/Incubator/trace/.gitkeep
project-workspace/Incubator/.gitkeep
daily/_template.md                     ← templates/<lang>/daily/
daily/_timeline-example.md             ← templates/<lang>/daily/
weekly/_template.md                    ← templates/<lang>/weekly/
daily/YYYY/YYYY-MM/YYYY-MM-DD.md       ← 오늘자, _template 에서 date 만 치환
Archive/README.md                      ← templates/<lang>/Archive/README.md
Archive/log-archive/.gitkeep
Archive/workspace-archive/.gitkeep
```

### 4. 만들기
- 날짜는 `date '+%Y-%m-%d'` 로 확인한 값
- `CLAUDE.md` 의 `{{...}}` 자리를 설정값으로 모두 채운다. 남은 `{{` 가 없는지 확인한다
  - `{{AUTHOR_HEADER}}`: 영어 `on` / `off`, 한국어 `켬` / `끔`
  - `{{CATEGORY_ROWS}}`: 카테고리마다 표 한 줄 — `| <폴더> | <무엇> | 엄격/완화 |` (영어: `strict` / `relaxed`)
- `.alfred/workspace` 내용:
  ```
  alfred-workspace
  version: 0.4.10
  created: YYYY-MM-DD
  language: en
  ```
  (한국어면 `language: ko`. 세션 시작 훅이 이 줄을 읽는다)
- 템플릿은 복사만 하고 저작 헤더를 넣지 않는다 (사용자 파일이다). `Incubator/log.md` 의 `{{TODAY}}` 는 오늘 날짜로 바꾼다
- 공통 규약 복사: `bash "<이 스킬 폴더>/../../hooks/sync-rules.sh" "<워크스페이스 루트>"`. `created` 가 찍힌다.
  `CLAUDE.md` 에 `@.alfred/rules.md` 가 한 줄로 들어 있는지 확인한다. `.alfred/rules.md` 는 고치지 않는다 — 플러그인이 덮어쓴다

### 5. 상태줄 배지 (기본 — 이 워크스페이스에서만)
상태줄에 하늘색 `[ALFRED]` 배지를 띄운다. **워크스페이스 자체의 `.claude/settings.local.json`** 에 두므로 이 워크스페이스에서만 뜨고,
**전역 `~/.claude/settings.json` 은 건드리지 않는다.** 기본값이라 묻지 않는다.
1. 이 스킬 기준 `../../hooks/statusline.sh` 를 `<워크스페이스 루트>/.alfred/statusline.sh` 로 복사한다
   (업데이트 뒤에는 세션 시작 훅이 `.alfred/rules.md` 처럼 최신으로 맞춘다)
2. 워크스페이스의 `statusLine` 은 이 워크스페이스 안에서 전역 것을 대신한다. 그래서 전역 `~/.claude/settings.json` (읽기만)에
   `statusLine.command` 가 있으면 그 문자열을 그대로 `<워크스페이스 루트>/.alfred/statusline-chain` 에 저장한다 — 배지 스크립트가
   그것을 먼저 돌려 둘을 나란히 띄운다. 없거나 이미 Alfred 배지 스크립트를 가리키면 건너뛴다
3. `<워크스페이스 루트>/.claude/settings.local.json` 에
   `"statusLine": {"type": "command", "command": "bash \"<워크스페이스 루트>/.alfred/statusline.sh\""}` 를 절대 경로로 넣는다.
   파일이 있으면 이 키만 더하고, 이미 `statusLine` 이 있으면 그대로 두고 마무리 안내에서 알린다.
   `.claude/` 는 `.gitignore` 템플릿에 들어 있어 커밋되지 않는다
- 색은 환경변수 `ALFRED_COLOR` 로 바꿀 수 있다 (256색 코드. 기본 117 하늘색, 114 초록)
- 끄기: `.claude/settings.local.json` 에서 `statusLine` 을 지운다
- 0.4.5 전에 만든 워크스페이스는 예전 전역 방식(`~/.claude/alfred-statusline.sh` + `.alfred-statusline-chain`)일 수 있다.
  사용자가 말하지 않으면 그대로 둔다. 배지 스크립트는 그 방식도 읽는다

### 6. 마무리 안내
아래 순서로 쓰고, 다시 시작 안내는 **맨 끝에 굵게 한 줄로** 둔다 — 사용자는 마지막에 읽은 것을 한다. 다시 시작하기 전에는 가이드 모드를 포함해 아무것도 제대로 돌지 않는다.
- 첫 프로젝트는 "<카테고리> 에 <이름> 프로젝트 만들어줘" 로 시작하면 된다고 알린다
- 이어서 Incubator 를 소개한다 (고른 언어 · 호칭으로, 자기 말로 하되 이 뜻에 가깝게): "아직 무엇을 구상 중이시라면 편하게 말씀해 주세요.
  Incubator 에서 그 내용을 추적하고 키웠다가, 실제 프로젝트로 띄울 때 원하시는 디렉토리로 옮기시면 됩니다. Incubator 에는 간단한 궁금증도 기록해
  아이디어가 날아가지 않게 해 드립니다. 떠오른 아이디어 중 지금 당장 하지 않으실 것은 말씀만 해 주시면 Incubator open 에 적어 두겠습니다.
  open 을 적극적으로 써 보세요!"
- 이어서 2단계의 기본값을 한 줄로 알리고, 말만 하면 바꿀 수 있다고 한다 — 예: "나머지는 기본값으로 했습니다: 비서 이름 Alfred,
  폴더 Work · Research · Life (+ Incubator), 저작 헤더 끔, 상태줄 배지 켬 (이 폴더만), git 안 함. 바꾸고 싶은 게 있으면 말씀만 해 주세요."
- 이어서 처음 쓰는 사람에게 한 줄: **다시 시작한 뒤** `/guide-mode on` 을 치면 Alfred 를 짧게 소개하고 쓰는 동안 가끔 사용법 팁을 준다 (`/guide-mode off` 로 끔)
- 맨 끝에 굵게: **지금 이 폴더에서 Claude Code 를 다시 시작해야** (나갔다가 `claude`) 훅이 워크스페이스를 알아본다
- git 은 묻지 않는다. `git init` 은 나중에 사용자가 원할 때만 실행한다

## 새 프로젝트를 만들 때 (init 이후, 사용자가 요청하면)
`project-logs/<카테고리>/<프로젝트>/log.md` 를 공통 규약 7절의 frontmatter 와 상단 구성(목표 · 전제 · 왜 지금 이 방식인가)으로 만든다.
objective · code · status 는 사용자에게 받는다. 지어내지 않는다.
옆에 `decision.md` 를 `## 출발점` 절만 두고 만든다 (영어는 `## Starting point`) — 최초 objective 와 날짜,
그때 상황 · 왜 시작했나를 사용자 말로. 채팅으로 묻고 비서가 채우지 않는다 (공통 규약 14절).
