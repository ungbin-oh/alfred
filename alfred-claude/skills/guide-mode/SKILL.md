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

The tour goes **one item at a time, each in its own question window** — not as a list. The window is used to step through,
not to ask: the user reads one item, picks "Got it — next", and the next item comes. Plain words, no internal section numbers.

- **Each window:** one question. Header `Tour N/10`. The question text is the item itself, written out in full in one or two short
  sentences (bold name first). Options, in this order: `Got it — next` / `Skip the rest of the tour` (ko: `알겠어요 — 다음` / `나머지 소개 건너뛰기`)
- **Write nothing in chat before or between the windows.** The window hides the text above it, so the item lives inside the window.
  Right after creating the state file, open window 1
- **Tree preview:** items with a tree below put it in the `preview` of the `Got it — next` option, so the tree shows beside the item.
  Each tree opens only the part of the workspace that item is about — the whole tree doesn't fit (a preview shows about 15 lines).
  Copy it as written; translate only the comments after the names into the workspace language. Items without a tree get no preview
- **Got it — next** → the next item's window. **Skip** → stop the windows there and go to the closing line
- **The user types their own answer** (the window's free-text field): answer it in a line or two, then open the window for the next item
- **After the last item (or a skip),** end the reply with one line recommending the Incubator as the place to begin — ko: "처음이시라면
  Incubator 에서 가볍게 질의응답을 주고받는 걸 추천드릴게요!" / en: "If you're new, I'd recommend starting in the Incubator — just ask me
  something and we'll go from there!" No window and no other question after that line
- **If the question window isn't available,** write all ten items out in full as a list instead — never a stand-in like
  "I've introduced the main features" — and close with the same line

The ten items:
1. What Alfred is: you decide, Alfred keeps the records
2. **Boot briefing** — opening a session shows every project's status, last update, next action and open items
3. **Projects** — each has `decision.md` (the judgments that set its direction — the most important one), `log.md` (decisions and why — **written only when you say "save"**), `trace/` (everything as it happens — written without being asked), `open.md` (things you want but won't start yet)
4. **Incubator** — ideas still taking shape and small questions go here; when one becomes real, it's launched and moved to a category
5. **"Later" ideas** — just say so and they go into an `open.md` (Incubator's, if no project fits)
6. **Saying "save"** — Alfred summarizes the day's work and decisions and writes the log after you confirm
7. **"continue X"** — enter project X and get the story so far
8. **Daily and weekly notes** — "let's wrap up the day" writes the day's timeline from the traces; on Friday–Sunday, "let's write the weekly" reviews the week and plans the next, and the plan flows into each day's to-dos
9. **Question windows** — short choices come as a multiple-choice window, like this tour; long drafts are confirmed in chat
10. **`/manual-mode`** — you type the commands and code yourself; **Archive** — finished things you keep, out of the briefing

Previews (item number → tree):

1.
```
<workspace>/
├── CLAUDE.md            your settings
├── project-logs/        records, one folder per project
├── project-workspace/   code and outputs, same paths
├── daily/               daily notes
├── weekly/              weekly notes
└── Archive/             kept, out of the briefing
```
2.
```
project-logs/
├── <category>/
│   └── <project>/
│       ├── log.md       ← frontmatter + last 3 entries
│       └── open.md      ← item titles only
└── Incubator/
    ├── log.md
    └── open.md
```
3.
```
project-logs/<category>/<project>/
├── decision.md       judgments that set direction ★
├── log.md            decisions and why — on "save"
├── open.md           wanted, not started yet
└── trace/
    └── YYYY-MM-DD.md everything, written as you go
project-workspace/<category>/<project>/
└── docs/ · code      outputs, same path
```
4.
```
project-logs/Incubator/
├── log.md
├── open.md           ideas and small questions
├── trace/
└── <sub-project>/    starts here
    ├── log.md
    └── trace/
          ↓ when it becomes real
project-logs/<category>/<sub-project>/
```
5.
```
project-logs/<project>/open.md
├── ## Closed         taken up or dropped
├── ## 1. <idea>
└── ## 2. <idea>
```
6.
```
project-logs/<category>/<project>/
├── trace/YYYY-MM-DD.md   read on "save"
└── log.md                ← summary appended after you confirm
```
7.
```
project-logs/<category>/X/
├── log.md            ← the story so far
└── open.md
project-workspace/<category>/X/   ← where the code is
```
8.
```
daily/
├── _template.md
└── YYYY/YYYY-MM/YYYY-MM-DD.md   To do · Done · Timeline · Thoughts · Tomorrow
weekly/
├── _template.md
└── YYYY/YYYY-Www.md             this week's review + next week's plan
      └─ next week's to-dos → each day's ## To do
```
10.
```
Archive/
├── README.md            what's archived
├── log-archive/         records, same shape as project-logs
└── workspace-archive/   outputs, same shape as project-workspace
```

After the tour the user answers in their own words; if they bring an idea or a question, start it in the Incubator
(open item / trace entry); if they ask for a project, create it, asking for what the rules require (objective, code) instead of
making it up.

## While on

The hook adds the tip rules every turn. On this turn (the toggle turn) the hook skips injection.
