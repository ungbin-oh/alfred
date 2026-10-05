<p align="center">
  <img src="https://em-content.zobj.net/source/apple/391/top-hat_1f3a9.png" width="110" />
</p>

<h1 align="center">Alfred</h1>

<p align="center">
  <strong>You make the calls. I keep things in order.</strong>
</p>

<p align="center">
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-blue?style=flat" alt="License"></a>
  <img src="https://img.shields.io/badge/Claude%20Code-plugin-D97757?style=flat" alt="Claude Code plugin">
  <a href="https://github.com/ungbin-oh/alfred/stargazers"><img src="https://img.shields.io/github/stars/ungbin-oh/alfred?style=flat&color=yellow" alt="Stars"></a>
</p>

<p align="center">
  <a href="#install">Install</a> •
  <a href="#codex">Codex</a> •
  <a href="#what-i-provide">What I provide</a> •
  <a href="#how-i-work">How I work</a> •
  <a href="#things-you-can-say">Things you can say</a> •
  <a href="#update-history">Update history</a> •
  <a href="README_kr.md">한국어</a>
</p>

written by Ungbin_Oh · created 2026-09-27 · updated 2026-10-05

---

Good day. I am Alfred.

I am a plugin that lets you use Claude Code — or Codex — as a **personal assistant**.
When you open a session, I report on every project in a table. I record what you decided and **why**,
and while you work, I note down every attempt and failure at your side.

One thing I shall make plain, however: **the decision is always yours.**
I offer no suggestions you did not ask for, and I ask before running anything.
Nor do I hand you a finished implementation first — you try, and I review alongside you.

> Status: **v0.1.7.** Local install, init and briefing tested on macOS (v0.1.2). v0.1.4 rule loading checked with `claude -p` on macOS; v0.1.5 rule wording not yet tested in a session. Codex plugin (`alfred-codex`) v0.1.6: rule loading checked with `codex exec` on macOS. Linux and Windows not yet tested.

## Install

Say this inside Claude Code:

```
/plugin marketplace add ungbin-oh/alfred
/plugin install alfred@alfred
```

Then give me a room to stay in.

1. Make a dedicated folder and open Claude Code there
   ```
   mkdir ~/ALFRED && cd ~/ALFRED && claude
   ```
2. Call `/alfred-init`. I first ask your language (**English** by default, or 한국어), then your name, how to address you,
   and your categories — all in question windows — and I create nothing until you've seen the file list and approved it.
   Last, I ask whether to show a sky-blue `[ALFRED]` badge in your statusline
   (this edits `statusLine` in the global `~/.claude/settings.json`. If you already have a statusline, I can sit next to it)
3. **Restart Claude Code once in the same folder.** From then on, I greet you first in every session
4. Tell me your first project, e.g. "create a Thesis-Experiment project in Research"

## Codex

The repository holds two plugins side by side: `alfred-claude/` for Claude Code (plugin `alfred`) and `alfred-codex/` for Codex
(plugin `alfred-codex`). The rules are the same file copied into both; only the way they reach the model differs.

Install in a terminal:

```
codex plugin marketplace add ungbin-oh/alfred
codex plugin add alfred-codex@alfred
```

Then make a dedicated folder, open Codex there and call the `alfred-init` skill (`$alfred-init`, or pick it from `/skills`).
Your settings go in `AGENTS.md` instead of `CLAUDE.md`.

- **Trust the hooks once.** The first time Codex starts in the workspace it asks you to review the plugin's hooks. Until you trust them,
  I can't load the rules
- **Question windows** need `codex --enable default_mode_request_user_input`. Without it I ask in chat, one question at a time
- **How the rules arrive:** Codex has no import in `AGENTS.md`, so the session-start hook prints the full rules into each session
  (its output limit is raised in `alfred-codex/hooks/hooks.json`). Updating the plugin updates the rules from the next session
- **Not in Codex:** the `[ALFRED]` statusline badge
- Update: `codex plugin marketplace upgrade alfred`, then `codex plugin add alfred-codex@alfred` again. Remove: `codex plugin remove alfred-codex@alfred`

## What I provide

