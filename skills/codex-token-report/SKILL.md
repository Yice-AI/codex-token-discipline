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
```

Interpretation:

- RTK savings are exact for commands that went through RTK.
- Codex thread tokens come from the local Codex state DB.
- `--large-events` scans recent session JSONL logs for large screenshots/base64 events.
- Serena and other semantic tools usually do not expose exact saved-token counters; infer value from lower broad-read usage and session trends.

If the command is missing, ask the user to run the repository installer:

```bash
curl -fsSL https://raw.githubusercontent.com/Yice-AI/codex-token-discipline/main/scripts/install.sh | bash
```
