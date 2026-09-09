# windows-fixit-tool

A portable kit that turns a Windows PC into something Claude Code can
diagnose and repair. Built on this Linux machine; carry it to the Windows
box on a USB stick.

## What's in here

| File | Purpose |
|---|---|
| `install-claude-code.ps1` | Installs Node.js (if missing) + the Claude Code CLI. |
| `install-tools.ps1` | Installs every free diagnostic tool in `tools.json` via `winget`. |
| `tools.json` | The toolbox manifest — every tool, what it's for, how to install it, and its real license (a few free tools are personal-use-only; flagged there). |
| `CLAUDE.md` | Instructions Claude Code reads automatically in this folder — defines its role as the fixit assistant, safety rules, and diagnostic workflow. |
| `PROMPT.md` | The opening message fed to Claude on launch (see below) — gets it straight into diagnosing instead of waiting for the first question. |

## Setup on the Windows machine

1. Copy this whole folder to the Windows PC (USB stick, network share, etc).
2. Open **Windows Terminal** or **PowerShell as Administrator**.
3. `cd` into the folder.
4. If scripts are blocked, run each with:
   ```powershell
   powershell -ExecutionPolicy Bypass -File install-claude-code.ps1
   powershell -ExecutionPolicy Bypass -File install-tools.ps1
   ```
   (or normally, if your execution policy already allows local scripts).
5. Run `claude "$(Get-Content -Raw PROMPT.md)"` in this folder — this feeds
   `PROMPT.md` in as Claude's opening message so it starts already primed
   for the job (confirm Windows version, greet the technician, diagnose
   methodically) instead of sitting idle waiting for the first question.
   Plain `claude` still works fine too, just without that kickoff. First
   run opens a browser to log in with your Claude account — your existing
   Pro/Max subscription covers usage, no separate API key needed.

Claude will pick up `CLAUDE.md` automatically and know what tools it has
and how it's expected to work; `PROMPT.md` is the one-time nudge to act on
it immediately rather than wait.

## Requirements

- Windows 10 (2004+) or Windows 11 — needed for `winget` (ships in the box
  on current builds; if missing, get "App Installer" from the Microsoft
  Store).
- Internet connection for the install scripts and for Claude Code itself.

## Cost

Everything in `tools.json` is free to run. `tools.json` calls out the
handful that are free-for-personal-use-only under their EULA (HWiNFO,
similarly-licensed tools) versus fully free/open-source — worth knowing
since these machines may be prepped for resale. Claude Code itself runs on
your existing Claude subscription; there's no separate per-tool cost here.

## Updating the toolbox

Add or remove entries in `tools.json` (same shape: `name`, `category`,
`purpose`, `install` = `winget`/`manual`/`builtin`, `wingetId` or
`manualUrl`, `license`). Re-run `install-tools.ps1` — it's safe to run
again, `winget` no-ops on already-installed packages.
