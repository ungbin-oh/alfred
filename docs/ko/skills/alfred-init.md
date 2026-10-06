# alfred-init

written by Ungbin_Oh · created 2026-09-26 · updated 2026-10-06

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

**창 2** (창 하나에 질문 4개까지)
1. 사용자 이름 (로그의 판단 주체 표기에 쓴다). `git config user.name` 이 있으면 그 값을 선택지로 둔다
2. 비서가 부를 호칭 (영어 예: "sir", 사용자 이름 / 한국어 예: "OO님", "주인님")
3. 비서 이름 — 선택지: en `Alfred`(기본) / `Alf` · ko `Alfred`(기본) / `알프레드`. 질문마다 선택지는 둘 이상 (하나뿐이면 창이 거절한다)
4. 카테고리 폴더 — 이름과 산출물 배치 방식(엄격/완화)
   (기본: `Work` 엄격 · `Research` 엄격 · `Life` 완화). `Incubator` 는 이와 별도로 늘 더한다(엄격) — 묻지 않고, 질문 문장에 그렇다고 적는다

**창 3**
5. 저작 헤더를 켤지, 켠다면 헤더에 쓸 이름 (끔)

### 3. 만들 것 보여 주고 확인받기
**질문 창으로 확인받고** 만든다 (만들기 / 설정 다시 / 중단). 만들 것의 요약을 **질문 문장 안에** 두세 줄로 넣는다 — 파일 수와 맨 위 항목 (예: "파일 20개: CLAUDE.md, .alfred/, Work · Research · Life + Incubator 의 project-logs · project-workspace, daily/, Archive/"). 창 앞에 전체 목록을 채팅으로 찍지 않고(창이 가린다), 선택지 미리보기에도 넣지 않는다(15줄 안팎만 보인다). 사용자가 전체 목록을 보자고 하면 채팅으로 보여 주고 다시 묻는다.
`<lang>` 은 2단계에서 고른 `en` 또는 `ko`.
```
CLAUDE.md                              ← templates/<lang>/CLAUDE.md 에 설정값을 채움
.alfred/workspace                      ← 마커 (버전·생성일·언어)
.alfred/rules.md                       ← 공통 규약 복사본, ../../hooks/sync-rules.sh 가 씀
.gitignore                             ← templates/gitignore
project-logs/<카테고리>/.gitkeep        ← 카테고리마다
project-workspace/<카테고리>/.gitkeep
project-logs/Incubator/log.md             ← templates/<lang>/Incubator/log.md ({{TODAY}} 채움)
project-logs/Incubator/open.md            ← templates/<lang>/Incubator/open.md
project-logs/Incubator/trace/.gitkeep
project-workspace/Incubator/.gitkeep
daily/_template.md                     ← templates/<lang>/daily/
daily/_timeline-example.md             ← templates/<lang>/daily/
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
  version: 0.3.1
  created: YYYY-MM-DD
  language: en
  ```
  (한국어면 `language: ko`. 세션 시작 훅이 이 줄을 읽는다)
- 템플릿은 복사만 하고 저작 헤더를 넣지 않는다 (사용자 파일이다). `Incubator/log.md` 의 `{{TODAY}}` 는 오늘 날짜로 바꾼다
- 공통 규약 복사: `bash "<이 스킬 폴더>/../../hooks/sync-rules.sh" "<워크스페이스 루트>"`. `created` 가 찍힌다.
  `CLAUDE.md` 에 `@.alfred/rules.md` 가 한 줄로 들어 있는지 확인한다. `.alfred/rules.md` 는 고치지 않는다 — 플러그인이 덮어쓴다

### 5. 상태줄 배지 (선택)
Alfred 워크스페이스에서 상태줄에 하늘색 `[ALFRED]` 배지를 띄운다. **전역 설정(`~/.claude/settings.json`)을 고치는 일이라
질문 창으로 먼저 묻는다.** 기존 `statusLine` 이 있는지 읽어 보고 선택지를 고른다:
- 기존 `statusLine` 이 없으면: 켜기 / 건너뛰기
- 있으면: 같이 띄우기(기존 것 옆에 붙임) / Alfred 로 바꾸기 / 건너뛰기

켜는 경우:
1. 이 스킬 기준 `../../hooks/statusline.sh` 를 `~/.claude/alfred-statusline.sh` 로 복사하고 실행 권한을 준다
   (플러그인 캐시 경로는 업데이트마다 바뀌어 settings.json 에 직접 적을 수 없다)
2. "같이 띄우기" 면 기존 `statusLine.command` 문자열을 `~/.claude/.alfred-statusline-chain` 에 저장한다
3. `settings.json` 의 `statusLine` 을 `{"type": "command", "command": "bash ~/.claude/alfred-statusline.sh"}` 로 바꾼다.
   **다른 키는 건드리지 않는다.** 고치기 전 내용을 보여 주고, 고친 뒤 diff 를 보여 준다
- 색은 환경변수 `ALFRED_COLOR` 로 바꿀 수 있다 (256색 코드. 기본 117 하늘색, 114 초록)
- 되돌리기: `~/.claude/.alfred-statusline-chain` 에 저장된 명령을 `statusLine.command` 로 되돌리거나 `statusLine` 을 지운다

### 6. 마무리 안내
- **Claude Code 를 이 폴더에서 다시 시작해야** 훅이 워크스페이스를 알아본다고 알린다
- 첫 프로젝트는 "<카테고리> 에 <이름> 프로젝트 만들어줘" 로 시작하면 된다고 알린다
- 이어서 Incubator 를 소개한다 (고른 언어 · 호칭으로, 자기 말로 하되 이 뜻에 가깝게): "아직 무엇을 구상 중이시라면 편하게 말씀해 주세요.
  Incubator 에서 그 내용을 추적하고 키웠다가, 실제 프로젝트로 띄울 때 원하시는 디렉토리로 옮기시면 됩니다. Incubator 에는 간단한 궁금증도 기록해
  아이디어가 날아가지 않게 해 드립니다. 떠오른 아이디어 중 지금 당장 하지 않으실 것은 말씀만 해 주시면 Incubator open 에 적어 두겠습니다.
  open 을 적극적으로 써 보세요!"
- 이어서 처음 쓰는 사람에게 한 줄: `/guide-mode on` 을 치면 Alfred 를 짧게 소개하고 쓰는 동안 가끔 사용법 팁을 준다 (`/guide-mode off` 로 끔)
- git 을 쓸지는 질문 창으로 묻기만 한다 (쓴다 / 나중에). `git init` 은 사용자가 하겠다고 할 때만 실행한다

## 새 프로젝트를 만들 때 (init 이후, 사용자가 요청하면)
`project-logs/<카테고리>/<프로젝트>/log.md` 를 공통 규약 7절의 frontmatter 와 상단 구성(목표 · 전제 · 왜 지금 이 방식인가)으로 만든다.
objective · code · status 는 사용자에게 받는다. 지어내지 않는다.
옆에 `decision.md` 를 `## 출발점` 절만 두고 만든다 (영어는 `## Starting point`) — 최초 objective 와 날짜,
그때 상황 · 왜 시작했나를 사용자 말로. 채팅으로 묻고 비서가 채우지 않는다 (공통 규약 14절).
