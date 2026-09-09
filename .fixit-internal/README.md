# PC Fixit Toolkit

A portable, all-free PC diagnostic/repair kit for Windows, macOS, and
Linux, with Claude Code as the actual diagnostic assistant. Built for the
PC-parts-reselling / refurb workflow — carry it on a USB stick to any
machine.

## Quick start — one file, any OS

This file lives inside `.fixit-internal/` — a deliberately hidden folder
(dot-prefix on Linux/macOS, the real exFAT "hidden" attribute on Windows).
It isn't meant to be opened directly.

**Open `PC Fixit Toolkit.html`** — one level up, at the drive/folder root —
in any browser, on any OS. That's the entire toolkit's interface: pick
your OS from the menu, then copy-paste the commands it shows you into
your own terminal.

It's a single static HTML file — no server, no Node.js required just to
view it, nothing to install first. It works by reading its own file
location (browsers expose the real path for a locally-opened file) to
build correct absolute paths into whichever `cd` command it shows you, so
it works regardless of what drive letter or mount point this folder ends
up at on a given machine. It never executes anything itself — every
button just puts text on your clipboard.

## Why a static page instead of a native app per OS

Earlier versions of this kit tried building a real native launcher per OS
(a `.app` bundle, a `.lnk` shortcut, a `.desktop` file) so there'd be one
icon to double-click per platform. That works, but fighting three
incompatible OS-native formats for something that only ever displays
copy-paste text was solving the wrong problem — a plain `.html` file
already opens correctly in a browser on Windows, macOS, and Linux with
zero special handling, and needs no per-OS icon-trust dance (Gatekeeper,
GNOME's launcher trust prompt, etc.). One file, works everywhere it's
opened, and is simpler to reason about.

## What's in each platform folder

| Platform | Folder | Bootstrap script | Tools installer |
|---|---|---|---|
| Windows | `windows-fixit-tool/` | `install-claude-code.ps1` | `install-tools.ps1` |
| macOS | `mac-fixit-tool/` | `install-claude-code.sh` | `install-tools.sh` |
| Linux | `linux-fixit-tool/` | `install-claude-code.sh` | `install-tools.sh` |

Each folder also has `tools.json` (the toolbox manifest — every tool,
what it's for, its license), `CLAUDE.md` (what makes Claude act as the
fixit assistant when run from that folder: safety rules, diagnostic
workflow, logging), and `PROMPT.md` (the opening message that gets it
started — see below). `PC Fixit Toolkit.html` reads none of these files
at runtime (everything it needs is baked into the page itself) — they're
what the copy-pasted commands actually invoke on the target machine.

## What's on the page

Same retro terminal look as before (green phosphor, scanlines, glitch
effects, the animated logo) — now purely decorative, since there's no
backend left to draw real system data from. Boot sequence plays once per
browser tab, skip anytime with any key.

- **OS menu** — pick Windows, macOS, or Linux.
- **Step 1–3** — Install Claude Code (primed with `PROMPT.md`), install
  diagnostic tools, launch the fixit assistant. Each is a copy-paste box
  with a "Copy Command" button.
- **Cleanup** — one more command (or four, on Linux — one per package
  manager, since that varies by distro) that uninstalls everything
  `tools.json` installed plus Claude Code itself, for handing a client's
  machine back clean. Deliberately leaves Node.js alone — it's a shared
  runtime, and there's no way to tell from a static page whether it
  predates the visit.
- **Clipboard log** — a running record of what's been copied.
- **Toolbox reference** — every tool for the selected platform, searchable,
  with license flags. Embedded directly in the page (no fetch — `file://`
  pages can't reliably fetch other local files due to browser CORS
  restrictions), so it reflects whatever `tools.json` looked like when
  this page was last generated, not necessarily this exact instant.

## The launch prompt (`PROMPT.md`)

Each platform folder has a `PROMPT.md` — the opening message fed to Claude
via `claude "$(cat PROMPT.md)"` (or the PowerShell equivalent on Windows)
in the "Launch Fixit Assistant" command. `CLAUDE.md` is the standing
rulebook Claude reads automatically every session; `PROMPT.md` is the
one-time kickoff that gets it acting on those rules immediately —
identify the platform specifics (distro + package manager on Linux, chip
on Mac, Windows version), greet the technician, and start diagnosing —
instead of sitting idle waiting for the first question.

## Cost

Everything here — every tool in every platform's `tools.json`, this page,
Node.js — is free. A few individual tools are flagged
"free-for-personal-use" rather than unrestricted (see each `tools.json`);
that's a property of those specific tools' EULAs, not this kit.

## Platform notes worth knowing before you start

- **Apple Silicon Macs (M1/M2/M3/M4) cannot boot rescue USB media at all**
  — no Boot Camp, no arbitrary ISO boot. `mac-fixit-tool/CLAUDE.md` and
  `tools.json` cover the real recovery paths (Recovery Mode, Apple
  Diagnostics, DFU restore via Apple Configurator 2).
- **Linux package names drift slightly across distros** —
  `linux-fixit-tool/install-tools.sh` detects apt/dnf/pacman/zypper and
  maps names per manager; a failed install is reported so you can search
  for the current name rather than being silently skipped. The cleanup
  command on the page has one variant per package manager for the same
  reason — pick the one matching the machine you're on.
- **A few Windows freeware tools are personal-use-only under their EULA**
  (e.g. HWiNFO) — flagged in `windows-fixit-tool/tools.json` since testing
  PCs for resale may count as commercial use.

## Updating

Each `tools.json` is a flat, documented format — add or remove tools
there and re-run that platform's `install-tools` script (safe to run
again). `PC Fixit Toolkit.html` embeds a snapshot of each `tools.json` and
the uninstall command built from it — after editing a `tools.json`, that
page needs regenerating to match (it won't auto-pick-up the change the
way the old server-backed version did).
