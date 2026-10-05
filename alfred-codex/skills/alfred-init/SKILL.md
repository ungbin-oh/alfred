---
name: alfred-init
description: Set up an Alfred workspace in the current folder — AGENTS.md (personal settings), project-logs/, daily/ templates, .alfred/workspace marker. Use only when the user types /alfred-init or explicitly says "install/initialize Alfred".
---

# alfred-init

Turns the current working folder into an Alfred workspace. Every file created **belongs to the user**.
The common rules are not copied into the workspace: the plugin's session-start hook adds them to every Codex session.
The workspace `AGENTS.md` holds only the user's settings.

**Question window:** wherever this skill says "question window", use `request_user_input` if it is available
(Codex needs it enabled, e.g. `codex --enable default_mode_request_user_input`). If it isn't, ask in chat,
one question at a time, with the options listed.

Templates are in this skill directory's `templates/` (next to this SKILL.md), one set per language:
`templates/en/` and `templates/ko/`. `templates/gitignore` is shared.

## Steps

### 1. Check the current folder (read only)
- Look at where you are and what's there with `pwd`, `ls -la`
- If `.alfred/workspace` already exists, say it's **already an initialized workspace** and stop
- If `AGENTS.md` already exists, don't overwrite it. Ask via the question window:
  append an Alfred settings section to the end of the existing file / stop
- If you're directly in the home directory (`~`), confirm once more (usually a dedicated folder is used)

### 2. Ask for settings
**Ask via the question window** (see above).
Put the default in the options and let the user answer freely too.

**Window 1 — language, alone.** Everything after this is asked in the chosen language.
- Language: `English` (default) / `한국어`

**Window 2** (up to 3 questions per window in Codex)
1. User name (used to mark who decided in logs). If `git config user.name` is set, offer it as an option
2. How the assistant addresses the user (en e.g. "sir", the user's name / ko e.g. "OO님", "주인님")
3. Assistant name (Alfred)

**Window 3**
4. Category folders — names and output placement (strict/relaxed)
   (default: `Work` strict · `Research` strict · `Life` relaxed)
5. Whether to turn on the author header, and if so, the name to put in it (off)

### 3. Show what will be created and confirm
Show the list below as text, then **confirm through the question window** before creating (create / redo settings / stop).
`<lang>` is `en` or `ko` per step 2.
```
AGENTS.md                              ← templates/<lang>/AGENTS.md with settings filled in
.alfred/workspace                      ← marker (version, created date, language)
.gitignore                             ← templates/gitignore
project-logs/<category>/.gitkeep       ← one per category
project-workspace/<category>/.gitkeep
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
  version: 0.1.6
  created: YYYY-MM-DD
  language: en
  ```
  (`language: ko` for Korean. The session-start hook reads this line)
- Copy templates as-is; don't add author headers (they're the user's files)

### 5. Wrap up
- Tell the user they **must restart Codex in this folder** for the hook to recognize the workspace.
  On the first start Codex asks them to review and trust the plugin's hooks; until they do, the rules are not loaded
- Tell them the first project can start with "create a <name> project in <category>"
- Only ask whether to use git. Run `git init` only if the user says to

## Creating a new project (after init, when the user asks)
Create `project-logs/<category>/<project>/log.md` with the frontmatter from section 7 of the common rules and the top section
(goal · premises · why this approach now). Get objective · code · status from the user. Never make them up.
Next to it, create `decision.md` with only a `## Starting point` section (`## 출발점` in Korean) — the first objective with its date,
and the situation then and why it started, in the user's words. Ask for it in chat; don't fill it in yourself (section 14 of the common rules).
