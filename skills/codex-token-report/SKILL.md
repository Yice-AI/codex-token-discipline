---
name: codex-token-report
description: Summarizes Codex token usage, RTK token savings, high-token conversations, and screenshot/base64-heavy sessions from local telemetry. Use when the user asks to view token usage, token savings, RTK savings, Codex cost trends, expensive sessions, or token reports.
---

# Codex Token Report

Run the local report command instead of manually querying Codex state or RTK logs.

```bash
codex-token-report
codex-token-report --project
codex-token-report --days 14 --top 20 --large-events
codex-token-report --session 019ec265-0f07-7923-a09b-cabb3aac9481
```

Interpretation:

- RTK savings are exact for commands that went through RTK.
- Codex thread tokens come from the local Codex state DB.
- `--large-events` scans recent session JSONL logs for large screenshots/base64 events.
- `--session <thread-id>` safely audits a specific session without printing raw JSONL.
- Serena and other semantic tools usually do not expose exact saved-token counters; infer value from lower broad-read usage and session trends.

Safety:

- Do not use `cat`, `sed`, `head`, `tail`, or broad `grep` directly on Codex session JSONL, archived sessions, shell snapshots, or encrypted reasoning.
- If a user asks why one session was expensive, run `codex-token-report --session <thread-id>` first and report the summarized findings.

If the command is missing, ask the user to run the repository installer:

```bash
curl -fsSL https://raw.githubusercontent.com/Yice-AI/codex-token-discipline/main/scripts/install.sh | bash
```
