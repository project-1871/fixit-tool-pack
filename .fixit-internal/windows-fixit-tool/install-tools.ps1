<#
.SYNOPSIS
  Installs the free diagnostic/repair tools listed in tools.json via winget.

.DESCRIPTION
  Part of the windows-fixit-tool kit. Reads tools.json, installs every entry
  marked "install": "winget", skips built-in tools, and prints a summary plus
  a to-do list of "manual" tools (no reliable winget package — usually
  bootable-ISO tools) with their official download URLs.

.NOTES
  Run from an elevated ("Run as Administrator") PowerShell for the smoothest
  winget experience. If a package fails, winget IDs occasionally drift —
  search for the current one with: winget search "<tool name>"
#>

$ErrorActionPreference = "Continue"

$manifestPath = Join-Path $PSScriptRoot "tools.json"
if (-not (Test-Path $manifestPath)) {
    Write-Error "tools.json not found next to this script."
    exit 1
}
$manifest = Get-Content $manifestPath -Raw | ConvertFrom-Json

if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Error "winget not found. Install 'App Installer' from the Microsoft Store, then re-run this script."
    exit 1
}

$installed = @()
$failed    = @()
$manual    = @()
$builtin   = @()

foreach ($tool in $manifest.tools) {
    switch ($tool.install) {
        "winget" {
            Write-Host "`n==> Installing $($tool.name) ($($tool.wingetId))" -ForegroundColor Cyan
            winget install --id $tool.wingetId -e --source winget --accept-package-agreements --accept-source-agreements
            if ($LASTEXITCODE -eq 0) {
                $installed += $tool.name
            } else {
                Write-Host "    FAILED (exit $LASTEXITCODE) — try: winget search `"$($tool.name)`"" -ForegroundColor Yellow
                $failed += $tool.name
            }
        }
        "manual" {
            $manual += $tool
        }
        "builtin" {
            $builtin += $tool
        }
    }
}

Write-Host "`n============================================================" -ForegroundColor Cyan
Write-Host "SUMMARY" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan

Write-Host "`nInstalled ($($installed.Count)):" -ForegroundColor Green
$installed | ForEach-Object { Write-Host "  - $_" }

if ($failed.Count -gt 0) {
    Write-Host "`nFailed ($($failed.Count)) — winget ID may have changed, search manually:" -ForegroundColor Red
    $failed | ForEach-Object { Write-Host "  - $_" }
}

if ($manual.Count -gt 0) {
    Write-Host "`nNo winget package — download these by hand once ($($manual.Count)):" -ForegroundColor Yellow
    $manual | ForEach-Object { Write-Host "  - $($_.name): $($_.manualUrl)" }
}

if ($builtin.Count -gt 0) {
    Write-Host "`nAlready built into Windows, nothing to install ($($builtin.Count)):" -ForegroundColor DarkGray
    $builtin | ForEach-Object { Write-Host "  - $($_.name)" }
}

Write-Host "`nSee tools.json for what each tool is for and its license (a few are free-for-personal-use only — flagged there)."
