---
name: alfred-init
description: Set up an Alfred workspace in the current folder — AGENTS.md (personal settings), project-logs/, daily/ templates, .alfred/workspace marker. Use only when the user types /alfred-init or explicitly says "install/initialize Alfred".
---

# alfred-init

Turns the current working folder into an Alfred workspace. Every file created **belongs to the user**.
The common rules are not copied into the workspace: the plugin's session-start hook adds them to every Codex session.
The workspace `AGENTS.md` holds only the user's settings.

**Question window:** wherever this skill says "question window", use `request_user_input` if it is available.
Codex needs it enabled once with the setup command `codex features enable default_mode_request_user_input`
(it stays on — written to `~/.codex/config.toml`). If it isn't available, tell the user once to run that command and reopen Codex,
and meanwhile ask in chat, one question at a time, with the options listed.

**One rule for every question-window step:** the `request_user_input` call is the very next action.
- Write no chat text before it — no summary, no options, no "please answer in the window". The call itself carries the question and the options
- Don't run other tools between deciding to ask and the call
- Wait for the answer before writing anything else; what comes after the question is written after the answer

**Chat gates — the questions Codex won't put in a window.** Codex's own instructions forbid `request_user_input` for permission
requests and for answers needed before work can go on, and tell it to ask those in chat instead. So three steps are asked in chat,
never in a window: existing `AGENTS.md` (step 1), the create confirmation (step 3) and git (step 5). For each chat gate:
- Write the question as one **bold** line, then one **bold** line saying exactly what to type — not "choose" or "select", since there is
  no window to choose in. ko: **"아래 입력창에 `생성` · `설정 다시 하기` · `중단` 중 하나를 입력해 주세요."**
  en: **"Type `create`, `redo settings` or `stop` in the chat box below."**
- End the turn right there. Nothing after the bold lines
- If the next message isn't one of the answers (or a plain equivalent such as "yes" for create): don't act on it and don't answer it.
  Say in bold that **setup isn't finished yet** — what is still missing (step 3: nothing has been created yet / step 5: git is not decided yet) —
  that their question can be asked again after setup, and repeat the bold "type …" line. Do this every time until an answer comes
- "stop" / "cancel" always ends the setup at that point

Templates are in this skill directory's `templates/` (next to this SKILL.md), one set per language:
`templates/en/` and `templates/ko/`. `templates/gitignore` is shared.

## Steps

### 1. Check the current folder (read only)
- Look at where you are and what's there with `pwd`, `ls -la`
- If `.alfred/workspace` already exists, say it's **already an initialized workspace** and stop
- If `AGENTS.md` already exists, don't overwrite it. Ask as a **chat gate** (see above):
  append an Alfred settings section to the end of the existing file (`append`) / `stop`
- If you're directly in the home directory (`~`), confirm once more (usually a dedicated folder is used)

### 2. Ask for settings
**Ask via the question window** (see above — the one rule applies to every window below).
Put the default in the options and let the user answer freely too.

**Window 1 — language, alone.** Everything after this is asked in the chosen language.
- Language: `English` (default) / `한국어`

