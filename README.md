<p align="center">
  <img src=".fixit-internal/icon/8cat.png" alt="8cat logo" width="128" height="128">
</p>

<h1 align="center">8cat — PC Fixit Toolkit</h1>

<p align="center">
  A portable, all-free PC diagnostic/repair kit for Windows, macOS, and Linux,<br>
  with Claude Code as the on-machine diagnostic assistant — under 200KB, one file.
</p>

---

## What this is

One file — **`8cat.html`** — that you open in any browser, on any OS.
Pick your platform from the menu, and it hands you the exact copy-paste
terminal commands for that machine: install Claude Code, install a full
set of free diagnostic tools, launch the assistant (already primed for
the job), and a cleanup command to uninstall everything when you're done.

No server, no Node.js required just to view it, nothing to install
first. The page reads its own file location to build correct absolute
paths, so it works no matter what drive letter or folder it ends up in.
It never executes anything on its own — every button just puts text on
your clipboard.

## Quick start

1. Clone or download this repo.
2. Open `8cat.html` in a browser.
3. Pick Windows, macOS, or Linux.
4. Copy each command into your own terminal, in order.

Carry it on a USB stick to work on other machines — that's what it's
built for.

## What's inside

| Path | Purpose |
|---|---|
| `8cat.html` | The entire interface. Static, self-contained, no dependencies. |
| `.fixit-internal/windows-fixit-tool/` | Windows kit: install scripts, tool manifest, Claude operating rules. |
| `.fixit-internal/mac-fixit-tool/` | Same, for macOS. |
| `.fixit-internal/linux-fixit-tool/` | Same, for Linux (auto-detects apt/dnf/pacman/zypper). |
| `.fixit-internal/README.md` | The detailed technical README — architecture, design decisions, platform gotchas. |

Each platform folder has:
- **`tools.json`** — the toolbox manifest: every free diagnostic tool for
  that OS, what it's for, how to install it, and its real license (a few
  "free" tools are personal-use-only under their EULA — flagged there).
- **`CLAUDE.md`** — the standing rules Claude reads automatically: role,
  safety rules (never run anything destructive without asking), and a
  diagnostic workflow.
- **`PROMPT.md`** — the opening message that gets Claude straight into
  the job (checking the distro on Linux, the chip on Mac, etc.) instead
  of sitting idle.

## Cost

Everything here is free. `tools.json` flags the handful of tools that are
free for personal use only, not unrestricted — that's a property of
those tools' own EULAs, not this kit.

## Platform notes

- **Apple Silicon Macs can't boot rescue USB media at all** — no Boot
  Camp, no arbitrary ISO boot. See `mac-fixit-tool/CLAUDE.md` for what
  actually works instead (Recovery Mode, Apple Diagnostics, DFU restore).
- **Linux package names vary by distro** — the page includes a separate
  cleanup command per package manager (apt/dnf/pacman/zypper); pick the
  one matching the machine you're on.
- **A few Windows freeware tools are personal-use-only** under their
  EULA (e.g. HWiNFO) — flagged in `windows-fixit-tool/tools.json`.

See `.fixit-internal/README.md` for the full technical writeup, including
why this is a static page instead of a native app per OS.
