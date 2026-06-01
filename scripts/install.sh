#!/usr/bin/env bash
set -euo pipefail

REPO="${CODEX_TOKEN_DISCIPLINE_REPO:-Yice-AI/codex-token-discipline}"
REF="${CODEX_TOKEN_DISCIPLINE_REF:-main}"
CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
SKILL_DIR="$CODEX_HOME/skills/codex-token-discipline"
BIN_DIR="$HOME/.local/bin"
RAW_BASE="https://raw.githubusercontent.com/$REPO/$REF"

need() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Missing required command: $1" >&2
    exit 1
  fi
}

download() {
  local path="$1"
  curl -fsSL "$RAW_BASE/$path"
}

need curl

mkdir -p "$SKILL_DIR/scripts" "$BIN_DIR" "$CODEX_HOME"

download "skills/codex-token-discipline/SKILL.md" > "$SKILL_DIR/SKILL.md"
download "skills/codex-token-discipline/scripts/codex-token-report" > "$SKILL_DIR/scripts/codex-token-report"
install -m 0755 "$SKILL_DIR/scripts/codex-token-report" "$BIN_DIR/codex-token-report"

AGENTS_FILE="$CODEX_HOME/AGENTS.md"
touch "$AGENTS_FILE"

tmp_file="$(mktemp)"
awk '
  /<!-- codex-token-discipline:start -->/ {skip=1; next}
  /<!-- codex-token-discipline:end -->/ {skip=0; next}
  skip != 1 {print}
' "$AGENTS_FILE" > "$tmp_file"

cat >> "$tmp_file" <<'EOF'

<!-- codex-token-discipline:start -->
# Global Token Discipline

- Use RTK for supported shell commands when available to reduce tool-output tokens.
- Common rewrites: `git ...` -> `rtk git ...`; `rg ...`/`grep ...` -> `rtk grep ...`; `npm ...` -> `rtk npm ...`; `npx ...` -> `rtk npx ...`; `pytest ...` -> `rtk pytest ...`; `cargo ...` -> `rtk cargo ...`; `tsc ...` -> `rtk tsc ...`; build/test/lint commands -> the matching `rtk` subcommand when available.
- If RTK is unavailable or unsupported for a command, keep output tight with targeted args, `head`/`tail`, or explicit summaries.
- Prefer semantic lookup/editing tools before broad file reads when exploring or modifying code.
- Prefer narrow file ranges, symbol references, focused search results, and structured queries over whole-file or whole-repo dumps.
- Avoid reading generated files, build artifacts, lockfiles, large JSON, screenshots, or old conversation logs unless required.
- For UI work, prefer DOM checks and small cropped screenshots over full-page images.
- For cross-session continuity, use short handoff/context summaries instead of rereading old conversations.
- Keep progress updates and final replies concise while preserving decisions, changed files, verification, and blockers.
<!-- codex-token-discipline:end -->
EOF

mv "$tmp_file" "$AGENTS_FILE"

echo "Installed Codex Token Discipline."
echo "Skill: $SKILL_DIR"
echo "Report command: $BIN_DIR/codex-token-report"
echo "Global instructions: $AGENTS_FILE"
echo
if command -v rtk >/dev/null 2>&1; then
  echo "RTK detected: $(rtk --version 2>/dev/null || echo yes)"
else
  echo "RTK not detected. The rules still help, but RTK command savings require RTK."
fi
echo "Restart Codex to load the new skill and global instructions."
