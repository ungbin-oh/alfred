---
name: alfred-init
description: Set up an Alfred workspace in the current folder — CLAUDE.md (personal settings), project-logs/, daily/ templates, .alfred/workspace marker. Use only when the user types /alfred-init or explicitly says "install/initialize Alfred".
---

# alfred-init

Turns the current working folder into an Alfred workspace. Every file created **belongs to the user**.
The common rules are copied into `.alfred/rules.md` by `../../hooks/sync-rules.sh` (relative to this skill), and the workspace
`CLAUDE.md` loads them with the line `@.alfred/rules.md`. The plugin's session-start hook keeps that copy up to date.

Templates are in this skill directory's `templates/` (next to this SKILL.md), one set per language:
`templates/en/` and `templates/ko/`. `templates/gitignore` is shared.

## Steps

### 1. Check the current folder (read only)
- Look at where you are and what's there with `pwd`, `ls -la`
- If `.alfred/workspace` already exists, say it's **already an initialized workspace** and stop
- If `CLAUDE.md` already exists, don't overwrite it. Ask via the multiple-choice question window (AskUserQuestion):
  append an Alfred settings section to the end of the existing file / stop.
  The appended section must include the line `@.alfred/rules.md` on its own line (not in backticks)
- If you're directly in the home directory (`~`), confirm once more (usually a dedicated folder is used)

### 2. Ask for settings
**Ask via the multiple-choice question window (AskUserQuestion).** Never in text.
Put the default in the options and take free input through the "Other" the window adds. Each question gets 2–4 options — never just one.

**Window 1 — language, alone.** Everything after this is asked in the chosen language.
- Language: `English` (default) / `한국어`

**Window 2 — two questions, nothing more**
1. User name (used to mark who decided in logs). If `git config user.name` is set, offer it as an option
2. How the assistant addresses the user (en e.g. "sir", the user's name / ko e.g. "OO님", "주인님")

**Everything else takes its default — don't ask:**
- Assistant name: `Alfred`
- Category folders: `Work` strict · `Research` strict · `Life` relaxed, plus `Incubator` (strict)
- Author header: off
- Statusline badge: off (step 5 runs only when the user asks for it later)
- git: not initialized (step 6 runs `git init` only when the user asks)

The closing message lists these defaults in one line and says any of them can be changed by just asking (step 6).

### 3. What will be created
No confirmation window — create right after step 2. If the user asks to see the full list, show it in chat.
`<lang>` is `en` or `ko` per step 2.
```
CLAUDE.md                              ← templates/<lang>/CLAUDE.md with settings filled in
.alfred/workspace                      ← marker (version, created date, language)
.alfred/rules.md                       ← copy of the common rules, written by ../../hooks/sync-rules.sh
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
- Fill every `{{...}}` in `CLAUDE.md` with the settings. Check that no `{{` remains
  - `{{AUTHOR_HEADER}}`: en `on` / `off`, ko `켬` / `끔`
  - `{{CATEGORY_ROWS}}`: one table row per category — `| <folder> | <what> | strict/relaxed |` (ko: `엄격` / `완화`)
- `.alfred/workspace` contents:
  ```
  alfred-workspace
  version: 0.4.4
  created: YYYY-MM-DD
  language: en
  ```
  (`language: ko` for Korean. The session-start hook reads this line)
- Copy templates as-is; don't add author headers (they're the user's files). In `Incubator/log.md`, replace `{{TODAY}}` with today's date
- Copy the common rules: `bash "<this skill dir>/../../hooks/sync-rules.sh" "<workspace root>"`. It prints `created`.
  Check that `CLAUDE.md` has the line `@.alfred/rules.md` on its own line. Don't edit `.alfred/rules.md` — the plugin overwrites it

### 5. Statusline badge (only when the user asks, during or after setup)
Shows a sky-blue `[ALFRED]` badge in the statusline inside Alfred workspaces. Not part of the default setup.
**This edits global settings (`~/.claude/settings.json`), so when the user asks for it, confirm through the question window first.**
Read whether a `statusLine` already exists and pick the options:
- No existing `statusLine`: turn on / skip
- One exists: show both (appended next to the existing one) / replace with Alfred / skip

If turning on:
1. Copy `../../hooks/statusline.sh` (relative to this skill) to `~/.claude/alfred-statusline.sh` and make it executable
   (the plugin cache path changes with every update, so it can't be written into settings.json directly)
2. For "show both", save the existing `statusLine.command` string to `~/.claude/.alfred-statusline-chain`
3. Set `statusLine` in `settings.json` to `{"type": "command", "command": "bash ~/.claude/alfred-statusline.sh"}`.
   **Touch no other keys.** Show the contents before editing and the diff after
- The color can be changed with the `ALFRED_COLOR` env var (256-color code. Default 117 sky blue, 114 green)
- To undo: restore `statusLine.command` from `~/.claude/.alfred-statusline-chain`, or delete `statusLine`

### 6. Wrap up
Write the closing message in this order, and put the restart **last**, in bold, on its own line — the user acts on the last thing they read. Nothing else in Alfred works until the restart, guide mode included.
- Tell them the first project can start with "create a <name> project in <category>"
  - Then introduce Incubator, in the chosen language and with the chosen form of address. Say it in your own words, close to this
    (ko): "아직 무엇을 구상 중이시라면 편하게 말씀해 주세요. Incubator 에서 그 내용을 추적하고 키웠다가, 실제 프로젝트로 띄울 때
    원하시는 디렉토리로 옮기시면 됩니다. Incubator 에는 간단한 궁금증도 기록해 아이디어가 날아가지 않게 해 드립니다.
    떠오른 아이디어 중 지금 당장 하지 않으실 것은 말씀만 해 주시면 Incubator open 에 적어 두겠습니다. open 을 적극적으로 써 보세요!"
    (en): "If you're still shaping an idea, just tell me. Incubator tracks it and lets it grow; when it becomes a real project, you move it
    to the folder you want. Even small questions go into Incubator so no idea slips away. Ideas you won't act on right now — just say so
    and I'll put them in Incubator's open.md. Make good use of open!"
  - Then one line on the defaults taken in step 2, and that any can be changed by just asking — e.g. (en) "I used the defaults for the rest:
    assistant name Alfred, folders Work · Research · Life (+ Incubator), author header off, no statusline badge, no git. Want any of these
    changed? Just tell me." (ko) "나머지는 기본값으로 했습니다: 비서 이름 Alfred, 폴더 Work · Research · Life (+ Incubator), 저작 헤더 끔,
    상태줄 배지 없음, git 안 함. 바꾸고 싶은 게 있으면 말씀만 해 주세요."
  - Then one line for first-timers: **after the restart**, `/guide-mode on` gives a short tour of Alfred and a usage tip now and then (`/guide-mode off` stops it)
  - Last, in bold: they **must restart Claude Code in this folder now** (quit, then `claude`) for the hook to recognize the workspace
- Don't ask about git. Run `git init` only if the user asks for it later

## Creating a new project (after init, when the user asks)
Create `project-logs/<category>/<project>/log.md` with the frontmatter from section 7 of the common rules and the top section
(goal · premises · why this approach now). Get objective · code · status from the user. Never make them up.
Next to it, create `decision.md` with only a `## Starting point` section (`## 출발점` in Korean) — the first objective with its date,
and the situation then and why it started, in the user's words. Ask for it in chat; don't fill it in yourself (section 14 of the common rules).
