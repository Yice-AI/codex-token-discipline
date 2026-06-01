#!/usr/bin/env bash
set -euo pipefail

REPO="${CODEX_TOKEN_DISCIPLINE_REPO:-Yice-AI/codex-token-discipline}"
REF="${CODEX_TOKEN_DISCIPLINE_REF:-main}"
CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
MAIN_SKILL_DIR="$CODEX_HOME/skills/codex-token-discipline"
REPORT_SKILL_DIR="$CODEX_HOME/skills/codex-token-report"
CAVEMAN_SKILL_DIR="$CODEX_HOME/skills/caveman"
BIN_DIR="$HOME/.local/bin"
RAW_BASE="https://raw.githubusercontent.com/$REPO/$REF"
SKIP_DEPS="${CODEX_TOKEN_DISCIPLINE_SKIP_DEPS:-0}"

export PATH="$BIN_DIR:$HOME/.local/bin:$HOME/.cargo/bin:/opt/homebrew/bin:/usr/local/bin:$PATH"

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

install_rtk() {
  if command -v rtk >/dev/null 2>&1 && rtk gain >/dev/null 2>&1; then
    echo "RTK already installed: $(rtk --version 2>/dev/null || echo detected)"
    return 0
  fi

  if command -v rtk >/dev/null 2>&1 && ! rtk gain >/dev/null 2>&1; then
    echo "Found an rtk command, but it does not support 'rtk gain'. It may be a different project named rtk." >&2
    echo "Skipping RTK auto-install to avoid overwriting an existing command." >&2
    return 0
  fi

  echo "Installing RTK..."
  curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/master/install.sh | sh

  if command -v rtk >/dev/null 2>&1 && rtk gain >/dev/null 2>&1; then
    echo "RTK installed: $(rtk --version 2>/dev/null || echo detected)"
  else
    echo "RTK installation did not put 'rtk' on PATH. Add the install location to PATH, then verify with: rtk gain" >&2
  fi
}

install_uv() {
  if command -v uv >/dev/null 2>&1; then
    return 0
  fi

  echo "Installing uv for Serena..."
  if command -v brew >/dev/null 2>&1; then
    brew install uv
  else
    curl -LsSf https://astral.sh/uv/install.sh | sh
    export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"
  fi
}

install_serena() {
  if command -v serena >/dev/null 2>&1; then
    echo "Serena already installed: $(serena --version 2>/dev/null || echo detected)"
  else
    install_uv
    echo "Installing Serena..."
    uv tool install -p 3.13 serena-agent || uv tool install serena-agent
  fi

  local serena_cmd
  serena_cmd="$(command -v serena || true)"
  if [[ -z "$serena_cmd" && -x "$HOME/.local/bin/serena" ]]; then
    serena_cmd="$HOME/.local/bin/serena"
  fi

  if [[ -z "$serena_cmd" ]]; then
    echo "Serena installed, but 'serena' was not found on PATH. Add ~/.local/bin to PATH and configure MCP manually." >&2
    return 0
  fi

  local config_file="$CODEX_HOME/config.toml"
  touch "$config_file"

  if grep -q '^[[:space:]]*\[mcp_servers\.serena\]' "$config_file"; then
    echo "Serena MCP already configured in $config_file"
    return 0
  fi

  cat >> "$config_file" <<EOF

[mcp_servers.serena]
command = "$serena_cmd"
args = ["start-mcp-server", "--context=codex", "--project-from-cwd"]
EOF

  echo "Serena MCP configured in $config_file"
}

need curl

mkdir -p "$MAIN_SKILL_DIR/scripts" "$REPORT_SKILL_DIR" "$CAVEMAN_SKILL_DIR" "$BIN_DIR" "$CODEX_HOME"

if [[ "$SKIP_DEPS" != "1" ]]; then
  install_rtk
  install_serena
else
  echo "Skipping dependency installation because CODEX_TOKEN_DISCIPLINE_SKIP_DEPS=1"
fi

download "skills/codex-token-discipline/SKILL.md" > "$MAIN_SKILL_DIR/SKILL.md"
download "skills/codex-token-discipline/scripts/codex-token-report" > "$MAIN_SKILL_DIR/scripts/codex-token-report"
download "skills/codex-token-report/SKILL.md" > "$REPORT_SKILL_DIR/SKILL.md"
download "skills/caveman/SKILL.md" > "$CAVEMAN_SKILL_DIR/SKILL.md"
install -m 0755 "$MAIN_SKILL_DIR/scripts/codex-token-report" "$BIN_DIR/codex-token-report"

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
- Keep progress updates and final replies concise while preserving decisions, changed files, verification, and blockers. Use compressed wording for routine updates.
<!-- codex-token-discipline:end -->
EOF

mv "$tmp_file" "$AGENTS_FILE"

echo "Installed Codex Token Discipline."
echo "Main skill: $MAIN_SKILL_DIR"
echo "Report skill: $REPORT_SKILL_DIR"
echo "Caveman skill: $CAVEMAN_SKILL_DIR"
echo "Report command: $BIN_DIR/codex-token-report"
echo "Global instructions: $AGENTS_FILE"
echo
if command -v rtk >/dev/null 2>&1; then
  echo "RTK detected: $(rtk --version 2>/dev/null || echo yes)"
else
  echo "RTK not detected. The rules still help, but RTK command savings require RTK."
fi
if command -v serena >/dev/null 2>&1; then
  echo "Serena detected: $(serena --version 2>/dev/null || echo yes)"
else
  echo "Serena not detected. Semantic lookup savings require Serena MCP or another semantic tool."
fi
echo "Restart Codex to load the new skill and global instructions."
