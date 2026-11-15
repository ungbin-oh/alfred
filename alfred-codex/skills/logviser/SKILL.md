---
name: logviser
description: Toggle the log advisor (on / lite / off / status / report / reset). Use only when the user types $logviser. When on, the assistant asks about saving the log once a project's traces not yet carried into log.md pass a threshold.
---

# logviser

The log advisor. Traces pile up during work and log.md is written only on "save", so it is easy to go days without
saving. While logviser is on, the plugin's UserPromptSubmit hook counts per project how many trace entries are not in
log.md yet, and when a project passes its threshold, it tells the assistant to ask.

The state is one line (`on` or `lite`) in the workspace's `.alfred$logviser` file. No file = off.
Workspace root = the working folder or its nearest parent that has `.alfred/workspace`.
If there is none, say "this is not an Alfred workspace" and stop.

## By argument

| Argument | Action |
|---|---|
| `on` | Write `on` to `.alfred$logviser`. Say it's on, with one line on what it does (below) |
| `lite` | Write `lite` to `.alfred$logviser`. Say it's on in lite, with one line on what it does |
| `off` | Delete `.alfred$logviser`. Say it's turned off |
| `status` | On (and which level) or off, then the table |
| `report` | The table only |
| `reset` | Delete `.alfred$logviser-seen`. Say projects over their threshold will be asked about again from the next turn |
| (none) | One line of usage: `$logviser on \| lite \| off \| status \| report \| reset` |
| anything else | Say the argument is unknown and show the usage above |

**The table** — on this turn the hook injects it ("LOGVISER — table for the logviser skill this turn"). Show it as it is.
If it isn't in the context, say the hook isn't attached to this session — don't count by hand.

## Levels

- **on** — when a project passes its threshold, the assistant does the user's request first, then opens a question window:
  what was done (from the trace headers), "what judgment or intent was behind it?", options "Save to the log now" / "Skip".
  A judgment typed into the free-text field becomes the log entry's Decision & Reason, and the draft is shown before writing
- **lite** — one line at the end of the reply (`📝 <code>: N traces not logged`), no window

## How it counts

- Not logged = the largest `<code>-trace<N>` in the newest trace file − the largest one cited on the log's `**Trace:**` lines.
  Only the project's own code counts
- Threshold: 8, or `logviser: N` in that project's log.md frontmatter
- After a skip, the same project is asked about again only after another threshold's worth (8 → 16 → 24 …)
- End of the day: while it's on, when the user says the day is over ("wrap up the day", "done for the day" …), the hook
  injects the table and the assistant shows it at the end of the reply and asks whether to save

On Codex the state shows in the thread name: `[ALFRED] [LOGVISER INC 9] 2026-11-15 #2` (the hook renames it; at once when
Codex runs with `codex --remote unix://`, otherwise after /resume).

The hook injects the detailed rules on the turns it fires. On this turn (the toggle turn) it injects only the table.
