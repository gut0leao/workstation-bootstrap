function Initialize-BootstrapContext {
  param(
    [Parameter(Mandatory)][string]$ProjectRoot
  )

  $script:ProjectName = 'workstation-bootstrap'
  $script:ProjectRoot = $ProjectRoot
  $script:Summary = [ordered]@{
    Executed = [System.Collections.Generic.List[string]]::new()
    Ignored  = [System.Collections.Generic.List[string]]::new()
    Pending  = [System.Collections.Generic.List[string]]::new()
  }
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
    [Parameter(Mandatory)][string]$StatePath,
    [Parameter(Mandatory)][string]$Profile
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
      profile           = $Profile
      supportedHost     = $Config.supportedHost
      linuxEnvironment  = $Config.linuxEnvironment
      wslDistribution   = $Config.wslDistribution
      resetDefaultScope = $Config.reset.defaultScope
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
    [Parameter(Mandatory)][string]$StatePath,
    [Parameter(Mandatory)][string]$Profile
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
  return New-StateManifest -Config $Config -StatePath $StatePath -Profile $Profile
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
    [Parameter(Mandatory)][string]$Profile,
    [Parameter(Mandatory)][bool]$IsDryRun,
    [Parameter(Mandatory)][bool]$Reset,
    [Parameter(Mandatory)][string]$ResetScope,
    [Parameter(Mandatory)][bool]$ConfirmDestructive,
    [Parameter(Mandatory)][bool]$SkipWSL,
    [Parameter(Mandatory)][bool]$SkipWindowsApps,
    [Parameter(Mandatory)][bool]$SkipUbuntuPackages,
    [Parameter(Mandatory)][bool]$Export
  )

  $run = [ordered]@{
    startedAt          = (Get-Date).ToUniversalTime().ToString('o')
    profile            = $Profile
    dryRun             = $IsDryRun
    reset              = $Reset
    resetScope         = $ResetScope
    confirmDestructive = $ConfirmDestructive
    skipWSL            = $SkipWSL
    skipWindowsApps    = $SkipWindowsApps
    skipUbuntuPackages = $SkipUbuntuPackages
    export             = $Export
  }

  $runs = @($State.runs)
  $State.runs = @($runs + $run)
  Add-SummaryItem -Bucket Executed -Message "Recorded current run in state manifest object."
}

function Invoke-ResetGuard {
  param(
    [Parameter(Mandatory)][bool]$Reset,
    [Parameter(Mandatory)][string]$ResetScope,
    [Parameter(Mandatory)][bool]$ConfirmDestructive
  )

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
  param(
    [Parameter(Mandatory)][bool]$Reset,
    [Parameter(Mandatory)][bool]$Export
  )

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
