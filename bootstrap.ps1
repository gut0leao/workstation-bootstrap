<#
.SYNOPSIS
  Windows host bootstrap for workstation-bootstrap.

.DESCRIPTION
  Current implemented scope is Windows 11 as host with Ubuntu running in WSL2.
  This first implementation slice loads configuration, validates basic host
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

$script:ProjectName = 'workstation-bootstrap'
$script:ProjectRoot = $PSScriptRoot
$script:Summary = [ordered]@{
  Executed = [System.Collections.Generic.List[string]]::new()
  Ignored  = [System.Collections.Generic.List[string]]::new()
  Pending  = [System.Collections.Generic.List[string]]::new()
}

function Write-Info {
  param([Parameter(Mandatory)][string]$Message)
  Write-Host "[INFO] $Message"
}

function Write-Warn {
  param([Parameter(Mandatory)][string]$Message)
  Write-Warning $Message
}

function Add-SummaryItem {
  param(
    [Parameter(Mandatory)][ValidateSet('Executed', 'Ignored', 'Pending')]
    [string]$Bucket,
    [Parameter(Mandatory)][string]$Message
  )

  $script:Summary[$Bucket].Add($Message)
}

function Get-LocalStateDirectory {
  $localAppData = [Environment]::GetFolderPath('LocalApplicationData')

  if ([string]::IsNullOrWhiteSpace($localAppData)) {
    return Join-Path $HOME ".workstation-bootstrap"
  }

  return Join-Path $localAppData $script:ProjectName
}

function Get-StatePath {
  return Join-Path (Get-LocalStateDirectory) 'state.json'
}

function Read-ProjectConfig {
  param([Parameter(Mandatory)][string]$RequestedProfile)

  $configPath = Join-Path $script:ProjectRoot 'config/workstation.json'

  if (-not (Test-Path -LiteralPath $configPath)) {
    throw "Configuration file not found: $configPath"
  }

  try {
    $config = Get-Content -LiteralPath $configPath -Raw | ConvertFrom-Json
  }
  catch {
    throw "Failed to parse configuration file '$configPath': $($_.Exception.Message)"
  }

  if (-not $config.profiles.PSObject.Properties.Name.Contains($RequestedProfile)) {
    throw "Profile '$RequestedProfile' is not defined in config/workstation.json."
  }

  Add-SummaryItem -Bucket Executed -Message "Loaded configuration profile '$RequestedProfile'."
  return $config
}

function Get-HostSnapshot {
  $osCaption = 'Windows'
  $osVersion = [Environment]::OSVersion.Version.ToString()

  try {
    $os = Get-CimInstance -ClassName Win32_OperatingSystem
    $osCaption = $os.Caption
    $osVersion = $os.Version
  }
  catch {
    try {
      $registry = Get-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion'
      $osCaption = $registry.ProductName
      $osVersion = "$($registry.CurrentVersion).$($registry.CurrentBuildNumber)"
    }
    catch {
      $osCaption = 'Windows'
      $osVersion = [Environment]::OSVersion.Version.ToString()
    }
  }

  return [ordered]@{
    type              = 'windows'
    computerName      = $env:COMPUTERNAME
    userName          = [Environment]::UserName
    powershellVersion = $PSVersionTable.PSVersion.ToString()
    osCaption         = $osCaption
    osVersion         = $osVersion
  }
}

function Test-IsWindows11 {
  param([Parameter(Mandatory)][string]$Version)

  try {
    $parsedVersion = [version]$Version
    return $parsedVersion.Build -ge 22000
  }
  catch {
    return $false
  }
}

