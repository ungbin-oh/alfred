---
name: logviser
description: Toggle the log advisor (on / lite / auto / off / status / report / reset). Use only when the user types $logviser. When on, the assistant asks about saving the log once a project's traces not yet carried into log.md pass a threshold; in auto it writes the entries itself.
---

# logviser

The log advisor. Traces pile up during work and log.md is written only on "save", so it is easy to go days without
saving. While logviser is on, the plugin's UserPromptSubmit hook counts per project how many trace entries are not in
log.md yet, and when a project passes its threshold, it tells the assistant to ask — or, in auto, to write the entries.

The state is one line (`on`, `lite` or `auto`) in the workspace's `.alfred/logviser` file. No file = off.
Workspace root = the working folder or its nearest parent that has `.alfred/workspace`.
If there is none, say "this is not an Alfred workspace" and stop.

## By argument

| Argument | Action |
|---|---|
| `on` | Write `on` to `.alfred/logviser`. Say it's on, with one line on what it does (below) |
| `lite` | Write `lite` to `.alfred/logviser`. Say it's on in lite, with one line on what it does |
| `auto` | Write `auto` to `.alfred/logviser`. Say it's on in auto, with what it does (below) — and say plainly that from now on log entries are written without asking, each marked with an `**Auto:**` line |
| `off` | Delete `.alfred/logviser`. Say it's turned off |
| `status` | On (and which level) or off, then the table |
| `report` | The table only |
| `reset` | Delete `.alfred/logviser-seen`. Say projects over their threshold will be asked about again from the next turn |
| (none) | One line of usage: `$logviser on \| lite \| auto \| off \| status \| report \| reset` |
| anything else | Say the argument is unknown and show the usage above |

**The table** — on this turn the hook injects it ("LOGVISER — table for the logviser skill this turn"). Show it as it is.
If it isn't in the context, say the hook isn't attached to this session — don't count by hand.

## Levels

- **on** — when a project passes its threshold, the assistant does the user's request first, then opens a question window:
  what was done (from the trace headers), "what judgment or intent was behind it?", options "Save to the log now" / "Skip".
  A judgment typed into the free-text field becomes the log entry's Decision & Reason, and the draft is shown before writing
- **lite** — one line at the end of the reply (`📝 <code>: N traces not logged`), no window
- **auto** — no question and no draft: when a project passes its threshold, the assistant does the user's request first, then
  writes the log entries itself from the traces and says what it saved in the last lines of the reply. For people who find the
  confirmation step a chore — turning auto on is the confirmation, given ahead
  - Every such entry carries `**Auto:** written by logviser auto — not confirmed by the user` right under `**Trace:**`, so it can
    be told from an entry the user confirmed
  - The user's intent goes in only as far as the trace holds it: a decision is written only when the trace records it and who
    made it. No made-up reasons. A stretch of plain questions and answers gets Problem and Result only
  - A topic still in progress is left for the next time, unless the count has reached twice the threshold
  - `next_action`, `objective` and `status` are not touched; open.md and decision.md are not written from here
  - A wrong auto entry is not edited (the log is append-only) — a correcting entry is appended
  - A save the user asks for ("save") still shows a draft and waits, as always

## How it counts

- Not logged = the largest `<code>-trace<N>` in the newest trace file − the largest one cited on the log's `**Trace:**` lines.
  Only the project's own code counts
- Threshold: 8, or `logviser: N` in that project's log.md frontmatter
- After a skip, the same project is asked about again only after another threshold's worth (8 → 16 → 24 …)
- End of the day: while it's on, when the user says the day is over ("wrap up the day", "done for the day" …), the hook
  injects the table and the assistant shows it at the end of the reply and asks whether to save. In auto it writes the
  entries for every project in the table instead, topics in progress included

On Codex the state shows in the thread name: `[ALFRED] [LOGVISER INC 9] 2026-11-15 #2`, with `LOGVISER-lite` / `LOGVISER-auto` for those levels (the hook renames it; at once when
Codex runs with `codex --remote unix://`, otherwise after /resume).

The hook injects the detailed rules on the turns it fires (for auto too). On this turn (the toggle turn) it injects only the table.
