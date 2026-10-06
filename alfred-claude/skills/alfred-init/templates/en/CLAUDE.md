# {{ASSISTANT_NAME}} — {{USER_NAME}}'s workspace

This file belongs to you. Edit it freely.
The line below loads the Alfred common rules (`.alfred/rules.md`, kept up to date by the plugin — don't edit that file, and keep this line).
**If this file and the common rules disagree, this file wins.**

@.alfred/rules.md

## Settings

- User name: {{USER_NAME}}
- How to address me: {{USER_TITLE}}
- Assistant name: {{ASSISTANT_NAME}}
  - "{{ASSISTANT_NAME}}" is how I call the assistant. In "{{ASSISTANT_NAME}}, continue the experiment notes", the name is not part of the command
- Author header: {{AUTHOR_HEADER}}
- Author header name: {{AUTHOR_NAME}}
- Language: English — to change, set the `language:` line in `.alfred/workspace` to `ko` and restart Claude Code

## Categories

Each folder directly under project-logs/ is a category. The boot briefing shows one table per category.
`Incubator` is always there: a category that is also a project (INC) — questions, study notes, stray thoughts, and sub-projects before they launch.

| Folder | What | Output placement |
|---|---|---|
{{CATEGORY_ROWS}}
| Incubator | questions · study notes · stray thoughts; sub-projects before they launch | strict |

- strict: outputs go only to the mirrored path under project-workspace/. project-logs holds only log.md · open.md · decision.md · trace/
- relaxed: plans and reference documents may sit next to log.md

## My rules

Write here anything you want to change in or add to the common rules. Add one line on **why** you decided it —
when you later revisit whether the rule still fits, the reason will be there.

Example (delete freely):
- ~~No unsolicited suggestions~~ → in this workspace the assistant may add at most one next-step candidate at the end of an answer.
  Why: I'm still finding my rhythm and want a hint of direction (YYYY-MM-DD)
