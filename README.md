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

Pick your OS, then the tool you use — Claude Code, Codex, or both.

|                  | 🍎 [macOS](#-macos) | 🪟 [Windows](#-windows) |
| ---------------- | ------------------- | ----------------------- |
| Terminal         | Terminal (zsh)      | PowerShell              |
| Before you start | —                   | Git for Windows         |

---

### 🍎 macOS

**Claude Code**

```bash
claude plugin marketplace add ungbin-oh/alfred
claude plugin install alfred@alfred
mkdir ~/ALFRED
cd ~/ALFRED
claude
```

➡️ In the session, type `/alfred-init`. When it finishes, quit and run `claude` again.

**Codex**

```bash
codex plugin marketplace add ungbin-oh/alfred
codex plugin add alfred-codex@alfred
codex features enable default_mode_request_user_input
mkdir ~/ALFRED
cd ~/ALFRED
codex
```

➡️ Trust the hooks when asked, then type `$alfred-init`. When it finishes, quit and run `codex` again.
The `features enable` line is needed only once — it turns on question windows for good.

---

### 🪟 Windows

> [!IMPORTANT]
> Alfred's hooks run on Git Bash, so install **Git for Windows** first.
> Already installed? Running it again is harmless — winget says so, or updates it.
> If `winget` isn't found, download Git from [git-scm.com](https://git-scm.com/download/win) instead.

**Step 1 · Git for Windows**

```powershell
winget install --id Git.Git -e
```

➡️ Close the terminal and open a new one.

**Step 2 · Claude Code**

```powershell
claude plugin marketplace add ungbin-oh/alfred
claude plugin install alfred@alfred
mkdir ~\ALFRED
cd ~\ALFRED
claude
```

➡️ In the session, type `/alfred-init`. When it finishes, quit and run `claude` again.

**Step 2 · Codex**

```powershell
codex plugin marketplace add ungbin-oh/alfred
codex plugin add alfred-codex@alfred
codex features enable default_mode_request_user_input
mkdir ~\ALFRED
cd ~\ALFRED
codex
```

➡️ Trust the hooks when asked, then type `$alfred-init`. When it finishes, quit and run `codex` again.
The `features enable` line is needed only once — it turns on question windows for good.

## What I provide

| What | What it does |
|---|---|
| **Boot briefing** | When you open a session, a table of projects per category — status · last updated · days idle · next action. Active projects idle over 14 days are flagged 🔴 neglected (display only) |
| **Decision log** `log.md` | Not results, but **"why it was decided that way at the time"**. Each entry records who decided (you / me) |
| **Work ledger** `trace/` | Commands, raw errors, hypotheses and why they were ruled out — written down as you work. When you save, I distill it into the log |
| **Decision record** `decision.md` | Only the judgments that set a project's direction — situation, trigger, your thoughts in your words, what you decided, and how it measures against the goal. I interview you to write it, so you can see whether you've strayed from where you started |
| **Open questions** `open.md` | What you haven't decided yet — candidate options and their grounds. Once decided, recorded in the log and listed in the file's Closed table |
| **Incubator** `project-logs/Incubator/` | A place for questions, study notes and stray thoughts that don't belong to any current project. When one turns into real work, launch it as a sub-project there; once it grows, move it to its category |
| **Archive** `Archive/` | Finished things you want to keep — outputs and records — out of the briefing's way. Moved only when you say so |
| **Daily notes** `daily/` | The story of each day and stray thoughts. Say "let's wrap up the day" and I write a timeline from the trace |
| **Question windows** | For short choices I use a multiple-choice window instead of text, so one answer stays per question. Long drafts I confirm with you in chat |
| **Two languages** | English or Korean, chosen at `/alfred-init`. One rulebook either way |
| `/alfred-init` | Sets up the workspace. Every file it creates is yours |
| `/manual-mode lite\|medium\|full` | Manual mode that ties my hands — you type the commands and code yourself |
| `/guide-mode on\|off` | For your first days: a short tour of how I work, then one usage tip now and then (`$guide-mode` in Codex) |
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
│   └── Incubator/            questions and half-ideas; sub-projects before they launch
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

**Claude Code**

```
claude plugin marketplace update alfred
claude plugin update alfred@alfred
```

**Codex**

```
codex plugin marketplace upgrade alfred
codex plugin add alfred-codex@alfred
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

- Claude Code (a version with plugin support), or Codex CLI with plugins (checked with 0.160)
- macOS, Linux or Windows. On Windows, Git for Windows (Git Bash) — the hooks are bash scripts

## License

[MIT](LICENSE) © 2026 Ungbin Oh

## Update history

Both plugins share one version number. Every change is in [CHANGELOG.md](CHANGELOG.md), tagged [Claude], [Codex] or [Both].

| Version | Date | What changed |
|---|---|---|
| **0.3.2** | 2026-10-06 | Bug fix: `alfred-init` puts "restart now" last, in bold, and says guide mode is for after the restart |
| 0.3.1 | 2026-10-06 | Guide mode: `/guide-mode on` gives a short tour and a usage tip now and then; `alfred-init` mentions it at the end |
| 0.3.0 | 2026-10-06 | Incubator: a built-in place for questions, study notes and stray thoughts, where sub-projects start before moving to a category. `alfred-init` always creates it |
| 0.2.3 | 2026-10-06 | Bug fix: the assistant-name question in `alfred-init` always has two options, so English setup no longer skips it |
| 0.2.2 | 2026-10-06 | Claude Code: a new session in an Alfred workspace is named by date |
| 0.2.1 | 2026-10-06 | Codex: `alfred-init` asks the create confirmation and git in chat (Codex won't open a window for them), in bold with exactly what to type |
| 0.2.0 | 2026-10-06 | Windows (Codex): hooks run through Git Bash; Git for Windows is required on Windows; question windows are turned on once at setup |
| 0.1.10 – 0.1.11 | 2026-10-06 | Bug fixes: hooks no longer hang on Windows outside a workspace; Codex question windows |
| 0.1.5 – 0.1.9 | 2026-10-05 | Plainer rules, Codex plugin and repo split, `alfred-init` fixes |

**Status: v0.3.2** — tested on macOS and Windows 11, in Claude Code and Codex (up to 0.2.3). Incubator (0.3.0) and guide mode (0.3.1) not yet tried in a real session. Linux not yet tested.
