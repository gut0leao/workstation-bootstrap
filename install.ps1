<#
.SYNOPSIS
  Windows remote installer placeholder for workstation-bootstrap.

.DESCRIPTION
  This file is intentionally minimal in the initial documentation scaffold.
  Current implemented scope is Windows 11 as host with Ubuntu running in WSL2.
  Future Ubuntu-host support must use install.sh instead of this file.
  Codex should implement the full Windows remote installer described in docs/requirements.md.
#>

param(
  [switch]$DryRun,
  [switch]$SkipWSL,
  [switch]$SkipWindowsApps,
  [switch]$SkipUbuntuPackages,
  [switch]$Export,
  [switch]$Reset,
  [ValidateSet('Config', 'UbuntuTools', 'WSLDistro', 'WindowsApps', 'All')]
  [string]$ResetScope = 'Config',
  [switch]$ConfirmDestructive,
  [ValidateSet('personal', 'corporate', 'minimal')]
  [string]$Profile = 'personal'
)

Write-Host "workstation-bootstrap install.ps1 placeholder"
Write-Host "Host scope: Windows 11 -> WSL2 -> Ubuntu."
Write-Host "Reset scope: controlled reset only; no implicit uninstall-all behavior."
Write-Host "Implement according to docs/requirements.md, docs/architecture.md, and docs/platforms.md."
