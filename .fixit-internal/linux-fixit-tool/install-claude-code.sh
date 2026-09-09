#!/usr/bin/env bash
# Installs Claude Code (and Node.js if needed) on a Linux machine.
# Part of the linux-fixit-tool kit.
#
# Uses nvm rather than the distro package manager for Node.js: it needs no
# sudo, works identically across every distro, and avoids the "distro's
# packaged Node is years old" problem that Claude Code's minimum-version
# requirement runs into on Debian/Ubuntu LTS releases.

set -euo pipefail

NVM_VERSION="v0.40.1"  # check https://github.com/nvm-sh/nvm/releases for a newer tag before running

step() { echo -e "\n==> $*"; }
ok()   { echo "    OK: $*"; }
warn() { echo "    WARN: $*"; }

step "Checking for Node.js"
if command -v node >/dev/null 2>&1; then
    ok "Node.js already installed: $(node -v)"
else
    step "Node.js not found — installing via nvm (no sudo required)"
    curl -fsSL "https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh" | bash
    export NVM_DIR="$HOME/.nvm"
    # shellcheck source=/dev/null
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    nvm install --lts
    if command -v node >/dev/null 2>&1; then
        ok "Node.js installed: $(node -v)"
    else
        echo "ERROR: nvm install finished but 'node' isn't available in this shell." >&2
        echo "Open a new terminal (or run: source ~/.nvm/nvm.sh) and re-run this script." >&2
        exit 1
    fi
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
  1. cd into this linux-fixit-tool folder
  2. Run: claude
  3. First run opens a browser to log in with your Claude account (Pro/Max
     subscription covers usage — no separate API key needed).
  4. Claude will read CLAUDE.md in this folder and act as the fixit assistant.
EOF