function New-StateManifest {
  param(
    [Parameter(Mandatory)]$Config,
    [Parameter(Mandatory)][string]$StatePath
  )

  $now = (Get-Date).ToUniversalTime().ToString('o')

  return [ordered]@{
    schemaVersion = 1
    project       = $script:ProjectName
    statePath     = $StatePath
    createdAt     = $now
    updatedAt     = $now
    host          = Get-HostSnapshot
    config        = [ordered]@{
      profile            = $Profile
      supportedHost      = $Config.supportedHost
      linuxEnvironment   = $Config.linuxEnvironment
      wslDistribution    = $Config.wslDistribution
      resetDefaultScope  = $Config.reset.defaultScope
    }
    managed       = [ordered]@{
      windowsApps      = @()
      wslDistributions = @()
      configFiles      = @()
      backups          = @()
    }
    runs          = @()
  }
}

function Read-StateManifest {
  param(
    [Parameter(Mandatory)]$Config,
    [Parameter(Mandatory)][string]$StatePath
  )

  if (Test-Path -LiteralPath $StatePath) {
    try {
      $state = Get-Content -LiteralPath $StatePath -Raw | ConvertFrom-Json
      Add-SummaryItem -Bucket Executed -Message "Loaded state manifest '$StatePath'."
      return $state
    }
    catch {
      throw "Failed to parse state manifest '$StatePath': $($_.Exception.Message)"
    }
  }

  Add-SummaryItem -Bucket Pending -Message "State manifest does not exist yet and will be created at '$StatePath'."
  return New-StateManifest -Config $Config -StatePath $StatePath
}

function Save-StateManifest {
  param(
    [Parameter(Mandatory)]$State,
    [Parameter(Mandatory)][string]$StatePath,
    [Parameter(Mandatory)][bool]$IsDryRun
  )

  $State.updatedAt = (Get-Date).ToUniversalTime().ToString('o')
  $State.host = Get-HostSnapshot

  if ($IsDryRun) {
    Add-SummaryItem -Bucket Ignored -Message "DryRun enabled; state manifest was not written."
    return
  }

  $stateDirectory = Split-Path -Parent $StatePath

  if (-not (Test-Path -LiteralPath $stateDirectory)) {
    New-Item -ItemType Directory -Path $stateDirectory -Force | Out-Null
    Add-SummaryItem -Bucket Executed -Message "Created state directory '$stateDirectory'."
  }

  $State | ConvertTo-Json -Depth 20 | Set-Content -LiteralPath $StatePath -Encoding UTF8
  Add-SummaryItem -Bucket Executed -Message "Saved state manifest '$StatePath'."
}

function Add-RunRecord {
  param(
    [Parameter(Mandatory)]$State,
    [Parameter(Mandatory)][bool]$IsDryRun
  )

  $run = [ordered]@{
    startedAt           = (Get-Date).ToUniversalTime().ToString('o')
    profile             = $Profile
    dryRun              = $IsDryRun
    reset               = [bool]$Reset
    resetScope          = $ResetScope
    confirmDestructive  = [bool]$ConfirmDestructive
    skipWSL             = [bool]$SkipWSL
    skipWindowsApps     = [bool]$SkipWindowsApps
    skipUbuntuPackages  = [bool]$SkipUbuntuPackages
    export              = [bool]$Export
  }

  $runs = @($State.runs)
  $State.runs = @($runs + $run)
  Add-SummaryItem -Bucket Executed -Message "Recorded current run in state manifest object."
}