**Window 2** (up to 3 questions per window in Codex)
1. User name (used to mark who decided in logs). If `git config user.name` is set, offer it as an option
2. How the assistant addresses the user (en e.g. "sir", the user's name / ko e.g. "OO님", "주인님")
3. Assistant name — options: en `Alfred` (default) / `Alf` · ko `Alfred` (default) / `알프레드`. Every question needs at least two options

**Window 3**
4. Category folders — names and output placement (strict/relaxed)
   (default: `Work` strict · `Research` strict · `Life` relaxed). `Incubator` is always added on top of these (strict) — don't ask about it;
   say so in the question text
5. Whether to turn on the author header, and if so, the name to put in it (off)

### 3. Show what will be created and confirm
**Confirm as a chat gate** before creating (see above — Codex won't open a window for this): first a short summary of the settings and
of what will be created — the file count and the top-level items, two or three lines (e.g. "19 files: AGENTS.md, .alfred/,
project-logs · project-workspace for Work/Research/Life + Incubator, daily/, Archive/") — then the bold question and the bold "type `create`,
`redo settings` or `stop`" line (in the chosen language). Don't print the full list unless the user asks for it; if they do, show it and
repeat the gate.
`<lang>` is `en` or `ko` per step 2.
```
AGENTS.md                              ← templates/<lang>/AGENTS.md with settings filled in
.alfred/workspace                      ← marker (version, created date, language)
.gitignore                             ← templates/gitignore
project-logs/<category>/.gitkeep       ← one per category
project-workspace/<category>/.gitkeep
project-logs/Incubator/log.md             ← templates/<lang>/Incubator/log.md ({{TODAY}} filled in)
project-logs/Incubator/open.md            ← templates/<lang>/Incubator/open.md
project-logs/Incubator/trace/.gitkeep
project-workspace/Incubator/.gitkeep
daily/_template.md                     ← templates/<lang>/daily/
daily/_timeline-example.md             ← templates/<lang>/daily/
daily/YYYY/YYYY-MM/YYYY-MM-DD.md       ← today's, from _template with only the date replaced
Archive/README.md                      ← templates/<lang>/Archive/README.md
Archive/log-archive/.gitkeep
Archive/workspace-archive/.gitkeep
```

### 4. Create
- Dates are values checked with `date '+%Y-%m-%d'`
- Fill every `{{...}}` in `AGENTS.md` with the settings. Check that no `{{` remains
  - `{{AUTHOR_HEADER}}`: en `on` / `off`, ko `켬` / `끔`
  - `{{CATEGORY_ROWS}}`: one table row per category — `| <folder> | <what> | strict/relaxed |` (ko: `엄격` / `완화`)
- `.alfred/workspace` contents:
  ```
  alfred-workspace
  version: 0.3.5
  created: YYYY-MM-DD
  language: en
  ```
  (`language: ko` for Korean. The session-start hook reads this line)
- Copy templates as-is; don't add author headers (they're the user's files). In `Incubator/log.md`, replace `{{TODAY}}` with today's date

### 5. Wrap up
First ask about git, then write the closing message.
- **Ask whether to use git as a chat gate** (see above): one line that the files were created, then the bold question and the bold
  "type `use git` or `not now`" line (ko: `git 사용` · `지금은 안 함`). Run `git init` only if the user answers `use git`
- After the answer, in one closing message. Write the closing message in this order, and put the restart **last**, in bold, on its own line — the user acts on the last thing they read. Nothing else in Alfred works until the restart, guide mode included.
  - Tell them the first project can start with "create a <name> project in <category>"
  - Then introduce Incubator, in the chosen language and with the chosen form of address. Say it in your own words, close to this
    (ko): "아직 무엇을 구상 중이시라면 편하게 말씀해 주세요. Incubator 에서 그 내용을 추적하고 키웠다가, 실제 프로젝트로 띄울 때
    원하시는 디렉토리로 옮기시면 됩니다. Incubator 에는 간단한 궁금증도 기록해 아이디어가 날아가지 않게 해 드립니다.
    떠오른 아이디어 중 지금 당장 하지 않으실 것은 말씀만 해 주시면 Incubator open 에 적어 두겠습니다. open 을 적극적으로 써 보세요!"
    (en): "If you're still shaping an idea, just tell me. Incubator tracks it and lets it grow; when it becomes a real project, you move it
    to the folder you want. Even small questions go into Incubator so no idea slips away. Ideas you won't act on right now — just say so
    and I'll put them in Incubator's open.md. Make good use of open!"
  - Then one line for first-timers: **after the restart**, `$guide-mode on` gives a short tour of Alfred and a usage tip now and then (`$guide-mode off` stops it)
  - Last, in bold: they **must restart Codex in this folder now** (quit, then plain `codex`) for the hook to recognize the workspace.
    On the first start Codex asks them to review and trust the plugin's hooks; until they do, the rules are not loaded

## Creating a new project (after init, when the user asks)
Create `project-logs/<category>/<project>/log.md` with the frontmatter from section 7 of the common rules and the top section
(goal · premises · why this approach now). Get objective · code · status from the user. Never make them up.
Next to it, create `decision.md` with only a `## Starting point` section (`## 출발점` in Korean) — the first objective with its date,
and the situation then and why it started, in the user's words. Ask for it in chat; don't fill it in yourself (section 14 of the common rules).
