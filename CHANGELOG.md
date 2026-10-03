# Changelog

written by Ungbin_Oh · created 2026-10-03 · updated 2026-10-03

Newest first. Hashes are commits in this repository. Korean translation: [`docs/ko/CHANGELOG.md`](docs/ko/CHANGELOG.md).

## 0.1.3 — 2026-10-03

Rule updates carried over from the workspace Alfred was modeled on.

- **open.md keeps a Closed table** (c40fd39) — decided items are not deleted; they move to one line in `## Closed`
  (item · closed date · where the conclusion went). The file stays and remaining items keep their numbers
- **Timeline summary table** (d3c99b0) — the daily Timeline opens with a table (# · time · project · one line),
  then the chunk details. Both timeline examples updated
- **No more "open a separate session" for large implementations** (e9f1396) — planning and implementation stay in one session
- **Neglected flag** (4a6a6d8) — active projects idle over 14 days show `🔴 neglected` in the briefing. Display only; status is never changed automatically
- **Archive** (b8d667d) — `Archive/` with `workspace-archive/` (outputs, not in git), `log-archive/` (records, tracked) and a README list.
  New status `archived`. Boot and project search don't look inside. `/alfred-init` creates it
- **Rule tightening** (2d449c0) — options only as already on the table; briefing project cell `name (code)`;
  undecided next_action is just "undecided" (or "undecided — see [[open]]"); question windows for short choices only, long drafts confirmed in chat
- **decision.md** (04efbb6) — a per-project record of only the judgments that set direction, each measured against the goal,
  starting from a `## Starting point`. Written by interviewing the user in chat, one question at a time

**Existing workspaces:** the rules update with the plugin. `Archive/` and the new `.gitignore` line are only created by `/alfred-init`,
so in an existing workspace add `Archive/README.md` and `Archive/workspace-archive/` (in `.gitignore`) yourself if you want them.
Existing projects get a `decision.md` when you start one.

## 0.1.2 — 2026-09-26 / 2026-09-27

- Version bump so a reinstall picks up the new files instead of the cached copy (c58fbc0)
- README: how to update (a54146d)
- **English by default, Korean chosen at `/alfred-init`** (bd22474) — one English rulebook; language-specific templates, READMEs and hook text;
  `language:` in `.alfred/workspace`. The Korean original is kept as tag `v0.1.2-ko` and translated in `docs/ko/`.
  Author headers removed from files the model reads as instructions

## 0.1.1 — 2026-09-26

- First public version (18e15aa): boot briefing, decision log, trace, open.md, daily notes, `/alfred-init`, `/manual-mode`,
  `[ALFRED]` statusline badge, question windows
- Marketplace owner set to the GitHub account (4c6e5ca, eb9fe3d)
- README: status, butler voice, what you get, how it works (cc9f873, dba1b2c)

0.1.0 was a local draft before the public history began.