function Test-IsAdministrator {
  $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
  $principal = [Security.Principal.WindowsPrincipal]::new($identity)
  return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Test-CommandAvailable {
  param([Parameter(Mandatory)][string]$Name)
  return $null -ne (Get-Command $Name -ErrorAction SilentlyContinue)
}

function Invoke-HostPrerequisiteChecks {
  Write-Info "Checking Windows host prerequisites."

  $os = Get-HostSnapshot

  if (($os.osCaption -like '*Windows 11*') -or (Test-IsWindows11 -Version $os.osVersion)) {
    Add-SummaryItem -Bucket Executed -Message "Windows 11-compatible build detected: $($os.osCaption) $($os.osVersion)."
  }
  else {
    Add-SummaryItem -Bucket Pending -Message "Expected Windows 11 host; detected '$($os.osCaption)' '$($os.osVersion)'."
  }

  if ($PSVersionTable.PSVersion.Major -ge 5) {
    Add-SummaryItem -Bucket Executed -Message "PowerShell version detected: $($PSVersionTable.PSVersion)."
  }
  else {
    Add-SummaryItem -Bucket Pending -Message "PowerShell 5 or newer is required; detected $($PSVersionTable.PSVersion)."
  }

  if (Test-IsAdministrator) {
    Add-SummaryItem -Bucket Executed -Message "PowerShell is running as administrator."
  }
  else {
    Add-SummaryItem -Bucket Pending -Message "PowerShell is not running as administrator; installation steps may require elevation."
  }

  if ($SkipWindowsApps) {
    Add-SummaryItem -Bucket Ignored -Message "Skipped winget check because -SkipWindowsApps was provided."
  }
  elseif (Test-CommandAvailable -Name 'winget') {
    Add-SummaryItem -Bucket Executed -Message "winget command is available."
  }
  else {
    Add-SummaryItem -Bucket Pending -Message "winget command was not found."
  }

  if ($SkipWSL) {
    Add-SummaryItem -Bucket Ignored -Message "Skipped WSL check because -SkipWSL was provided."
  }
  elseif (Test-CommandAvailable -Name 'wsl') {
    Add-SummaryItem -Bucket Executed -Message "wsl command is available."
  }
  else {
    Add-SummaryItem -Bucket Pending -Message "wsl command was not found."
  }
}

function Invoke-ResetGuard {
  if (-not $Reset) {
    return
  }

  Write-Warn "Reset mode is not implemented yet. No reset actions were executed."

  if ($ResetScope -in @('WSLDistro', 'WindowsApps', 'All') -and -not $ConfirmDestructive) {
    Add-SummaryItem -Bucket Pending -Message "Reset scope '$ResetScope' is destructive and requires -ConfirmDestructive."
  }

  Add-SummaryItem -Bucket Pending -Message "Reset scope '$ResetScope' is documented but not implemented yet."
}

function Invoke-PendingImplementationGuards {
  if ($Reset) {
    return
  }

  Add-SummaryItem -Bucket Pending -Message "Windows application installation is not implemented yet."
  Add-SummaryItem -Bucket Pending -Message "WSL/Ubuntu installation and configuration are not implemented yet."
  Add-SummaryItem -Bucket Pending -Message "Ubuntu package bootstrap is not implemented yet."

  if ($Export) {
    Add-SummaryItem -Bucket Pending -Message "Export mode is not implemented yet."
  }
}

function Write-FinalSummary {
  Write-Host ''
  Write-Host 'Summary'
  Write-Host '-------'

  foreach ($bucket in @('Executed', 'Ignored', 'Pending')) {
    Write-Host "${bucket}:"

    if ($script:Summary[$bucket].Count -eq 0) {
      Write-Host '  - none'
      continue
    }

    foreach ($item in $script:Summary[$bucket]) {
      Write-Host "  - $item"
    }
  }
}

try {
  Write-Info "Starting $script:ProjectName bootstrap."

  if ($DryRun) {
    Write-Info 'DryRun enabled; no filesystem changes will be written by this implementation slice.'
  }

  $config = Read-ProjectConfig -RequestedProfile $Profile
  $statePath = Get-StatePath
  $state = Read-StateManifest -Config $config -StatePath $statePath

  Add-RunRecord -State $state -IsDryRun ([bool]$DryRun)
  Invoke-HostPrerequisiteChecks
  Invoke-ResetGuard
  Invoke-PendingImplementationGuards
  Save-StateManifest -State $state -StatePath $statePath -IsDryRun ([bool]$DryRun)
}
catch {
  Add-SummaryItem -Bucket Pending -Message $_.Exception.Message
  Write-FinalSummary
  throw
}

Write-FinalSummary
