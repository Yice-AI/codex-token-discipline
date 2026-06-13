# Codex Token Discipline

A Codex skill plus installer for reducing token waste during high-intensity software development without intentionally lowering coding quality.

It combines four practical habits:

- RTK-wrapped shell commands where available.
- Semantic code navigation before broad file reads.
- Narrow context reads and small verification outputs.
- Local token reports that identify expensive sessions, screenshots, and tool-output spikes.

The installer bundles three skills:

- `codex-token-discipline`: default code-task token discipline plus token-saving workflow and diagnosis.
- `codex-token-report`: direct trigger for token usage and savings reports.
- `caveman`: optional compressed response mode for shorter wording.

## One-line Install

```bash
curl -fsSL https://raw.githubusercontent.com/Yice-AI/codex-token-discipline/main/scripts/install.sh | bash
```

Restart Codex after installation so new skills and global instructions are loaded.

This is the recommended install path for "works everywhere by default".

## Install With Codex Skill Installer

If you only want the skills, install:

Ask Codex to install `Yice-AI/codex-token-discipline`, paths `skills/codex-token-discipline`, `skills/codex-token-report`, and `skills/caveman`, using the built-in `skill-installer`.

The one-line installer is recommended because it also installs `codex-token-report` and writes global token-discipline defaults to `~/.codex/AGENTS.md`.

By default, the one-line installer also attempts to install and configure the supporting tools used by this workflow:

- RTK, for compressed shell-command output and exact `rtk gain` savings.
- Serena, for semantic code lookup/editing through Codex MCP.

To skip dependency installation and only install this repository's files:

```bash
CODEX_TOKEN_DISCIPLINE_SKIP_DEPS=1 bash -c "$(curl -fsSL https://raw.githubusercontent.com/Yice-AI/codex-token-discipline/main/scripts/install.sh)"
```

## Skill vs Global Defaults

Installing a Codex skill and installing global defaults are related, but they are not the same thing.

A skill is like a manual Codex can open when the current request matches the skill description. This skill intentionally matches ordinary software-development tasks too, because token discipline should apply while reading, searching, editing, debugging, reviewing, building, and testing code, not only after the user asks about cost.

Global `AGENTS.md` instructions are default rules Codex sees at the start of new conversations. They are the right place for always-on habits such as "use RTK for supported commands", "prefer narrow reads", and "avoid full-page screenshots unless needed".

That is why this repository ships both:

- `skills/codex-token-discipline/SKILL.md` for token-saving diagnosis and workflows.
- `scripts/install.sh` to install the skill, install `codex-token-report`, and write global defaults into `~/.codex/AGENTS.md`.

If you install only the skill, it is useful when triggered. If you run the one-line installer, new Codex conversations get the token-discipline rules by default.

## What It Installs

- `~/.codex/skills/codex-token-discipline/SKILL.md`
- `~/.codex/skills/codex-token-report/SKILL.md`
- `~/.codex/skills/caveman/SKILL.md`
- `~/.local/bin/codex-token-report`
- A marked `Global Token Discipline` block in `~/.codex/AGENTS.md`
- RTK, if it is missing and can be installed.
- Serena, if it is missing and can be installed.
- Serena MCP config in `~/.codex/config.toml`, if it is not already configured.

The installer does not upload local data and does not modify project repositories.

## Usage

```bash
codex-token-report
codex-token-report --project
codex-token-report --days 14 --top 20 --large-events
codex-token-report --session 019ec265-0f07-7923-a09b-cabb3aac9481
```

Use `codex-token-report` to answer:

- How many tokens did Codex use recently?
- Which conversations are most expensive?
- How many tokens did RTK explicitly save?
- Are screenshots/base64 images dominating the session?
- Is the current project better or worse than recent baseline?
- Which commands or events made one specific session expensive, without dumping raw rollout JSONL?

After installation, verify:

```bash
rtk gain
codex-token-report --project --large-events
```

Restart Codex and start a new conversation before judging whether global behavior changed.

## Existing Installations

If you already have token-discipline rules in `~/.codex/AGENTS.md`, you usually do not need to uninstall this skill.

The skill and global rules are compatible:

- The skill is loaded only for relevant token-saving/reporting requests.
- The global rules keep everyday development sessions efficient.
- If the installer finds its marked block between `<!-- codex-token-discipline:start -->` and `<!-- codex-token-discipline:end -->`, rerunning it updates that block.
- If the installer sees existing token-discipline-like rules but no marked block, it leaves them unchanged to avoid duplicates.

If you previously wrote your own global rules and want full control, either keep your existing `AGENTS.md` and run the installer normally, or force the managed block:

```bash
CODEX_TOKEN_DISCIPLINE_FORCE_AGENTS=1 bash -c "$(curl -fsSL https://raw.githubusercontent.com/Yice-AI/codex-token-discipline/main/scripts/install.sh)"
```

## Notes

- RTK savings are exact only for commands that went through RTK.
- Serena or other semantic tools do not expose exact saved-token counters; their value is inferred from fewer broad reads and lower session trends.
- Images and screenshots can dominate token use. Use cropped screenshots or DOM checks when possible.
- Codex rollout/session JSONL can contain huge single-line system prompts and encrypted reasoning. Do not inspect it with raw `cat`, `sed`, `head`, or `tail`; use `codex-token-report --session <thread-id>`.
- Old conversations may not reload new skills/global instructions reliably. Start a new conversation after installation for the cleanest result.
