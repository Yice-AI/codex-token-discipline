---
name: codex-token-discipline
description: Reduces Codex token waste during software development using RTK-aware commands, semantic code navigation, narrow context reads, handoff summaries, and local token reports. Use when the user asks to save tokens, reduce Codex cost, inspect token usage, diagnose expensive sessions, install token-saving defaults, or keep coding quality high while using fewer tokens.
---

# Codex Token Discipline

## Default Behavior

When this skill is active, preserve engineering quality while aggressively reducing avoidable context.

- Prefer RTK-wrapped commands when RTK exists: `rtk git`, `rtk grep`, `rtk npm`, `rtk npx`, `rtk pytest`, `rtk cargo`, `rtk tsc`.
- Prefer semantic lookup/editing tools before broad file reads.
- Use narrow reads: line ranges, symbols, targeted `rg`, `jq` keys, focused logs.
- Avoid reading generated output, build artifacts, large JSON, lockfiles, screenshots, or old conversations unless required.
- Never print raw Codex rollout/session JSONL, archived sessions, shell snapshots, or encrypted reasoning. These files often contain entire system/developer prompts on one line and can instantly consume the context window.
- For session/token investigations, use `codex-token-report --session <thread-id>` or a local summarizing script that emits counts and small excerpts only. Do not use `cat`, `sed`, `head`, `tail`, or broad `grep` directly on session JSONL.
- For UI work, prefer DOM checks and small cropped screenshots over full-page images.
- For long-running projects, create or update a short handoff/context note instead of asking future sessions to reread old chats.
- Keep progress updates and final answers compact but include decisions, changed files, verification, and blockers.

## Workflows

### New Project Setup

1. Check for `AGENTS.md` and existing project conventions.
2. Add a short token-discipline block only if the project lacks one.
3. Recommend a durable `CONTEXT.md` or handoff file for cross-session continuity.
4. Use `codex-token-report --project` to establish the baseline.

### During Coding

1. Search narrowly first.
2. Read only files or symbols needed for the change.
3. Use RTK for supported shell commands.
4. Run focused verification.
5. Summarize only what changed and what was tested.

### Expensive Session Diagnosis

Run:

```bash
codex-token-report --project --days 7 --top 10 --large-events
```

For a specific expensive or broken thread, run the safe session audit:

```bash
codex-token-report --session 019ec265-0f07-7923-a09b-cabb3aac9481
```

This intentionally reports only metadata, token counters, risky command patterns, and largest event sizes. It must not dump raw JSONL content.

Interpretation:

- High RTK savings means command output compression is working.
- High image/base64 counts means screenshots or visual inputs are dominating.
- High thread tokens with low RTK/Serena usage means broad context reads or chat carryover are likely.
- Any direct raw read of rollout/session JSONL is a skill failure. Replace it with `codex-token-report --session <thread-id>` and add a durable handoff instead of rereading the log.
- Repeated "read old conversation" tasks should become handoff summaries.

## Install / Report Script

If the report command is installed:

```bash
codex-token-report
codex-token-report --project
codex-token-report --large-events
```

If missing, ask the user to run the repository installer or install `scripts/codex-token-report` into `~/.local/bin`.
