<#
.SYNOPSIS
  Installs Claude Code (and its prerequisites) on a Windows machine.

.DESCRIPTION
  Part of the windows-fixit-tool kit. Installs Node.js LTS via winget if needed,
  then installs the Claude Code CLI via npm, then verifies it runs.

.NOTES
  Run from an elevated ("Run as Administrator") PowerShell for the smoothest
  winget experience. If you get a script-execution error, run:
    powershell -ExecutionPolicy Bypass -File install-claude-code.ps1
#>

$ErrorActionPreference = "Stop"

function Write-Step($msg) { Write-Host "`n==> $msg" -ForegroundColor Cyan }
function Write-Ok($msg)   { Write-Host "    OK: $msg" -ForegroundColor Green }
function Write-Warn2($msg) { Write-Host "    WARN: $msg" -ForegroundColor Yellow }

function Update-SessionPath {
    # winget/npm installers update the registry PATH but not this already-open
    # process's environment. Re-read Machine + User PATH so later commands in
    # this same script (or this same terminal) can find newly installed tools
    # without opening a new window.
    $machine = [System.Environment]::GetEnvironmentVariable("Path", "Machine")
    $user    = [System.Environment]::GetEnvironmentVariable("Path", "User")
    $env:Path = "$machine;$user"
}

Write-Step "Checking for winget"
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Error "winget not found. Install 'App Installer' from the Microsoft Store, then re-run this script."
    exit 1
}
Write-Ok "winget found"

Write-Step "Checking for Node.js"
$node = Get-Command node -ErrorAction SilentlyContinue
if ($node) {
    Write-Ok "Node.js already installed: $(node -v)"
} else {
    Write-Step "Installing Node.js LTS via winget"
    winget install --id OpenJS.NodeJS.LTS -e --source winget --accept-package-agreements --accept-source-agreements
    Update-SessionPath
    if (Get-Command node -ErrorAction SilentlyContinue) {
        Write-Ok "Node.js installed: $(node -v)"
    } else {
        Write-Warn2 "Node.js install finished but 'node' isn't on PATH yet in this session. Close and reopen your terminal, then re-run this script."
        exit 1
    }
}

Write-Step "Checking for git (recommended, not strictly required)"
if (Get-Command git -ErrorAction SilentlyContinue) {
    Write-Ok "git already installed"
} else {
    Write-Warn2 "git not found. install-tools.ps1 will install it, or run: winget install --id Git.Git -e"
}

Write-Step "Installing Claude Code via npm"
npm install -g @anthropic-ai/claude-code
Update-SessionPath

Write-Step "Verifying install"
$claude = Get-Command claude -ErrorAction SilentlyContinue
if ($claude) {
    claude --version
    Write-Ok "Claude Code installed."
} else {
    Write-Warn2 "npm reported success but 'claude' isn't on PATH in this session yet. Close and reopen your terminal and run 'claude --version' to confirm."
}

Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  1. cd into this windows-fixit-tool folder"
Write-Host "  2. Run: claude"
Write-Host "  3. First run opens a browser to log in with your Claude account (Pro/Max subscription covers usage — no separate API key needed)."
Write-Host "  4. Claude will read CLAUDE.md in this folder and act as the fixit assistant."
