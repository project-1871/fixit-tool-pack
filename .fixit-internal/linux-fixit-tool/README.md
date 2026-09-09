# linux-fixit-tool

A portable kit that turns a Linux PC into something Claude Code can
diagnose and repair. Works across Debian/Ubuntu, Fedora/RHEL, Arch, and
openSUSE — `install-tools.sh` detects the package manager and adapts.

## What's in here

| File | Purpose |
|---|---|
| `install-claude-code.sh` | Installs Node.js via nvm (if missing) + the Claude Code CLI. |
| `install-tools.sh` | Detects your distro's package manager and installs every free diagnostic tool in `tools.json`. |
| `tools.json` | The toolbox manifest — every tool, what it's for, its package name per distro, and its license (nearly everything here is open source and free for any use). |
| `CLAUDE.md` | Instructions Claude Code reads automatically in this folder — defines its role as the fixit assistant, safety rules, and diagnostic workflow. |
| `PROMPT.md` | The opening message fed to Claude on launch (see below) — gets it straight into distro-detection and troubleshooting mode instead of waiting for the first question. |

## Setup on the target Linux machine

1. Copy this folder to the machine (USB stick, `scp`, git clone, whatever's handy).
2. Open a terminal, `cd` into the folder.
3. `chmod +x install-claude-code.sh install-tools.sh` (once, if permissions didn't survive the copy).
4. `./install-claude-code.sh`
5. `./install-tools.sh`
6. Run `claude "$(cat PROMPT.md)"` in this folder — this feeds `PROMPT.md`
   in as Claude's opening message so it starts already primed for the job
   (identify the distro, greet the technician, diagnose methodically)
   instead of sitting idle waiting for the first question. Plain `claude`
   still works fine too, just without that kickoff. First run opens a
   browser to log in with your Claude account — your existing Pro/Max
   subscription covers usage, no separate API key needed.

Claude will pick up `CLAUDE.md` automatically and know what tools it has
and how it's expected to work; `PROMPT.md` is the one-time nudge to act on
it immediately rather than wait.

## Requirements

- Any Linux distro using apt, dnf, pacman, or zypper.
- `curl` and `bash` (present on virtually every install).
- `sudo` access for `install-tools.sh` (package installs); Node.js itself
  installs without sudo via nvm.
- Internet connection.

## Cost

Everything in `tools.json` is free and open source. Claude Code itself runs
on your existing Claude subscription — no separate per-tool cost here.

## Updating the toolbox

Add or remove entries in `tools.json` (same shape: `name`, `category`,
`purpose`, `install` = `pkg`/`manual`/`builtin`, `pkgApt`/`pkgDnf`/
`pkgPacman`/`pkgZypper` or `manualUrl`, `license`). Re-run
`install-tools.sh` — it's safe to run again.
