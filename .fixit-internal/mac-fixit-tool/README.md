# mac-fixit-tool

A portable kit that turns a Mac into something Claude Code can diagnose and
repair. Uses Homebrew for everything scriptable.

## What's in here

| File | Purpose |
|---|---|
| `install-claude-code.sh` | Installs Homebrew (if missing) + Node.js + the Claude Code CLI. |
| `install-tools.sh` | Installs every free diagnostic tool in `tools.json` via Homebrew (formula or cask). |
| `tools.json` | The toolbox manifest — every tool, what it's for, how to install it, its license, and the built-in Boot & Recovery options (important: these differ sharply between Apple Silicon and Intel Macs). |
| `CLAUDE.md` | Instructions Claude Code reads automatically in this folder — defines its role as the fixit assistant, safety rules, and diagnostic workflow. |
| `PROMPT.md` | The opening message fed to Claude on launch (see below) — gets it straight into checking Apple Silicon vs. Intel and diagnosing, instead of waiting for the first question. |

## Important: Apple Silicon vs. Intel

Ventoy, Rescuezilla, and balenaEtcher-created boot USBs — the classic
"boot a rescue environment from a flash drive" toolkit — **only work on
Intel Macs**, and even there only after Startup Security Utility is set to
allow it. **Apple Silicon Macs (M1/M2/M3/M4) cannot boot any of that** —
the only rescue paths are Apple's own Recovery Mode, Apple Diagnostics, and
(for a Mac that won't boot at all) a DFU restore via Apple Configurator 2
and a second Mac. `tools.json` and `CLAUDE.md` both spell this out so
Claude checks the chip before proposing a fix that won't work.

## Setup on the target Mac

1. Copy this folder to the Mac (USB stick, AirDrop, git clone, whatever's handy).
2. Open Terminal, `cd` into the folder.
3. `chmod +x install-claude-code.sh install-tools.sh` (once, if permissions didn't survive the copy).
4. `./install-claude-code.sh`
5. `./install-tools.sh`
6. Run `claude "$(cat PROMPT.md)"` in this folder — this feeds `PROMPT.md`
   in as Claude's opening message so it starts already primed for the job
   (check Apple Silicon vs. Intel, greet the technician, diagnose
   methodically) instead of sitting idle waiting for the first question.
   Plain `claude` still works fine too, just without that kickoff. First
   run opens a browser to log in with your Claude account — your existing
   Pro/Max subscription covers usage, no separate API key needed.

Claude will pick up `CLAUDE.md` automatically and know what tools it has
and how it's expected to work; `PROMPT.md` is the one-time nudge to act on
it immediately rather than wait.

## Requirements

- macOS with Terminal access.
- Internet connection (Homebrew, Node.js, Claude Code, and most tool
  installs all need it).
- Xcode Command Line Tools (Homebrew's installer will prompt for these
  automatically if missing).

## Cost

Everything in `tools.json` is free — nearly all open source, one
freeware-with-a-caveat (Malwarebytes, flagged in `tools.json`). Claude
Code itself runs on your existing Claude subscription — no separate
per-tool cost here.

## Updating the toolbox

Add or remove entries in `tools.json` (same shape: `name`, `category`,
`purpose`, `install` = `brew`/`brew-cask`/`manual`/`builtin`, `brewId` or
`manualUrl`, `license`). Re-run `install-tools.sh` — it's safe to run
again, Homebrew no-ops on already-installed packages.
