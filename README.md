# Codex Token Discipline

A Codex skill plus installer for reducing token waste during high-intensity software development without intentionally lowering coding quality.

It combines four practical habits:

- RTK-wrapped shell commands where available.
- Semantic code navigation before broad file reads.
- Narrow context reads and small verification outputs.
- Local token reports that identify expensive sessions, screenshots, and tool-output spikes.

## One-line Install

```bash
curl -fsSL https://raw.githubusercontent.com/Yice-AI/codex-token-discipline/main/scripts/install.sh | bash
```

Restart Codex after installation so new skills and global instructions are loaded.

## Install With Codex Skill Installer

If you only want the skill, install:

Ask Codex to install `Yice-AI/codex-token-discipline`, path `skills/codex-token-discipline`, using the built-in `skill-installer`.

The one-line installer is recommended because it also installs `codex-token-report` and writes global token-discipline defaults to `~/.codex/AGENTS.md`.

## What It Installs

- `~/.codex/skills/codex-token-discipline/SKILL.md`
- `~/.local/bin/codex-token-report`
- A marked `Global Token Discipline` block in `~/.codex/AGENTS.md`

The installer does not upload local data and does not modify project repositories.

## Usage

```bash
codex-token-report
codex-token-report --project
codex-token-report --days 14 --top 20 --large-events
```

## Notes

- RTK savings are exact only for commands that went through RTK.
- Serena or other semantic tools do not expose exact saved-token counters; their value is inferred from fewer broad reads and lower session trends.
- Images and screenshots can dominate token use. Use cropped screenshots or DOM checks when possible.
