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
  <img src="https://img.shields.io/badge/Codex-plugin-10A37F?style=flat" alt="Codex plugin">
  <a href="https://github.com/ungbin-oh/alfred/stargazers"><img src="https://img.shields.io/github/stars/ungbin-oh/alfred?style=flat&color=yellow" alt="Stars"></a>
</p>

<p align="center">
  <a href="#install">Install</a> •
  <a href="#what-i-provide">What I provide</a> •
  <a href="#how-i-work">How I work</a> •
  <a href="#things-you-can-say">Things you can say</a> •
  <a href="#update-history">Update history</a> •
  <a href="README_kr.md">한국어</a>
</p>

written by Ungbin_Oh · created 2026-09-27 · updated 2026-10-06

---

### Record everything. Track everything. Lose nothing.

Juggling five projects at once? Alfred keeps every one of them on track —
what you did, what you decided, and **why** — so you can switch freely and pick up exactly where you left off.

- 🎩 **Open a session, see every project** — status, last touched, what's next, in one table
- 📝 **Every decision, with its reason** — written down as you work, not reconstructed later
- 🧭 **You decide. Alfred organizes.** — no unasked suggestions, nothing runs without your OK

Your multitasking, finally under control.

## Install

**Claude Code**
```
claude plugin marketplace add ungbin-oh/alfred
claude plugin install alfred@alfred
mkdir ~/ALFRED && cd ~/ALFRED && claude
# in the session: /alfred-init  → then reopen Claude Code
```

**Codex**
```
codex plugin marketplace add ungbin-oh/alfred
codex plugin add alfred-codex@alfred
mkdir ~/ALFRED && cd ~/ALFRED && codex --enable default_mode_request_user_input
# trust the hooks when asked, then: $alfred-init  → then reopen Codex
```

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
claude plugin marketplace update alfred && claude plugin update alfred@alfred      # Claude Code
codex plugin marketplace upgrade alfred && codex plugin add alfred-codex@alfred    # Codex
```

Your logs and settings stay as they are.

## Dismissing me

```
claude plugin uninstall alfred@alfred      # Claude Code
codex plugin remove alfred-codex@alfred    # Codex
```

Your logs and notes stay — they're yours. If you turned on the statusline badge, remove `statusLine` from `~/.claude/settings.json`.

## Korean translation

The rules and skills have one English source (`alfred-claude/`; `alfred-codex/` carries the same rules). A Korean translation for readers lives in [`docs/ko/`](docs/ko/); Alfred itself doesn't read it.

## Requirements

- Claude Code (a version with plugin support), or Codex CLI with plugins (checked with 0.160.0)
- macOS or Linux (the hooks are bash scripts. Not yet tested on Windows)

## License

[MIT](LICENSE) © 2026 Ungbin Oh

## Update history

What changed in each version is in [CHANGELOG.md](CHANGELOG.md). Both plugins share one version number; each change is tagged [Claude], [Codex] or [Both]. Latest: **0.1.10** (2026-10-06) — bug fix (Windows): hooks no longer hang for 5 seconds outside an Alfred workspace. Before that, **0.1.9** — bug fix: `alfred-init` confirms through the question window again, with a short summary inside the question. Before that, **0.1.8** — bug fix (Codex): Codex's own `/init` no longer touches an Alfred workspace. Before that, **0.1.7** — bug fix: `alfred-init` shows the file list in chat instead of under a question window. Before that, **0.1.6** — the repository splits into `alfred-claude/` and `alfred-codex/`, and Codex gets its own plugin. Before that, **0.1.5** — rules rewritten in plainer sentences, boot asks about yesterday's To do, decision.md leaves "what counts as a judgment" to you, personal details removed.

- Status: **v0.1.9** — tested on macOS in Claude Code and Codex. Linux and Windows not yet tested
