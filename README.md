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

This is the recommended install path for "works everywhere by default".

## Install With Codex Skill Installer

If you only want the skill, install:

Ask Codex to install `Yice-AI/codex-token-discipline`, path `skills/codex-token-discipline`, using the built-in `skill-installer`.

The one-line installer is recommended because it also installs `codex-token-report` and writes global token-discipline defaults to `~/.codex/AGENTS.md`.

## Skill vs Global Defaults

Installing a Codex skill and installing global defaults are related, but they are not the same thing.

A skill is like a manual Codex can open when the current request matches the skill description. For example, if the user asks "why is this session expensive?" or "show token savings", Codex can load this skill and follow its report workflow.

Global `AGENTS.md` instructions are default rules Codex sees at the start of new conversations. They are the right place for always-on habits such as "use RTK for supported commands", "prefer narrow reads", and "avoid full-page screenshots unless needed".

That is why this repository ships both:

- `skills/codex-token-discipline/SKILL.md` for token-saving diagnosis and workflows.
- `scripts/install.sh` to install the skill, install `codex-token-report`, and write global defaults into `~/.codex/AGENTS.md`.

If you install only the skill, it is useful when triggered. If you run the one-line installer, new Codex conversations get the token-discipline rules by default.

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

Use `codex-token-report` to answer:

- How many tokens did Codex use recently?
- Which conversations are most expensive?
- How many tokens did RTK explicitly save?
- Are screenshots/base64 images dominating the session?
- Is the current project better or worse than recent baseline?

## Existing Installations

If you already have token-discipline rules in `~/.codex/AGENTS.md`, you usually do not need to uninstall this skill.

The skill and global rules are compatible:

- The skill is loaded only for relevant token-saving/reporting requests.
- The global rules keep everyday development sessions efficient.
- The installer writes a marked block between `<!-- codex-token-discipline:start -->` and `<!-- codex-token-discipline:end -->`, so rerunning it updates that block instead of appending endless duplicates.

If you previously wrote your own global rules and want full control, either keep your existing `AGENTS.md` and install only the skill, or run the installer and then edit the marked block.

## Notes

- RTK savings are exact only for commands that went through RTK.
- Serena or other semantic tools do not expose exact saved-token counters; their value is inferred from fewer broad reads and lower session trends.
- Images and screenshots can dominate token use. Use cropped screenshots or DOM checks when possible.
- Old conversations may not reload new skills/global instructions reliably. Start a new conversation after installation for the cleanest result.
