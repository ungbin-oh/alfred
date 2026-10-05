# Changelog

written by Ungbin_Oh · created 2026-10-03 · updated 2026-10-05

Newest first. Hashes are commits in this repository. From 0.1.8 on there is one version for the whole repository: both plugins (`alfred` for Claude Code, `alfred-codex` for Codex) carry the same number, and each item is tagged **[Claude]**, **[Codex]** or **[Both]**. Korean translation: [`docs/ko/CHANGELOG.md`](docs/ko/CHANGELOG.md).

## 0.1.9 — 2026-10-05

**Bug fix.** Both plugins are now 0.1.9.

- **[Both] `alfred-init` confirms through the question window again** — 0.1.7 moved the "create / redo settings / stop" confirmation
  to chat so the window would not cover the file list, which meant typing the answer. Now the window asks, with a two-or-three-line
  summary (file count and top-level items) inside the question itself; the full list is shown in chat only if asked for.
  The closing "use git?" question also goes through the window. Codex's skill names `request_user_input` explicitly, since without it
  the confirmation still came as chat. Checked in Claude Code and Codex

## 0.1.8 — 2026-10-05

**Bug fix.** Both plugins are now 0.1.8.

- **[Codex] Codex's own `/init` could be mistaken for Alfred's setup** — Codex lists `/init` on its start screen every session. It is Codex's
  command for writing a contributor-guide `AGENTS.md`, and in an Alfred workspace that file holds the user's settings.
  A new `UserPromptSubmit` hook (`alfred-codex/hooks/init-guard.sh`) catches the `/init` prompt in an Alfred workspace and tells the
  model not to touch any file and to explain that Alfred is already set up (`$alfred-init` is Alfred's setup). Outside Alfred
  workspaces `/init` works as usual. Codex asks once more to trust hooks after updating

## 0.1.7 — 2026-10-05

**Bug fix** (both plugins: `alfred` and `alfred-codex` are now 0.1.7).

- **`alfred-init`: the file list was covered by the question window** — step 3 said to show the list of files to create and then
  confirm in a question window. The window covered the list, and a list put in an option preview was cut off after about 15 lines.
  This went against the rules' own question-window section. Now the list is shown in chat and confirmed in chat

## 0.1.6 — 2026-10-05

Codex support, as a separate plugin in the same repository.

- **Two plugins, one repository** — `alfred-claude/` (Claude Code, plugin `alfred`, still 0.1.5 inside) and `alfred-codex/`
  (Codex, plugin `alfred-codex`, 0.1.6). The marketplace at the root lists both. Shared files (rules, skills, templates) are copied
  into each; Claude Code users install as before (`alfred@alfred`)
- **Codex: rules through the session-start hook** — `AGENTS.md` has no import, so the hook prints the full rules every session.
  Its output limit is raised to 20,000 tokens in `alfred-codex/hooks/hooks.json` (Codex's default is about 2,500 tokens, then it cuts
  the middle). Hooks live in `hooks/hooks.json`; Codex ignores hooks written inside `plugin.json`
- **Codex: settings in `AGENTS.md`** — `alfred-init` creates `AGENTS.md` from `templates/<lang>/AGENTS.md`; no `.alfred/rules.md` copy,
  no statusline badge (Codex has no custom statusline). Question windows use `request_user_input` when enabled, otherwise chat
- **Codex: trust the hooks once** — Codex asks the user to review plugin hooks before they run

## 0.1.5 — 2026-10-05

Rule updates carried over from the workspace Alfred was modeled on (its rules were rewritten section by section in plain sentences).
Personal details removed from the repo.

- **Plainer wording, same rules** — role boundary, no-suggestions, ask-before-running and the question window now say who does what
  in full sentences. Rule history dates were already absent here
- **Boot asks once about yesterday's `## To do`** — skim it and ask in the briefing whether it was done
- **Question window** — the preview field may be used (just not for long content the user must read in full); if the user only sees
  the final message, put the facts the question needs inside the window, and ask a long question in chat instead
- **One project at a time** — something unrecorded in another project is remembered, not mentioned, until the user switches or says "save"
- **Time** — also check `date` when a draft must be shown before the shell can fill in a time
- **log.md** — `aliases` explained; "who decided" needs no "decided:" label; unverified estimates go to the trace, one-off measurements
  never to `docs/`; entry numbers: no zero padding, next number from the last header of the most recent file (the `sort` warning is gone);
  the briefing line about showing the objective is removed
- **trace** — everything exchanged in the project goes in: questions, requests, answers, attempts, decisions
- **open.md** — kept separate because it is a different kind of document from log, trace and decision
- **decision.md** — a judgment is a direction the user settled on after thinking it through, and **the user decides what counts as one**.
  The "what counts as a judgment" and "write fragments early" rules are removed; why it is separate: judgments weren't getting recorded in the log
- **Timeline** — what counts as a dead end worth keeping is spelled out (a wrong estimate that shook a judgment, a mismeasured number nearly used,
  a reported pass that wasn't); tool slips stay in the trace
- **Personal details removed** — the author line is gone from `rules/core.md` (the model reads that file, and the line could leak into
  answers); the timeline example's "advisor meeting" is now a "team meeting"

## 0.1.4 — 2026-10-05

- **The common rules load through `CLAUDE.md`, not hook output.** Claude Code caps hook output at 10,000 characters and the rules
  are about 24,000, so from 0.1.2 on the model only saw a 2,000-character preview (sections 0–1). Now `hooks/sync-rules.sh` copies
  `rules/core.md` into the workspace as `.alfred/rules.md`, and `CLAUDE.md` loads it with the line `@.alfred/rules.md`
  (imports load in full, up to 4 MiB per file). The session-start hook prints only the short header and refreshes the copy
  when it differs. `/alfred-init` writes the copy and the import line

**Existing workspaces:** `CLAUDE.md` is loaded before the session-start hook runs, so a copy the hook just created or updated
loads on its own only from the next session; in that first session Alfred reads the file itself. Workspaces made before 0.1.4
have no `@.alfred/rules.md` line — Alfred asks once whether to add it, and never edits `CLAUDE.md` without your answer.

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
