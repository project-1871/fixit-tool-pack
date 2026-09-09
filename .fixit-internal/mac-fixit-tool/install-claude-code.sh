#!/usr/bin/env bash
# Installs Claude Code (and Homebrew + Node.js if needed) on a Mac.
# Part of the mac-fixit-tool kit.

set -euo pipefail

step() { echo -e "\n==> $*"; }
ok()   { echo "    OK: $*"; }
warn() { echo "    WARN: $*"; }

step "Checking for Homebrew"
if command -v brew >/dev/null 2>&1; then
    ok "Homebrew already installed: $(brew --version | head -1)"
else
    step "Installing Homebrew (official script)"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Apple Silicon Homebrew installs to /opt/homebrew; Intel to /usr/local.
    # The installer prints the exact eval line to add, but do it here too so
    # this same script session can immediately use brew.
    if [ -x /opt/homebrew/bin/brew ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [ -x /usr/local/bin/brew ]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi

    if command -v brew >/dev/null 2>&1; then
        ok "Homebrew installed: $(brew --version | head -1)"
    else
        echo "ERROR: Homebrew install finished but 'brew' isn't on PATH in this shell." >&2
        echo "Open a new terminal and re-run this script." >&2
        exit 1
    fi
fi

step "Checking for Node.js"
if command -v node >/dev/null 2>&1; then
    ok "Node.js already installed: $(node -v)"
else
    step "Installing Node.js via Homebrew"
    brew install node
fi

step "Installing Claude Code via npm"
npm install -g @anthropic-ai/claude-code

step "Verifying install"
if command -v claude >/dev/null 2>&1; then
    claude --version
    ok "Claude Code installed."
else
    warn "npm reported success but 'claude' isn't on PATH in this shell yet."
    warn "Open a new terminal and run: claude --version"
fi

cat <<'EOF'

Next steps:
  1. cd into this mac-fixit-tool folder
  2. Run: claude
  3. First run opens a browser to log in with your Claude account (Pro/Max
     subscription covers usage — no separate API key needed).
  4. Claude will read CLAUDE.md in this folder and act as the fixit assistant.
EOF
