<#
.SYNOPSIS
  Windows host bootstrap for workstation-bootstrap.

.DESCRIPTION
  Current implemented scope is Windows 11 as host with Ubuntu running in WSL2.
  This implementation slice loads configuration, validates basic host
  prerequisites, manages a local state manifest, supports DryRun, and prints a
  final summary. Installation and reset scopes are intentionally pending.
#>

[CmdletBinding()]
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

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$projectRoot = $PSScriptRoot
. (Join-Path $projectRoot 'scripts/windows/lib/bootstrap-common.ps1')
. (Join-Path $projectRoot 'scripts/windows/check-prereqs.ps1')
. (Join-Path $projectRoot 'scripts/windows/install-winget-packages.ps1')
. (Join-Path $projectRoot 'scripts/windows/configure-wslconfig.ps1')
. (Join-Path $projectRoot 'scripts/windows/install-wsl.ps1')
. (Join-Path $projectRoot 'scripts/windows/configure-wezterm.ps1')
. (Join-Path $projectRoot 'scripts/windows/install-fonts.ps1')

Initialize-BootstrapContext -ProjectRoot $projectRoot

try {
  Write-Info "Starting $script:ProjectName bootstrap."

  if ($DryRun) {
    Write-Info 'DryRun enabled; no filesystem changes will be written by this implementation slice.'
  }

  $config = Read-ProjectConfig -RequestedProfile $Profile
  $statePath = Get-StatePath
  $state = Read-StateManifest -Config $config -StatePath $statePath -Profile $Profile

  Add-RunRecord `
    -State $state `
    -Profile $Profile `
    -IsDryRun ([bool]$DryRun) `
    -Reset ([bool]$Reset) `
    -ResetScope $ResetScope `
    -ConfirmDestructive ([bool]$ConfirmDestructive) `
    -SkipWSL ([bool]$SkipWSL) `
    -SkipWindowsApps ([bool]$SkipWindowsApps) `
    -SkipUbuntuPackages ([bool]$SkipUbuntuPackages) `
    -Export ([bool]$Export)

  Invoke-HostPrerequisiteChecks `
    -SkipWindowsApps ([bool]$SkipWindowsApps) `
    -SkipWSL ([bool]$SkipWSL)

  Invoke-ResetGuard `
    -Reset ([bool]$Reset) `
    -ResetScope $ResetScope `
    -ConfirmDestructive ([bool]$ConfirmDestructive)

  if (-not $Reset) {
    if ($SkipWindowsApps) {
      Add-SummaryItem -Bucket Ignored -Message "Skipped Windows app installation because -SkipWindowsApps was provided."
    }
    else {
      Invoke-WingetPackageInstall `
        -State $state `
        -IsDryRun ([bool]$DryRun)
    }

    if ($SkipWSL) {
      Add-SummaryItem -Bucket Ignored -Message "Skipped .wslconfig generation because -SkipWSL was provided."
    }
    else {
      Set-WslConfig `
        -State $state `
        -IsDryRun ([bool]$DryRun)

      Install-WslDistribution `
        -State $state `
        -DistributionName ([string]$config.wslDistribution) `
        -IsDryRun ([bool]$DryRun)
    }

    Set-WezTermConfig `
      -State $state `
      -IsDryRun ([bool]$DryRun)

    Install-JetBrainsMonoNerdFont `
      -State $state `
      -IsDryRun ([bool]$DryRun)
  }

  Invoke-PendingImplementationGuards `
    -Reset ([bool]$Reset) `
    -Export ([bool]$Export)

  Save-StateManifest `
    -State $state `
    -StatePath $statePath `
    -IsDryRun ([bool]$DryRun)
}
catch {
  Add-SummaryItem -Bucket Pending -Message $_.Exception.Message
  Write-FinalSummary
  throw
}

Write-FinalSummary
