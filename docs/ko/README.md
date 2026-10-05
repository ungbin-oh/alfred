# 한국어 번역본

written by Ungbin_Oh · created 2026-09-27 · updated 2026-10-05

Alfred 의 규약·스킬 정본은 영어 한 벌이다. 여기는 **사람이 읽는 한국어 번역본**이고 Alfred 는 읽지 않는다.
한국어 워크스페이스에서 Alfred 가 한국어로 말하는 것은 이 파일들이 아니라 규약의 언어 절 덕분이다.

| 번역본 | 정본 |
|---|---|
| `core.md` | `alfred-claude/rules/core.md` (`alfred-codex/rules/core.md` 도 같은 사본) |
| `skills/alfred-init.md` | `alfred-claude/skills/alfred-init/SKILL.md` |
| `skills/alfred-init-codex.md` | `alfred-codex/skills/alfred-init/SKILL.md` — Claude 판과 다른 점만 |
| `skills/manual-mode.md` | `alfred-claude/skills/manual-mode/SKILL.md` (Codex 판도 같음) |
| `hooks/manual-mode-rules.txt` | `alfred-claude/hooks/manual-mode.sh` 의 주입 문구 (Codex 판도 같음) |
| `CHANGELOG.md` | 루트 `CHANGELOG.md` |

**관리 규칙** — 정본을 고치는 커밋에서 번역본도 같이 고친다. 번역본만 따로 고치지 않는다.

영어로 옮기기 전 원본(한국어가 정본이던 v0.1.2)은 태그 `v0.1.2-ko` 에 있다.
사용자 파일이 되는 템플릿(`CLAUDE.md` · Codex 는 `AGENTS.md`, daily, `Archive/README.md`)은 번역본이 아니라 각 플러그인의 `skills/alfred-init/templates/ko/` 에 실물로 있다.
Claude Code 워크스페이스의 `.alfred/rules.md` 는 영어 정본 `alfred-claude/rules/core.md` 의 복사본이다 (번역본이 아니다). Codex 는 이 복사본 없이 훅이 규약을 직접 넣는다.