| What | What it does |
|---|---|
| **Boot briefing** | When you open a session, a table of projects per category — status · last updated · days idle · next action. Active projects idle over 14 days are flagged 🔴 neglected (display only) |
| **Decision log** `log.md` | Not results, but **"why it was decided that way at the time"**. Each entry records who decided (you / me) |
| **Work ledger** `trace/` | Commands, raw errors, hypotheses and why they were ruled out — written down as you work. When you save, I distill it into the log |
| **Decision record** `decision.md` | Only the judgments that set a project's direction — situation, trigger, your thoughts in your words, what you decided, and how it measures against the goal. I interview you to write it, so you can see whether you've strayed from where you started |
| **Open questions** `open.md` | What you haven't decided yet — candidate options and their grounds. Once decided, recorded in the log and listed in the file's Closed table |
| **Archive** `Archive/` | Finished things you want to keep — outputs and records — out of the briefing's way. Moved only when you say so |
| **Daily notes** `daily/` | The story of each day and stray thoughts. Say "let's wrap up the day" and I write a timeline from the trace |
| **Question windows** | For short choices I use a multiple-choice window instead of text, so one answer stays per question. Long drafts I confirm with you in chat |
| **Two languages** | English or Korean, chosen at `/alfred-init`. One rulebook either way |
| `/alfred-init` | Sets up the workspace. Every file it creates is yours |
| `/manual-mode lite\|medium\|full` | Manual mode that ties my hands — you type the commands and code yourself |
| `[ALFRED]` badge | Shows in the statusline only inside an Alfred workspace |

## How I work

1. **The plugin keeps a copy of the common rules (`alfred-claude/rules/core.md`) in `.alfred/rules.md`, and your `CLAUDE.md` loads it with the line `@.alfred/rules.md`.** Update the plugin and the copy updates with it
2. **`/alfred-init` creates your files** — `CLAUDE.md` holding your settings, and the folder skeleton. Edit them as you like
3. **When the two disagree, yours wins.** Project `log.md` `## Format` > workspace `CLAUDE.md` > common rules
4. **In a folder without the `.alfred/workspace` marker, I do nothing.** I don't intrude on other work
5. I never make up the time — the shell's `date` fills it in. I have no clock, after all

```
~/ALFRED/
├── CLAUDE.md              your settings and rules
├── .alfred/workspace      the marker that this is my room (also holds the language)
├── .alfred/rules.md       copy of the common rules, kept by the plugin — don't edit
├── project-logs/          per project: log.md · decision.md · open.md · trace/
├── project-workspace/     actual code and outputs
├── daily/                 daily notes
└── Archive/               kept but not in use — the briefing doesn't look here
```

To switch language later, change the `language:` line in `.alfred/workspace` to `en` or `ko` and restart Claude Code.

## Things you can say

| You say | I do |
|---|---|
| `continue X` | Enter project X and brief the story so far |
| `save` | Show a summary of today's work and decisions, and write it to log.md once you approve |
| `let's wrap up the day` | Write the Timeline of today's daily note from the trace |
| `show full history` | Read that project's whole log |

## Updating

```
/plugin marketplace update alfred
/plugin uninstall alfred@alfred
/plugin install alfred@alfred
```

Then restart Claude Code once. Your workspace logs and settings stay as they are.
In the first session after an update I refresh `.alfred/rules.md` and read it myself; from the next session it loads on its own.
Workspaces made before 0.1.4 don't have the `@.alfred/rules.md` line in `CLAUDE.md` yet — I'll ask you once whether to add it.

## Update history

What changed in each version is in [CHANGELOG.md](CHANGELOG.md). Latest: **0.1.9** (2026-10-05) — bug fix: `alfred-init` confirms through the question window again, with a short summary inside the question. Before that, **0.1.8** — bug fix (Codex): Codex's own `/init` no longer touches an Alfred workspace. Before that, **0.1.7** — bug fix: `alfred-init` shows the file list in chat instead of under a question window. Before that, **0.1.6** — the repository splits into `alfred-claude/` and `alfred-codex/`, and Codex gets its own plugin. Before that, **0.1.5** — rules rewritten in plainer sentences, boot asks about yesterday's To do, decision.md leaves "what counts as a judgment" to you, personal details removed.

## Dismissing me

```
/plugin uninstall alfred@alfred
```

Your workspace logs and notes remain. They are all yours.

If you turned on the statusline badge, undo it separately: delete `statusLine` from `~/.claude/settings.json`,
or if you chose to show both, restore the original command saved in `~/.claude/.alfred-statusline-chain`,
then delete `~/.claude/alfred-statusline.sh` and `.alfred-statusline-chain`.

## Korean translation

The rules and skills have one English source (`alfred-claude/`; `alfred-codex/` carries the same rules). A Korean translation for readers lives in [`docs/ko/`](docs/ko/); Alfred itself doesn't read it.

## Requirements

- Claude Code (a version with plugin support), or Codex CLI with plugins (checked with 0.160.0)
- macOS or Linux (the hooks are bash scripts. Not yet tested on Windows)

## License

[MIT](LICENSE) © 2026 Ungbin Oh
