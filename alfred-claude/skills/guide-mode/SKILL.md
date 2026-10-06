---
name: guide-mode
description: Toggle guide mode (on / off / status). Use only when the user types /guide-mode. When on, Alfred gives a short tour first and then drops one short usage tip now and then.
---

# guide-mode

A mode for people new to Alfred. Turning it on gives a short tour of Alfred and invites the first use; while it stays on,
Alfred adds a short usage tip now and then. The state is the workspace's `.alfred/guide-mode` file (it exists = on), and the plugin's
UserPromptSubmit hook injects the tip rules every turn.

Workspace root = the working folder or its nearest parent that has `.alfred/workspace`.
If there is none, say "this is not an Alfred workspace" and stop.

Speak in the workspace language (`language:` in `.alfred/workspace`) and use the form of address and assistant name from the workspace
settings file (`CLAUDE.md`).

## By argument

| Argument | Action |
|---|---|
| `on` (or none, while off) | Create `.alfred/guide-mode` (one line: `on`). Then give the tour below |
| `off` | Delete `.alfred/guide-mode`. One line: it's off, and `/guide-mode on` turns it back on |
| `status` | "on" if the file exists, otherwise "off" |
| (none, while on) | Say it's already on; `/guide-mode off` turns it off |
| anything else | Say the argument is unknown; usage: `/guide-mode on \| off \| status` |

Writing and deleting the state file is done by the assistant (allowed even while manual mode is on).

## The tour (when turned on)

Short — about ten lines, one line per item, no tables. Plain words, no internal section numbers.
1. One line of what Alfred is: you decide, Alfred keeps the records
2. **Boot briefing** — opening a session shows every project's status, last update and next action
3. **Projects** — each has `log.md` (decisions and why), `trace/` (everything as it happens), `decision.md` (judgments that set direction), `open.md` (not decided yet)
4. **Incubator** — ideas still taking shape and small questions go here; when one becomes real, it's launched and moved to a category
5. **"Later" ideas** — just say so and they go into an `open.md` (Incubator's, if no project fits)
6. **Saying "save"** — Alfred summarizes the day's work and decisions and writes the log after you confirm
7. **"continue X"** — enter project X and get the story so far
8. **Daily notes** — "let's wrap up the day" writes the day's timeline from the traces
9. **Question windows** — short choices come as a multiple-choice window; long drafts are confirmed in chat
10. **`/manual-mode`** — you type the commands and code yourself; **Archive** — finished things you keep, out of the briefing

Then invite the first use. Through the question window (AskUserQuestion): one question — what would you like to start with? — options exactly two,
"Start a project" / "Put an idea in Incubator" (in the workspace language); the window's "Other" lets them say something else.
After the answer, do that (create the project with the user's details, or start an Incubator open item / trace entry) — asking for
details the rules require (objective, code) instead of making them up.

## While on

The hook adds the tip rules every turn. On this turn (the toggle turn) the hook skips injection.
