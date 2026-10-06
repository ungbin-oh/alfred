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
Put the default in the options and take free input through the "Other" the window adds.

**Window 1 — language, alone.** Everything after this is asked in the chosen language.
- Language: `English` (default) / `한국어`

**Window 2** (up to 4 questions per window)
1. User name (used to mark who decided in logs). If `git config user.name` is set, offer it as an option
2. How the assistant addresses the user (en e.g. "sir", the user's name / ko e.g. "OO님", "주인님")
3. Assistant name (Alfred)
4. Category folders — names and output placement (strict/relaxed)
   (default: `Work` strict · `Research` strict · `Life` relaxed)

**Window 3**
5. Whether to turn on the author header, and if so, the name to put in it (off)

### 3. Show what will be created and confirm
**Confirm through the question window** before creating (create / redo settings / stop). Put a short summary of what will be created **in the question text itself** — the file count and the top-level items, two or three lines (e.g. "15 files: CLAUDE.md, .alfred/, project-logs · project-workspace for Work/Research/Life, daily/, Archive/"). Don't print the full list in chat before the window (the window covers it) and don't put it in an option preview (only about 15 lines show). If the user asks to see the full list, show it in chat and ask again.
`<lang>` is `en` or `ko` per step 2.
```
CLAUDE.md                              ← templates/<lang>/CLAUDE.md with settings filled in
.alfred/workspace                      ← marker (version, created date, language)
.alfred/rules.md                       ← copy of the common rules, written by ../../hooks/sync-rules.sh
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
- Fill every `{{...}}` in `CLAUDE.md` with the settings. Check that no `{{` remains
  - `{{AUTHOR_HEADER}}`: en `on` / `off`, ko `켬` / `끔`
  - `{{CATEGORY_ROWS}}`: one table row per category — `| <folder> | <what> | strict/relaxed |` (ko: `엄격` / `완화`)
- `.alfred/workspace` contents:
  ```
  alfred-workspace
  version: 0.1.10
  created: YYYY-MM-DD
  language: en
  ```
  (`language: ko` for Korean. The session-start hook reads this line)
- Copy templates as-is; don't add author headers (they're the user's files)
- Copy the common rules: `bash "<this skill dir>/../../hooks/sync-rules.sh" "<workspace root>"`. It prints `created`.
  Check that `CLAUDE.md` has the line `@.alfred/rules.md` on its own line. Don't edit `.alfred/rules.md` — the plugin overwrites it

### 5. Statusline badge (optional)
Shows a sky-blue `[ALFRED]` badge in the statusline inside Alfred workspaces. **This edits global settings (`~/.claude/settings.json`),
so ask through the question window first.** Read whether a `statusLine` already exists and pick the options:
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
- Tell the user they **must restart Claude Code in this folder** for the hook to recognize the workspace
- Tell them the first project can start with "create a <name> project in <category>"
- Only ask whether to use git — through the question window (use git / not now). Run `git init` only if the user says to

## Creating a new project (after init, when the user asks)
Create `project-logs/<category>/<project>/log.md` with the frontmatter from section 7 of the common rules and the top section
(goal · premises · why this approach now). Get objective · code · status from the user. Never make them up.
Next to it, create `decision.md` with only a `## Starting point` section (`## 출발점` in Korean) — the first objective with its date,
and the situation then and why it started, in the user's words. Ask for it in chat; don't fill it in yourself (section 14 of the common rules).
