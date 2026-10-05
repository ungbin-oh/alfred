---
name: manual-mode
description: Toggle manual mode (lite / medium / full / once / status / off). Use only when the user types /manual-mode. When on, the assistant only prints commands and code, and the user runs them.
---

# manual-mode

A mode that ties the assistant's hands so the user types things themselves. The level is stored as one line in the workspace's
`.alfred/manual-mode` file, and the plugin's UserPromptSubmit hook injects the rules every turn.

Workspace root = the working folder or its nearest parent that has `.alfred/workspace`.
If there is none, say "this is not an Alfred workspace" and stop.

## By argument

| Argument | Action |
|---|---|
| `lite` / `medium` / `full` | Write that word as one line to `.alfred/manual-mode`. Say the level's rules apply from this turn |
| `off` | Delete `.alfred/manual-mode`. Say it's turned off |
| `status` | If the file exists, report the level; otherwise "off" |
| `once` | See "once" below |
| (none) | One line of usage: `/manual-mode lite\|medium\|full \| once \| status \| off` |
| anything else | Say the argument is unknown and show the usage above |

Writing and deleting the state file is done by the assistant even while the mode is on (an allowed exception).

## Levels

- **lite** — only shell runs are the user's
- **medium** — + writing and editing code files is the user's too. The assistant prints code blocks
- **full** — + no design offered either. Hint ladder pinned to rung 1 (direction)

The hook injects the detailed rules every turn. On this turn (the toggle turn) the hook skips injection,
so if you just turned a level on, act by the level just set.

## once

An exception for this one turn only. **The level stays** (the file isn't changed). If the mode is off,
say "once only works while the mode is on" and stop.

If it's on, **the assistant runs the shell block it printed in the previous turn itself.**
- Only the commands in that block. Don't invent or add commands
- Before running, write one line on what is being run
- If the previous turn had more than one block, don't run — ask which one
- If the previous turn had no block, say there's nothing to run
- Report the result after running. From the next turn, back to the normal level
- The exception covers only running that block. Follow-up runs and retries are the user's again (permission covers one run)
