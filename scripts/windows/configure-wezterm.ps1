function Get-WezTermConfigTargetPath {
  $legacyConfigPath = Join-Path $env:USERPROFILE '.wezterm.lua'

  if (Test-Path -LiteralPath $legacyConfigPath) {
    return $legacyConfigPath
  }

  $configRoot = Join-Path $env:USERPROFILE '.config'
  $weztermRoot = Join-Path $configRoot 'wezterm'
  return Join-Path $weztermRoot 'wezterm.lua'
}

function Copy-ManagedConfigFile {
  param(
    [Parameter(Mandatory)]$State,
    [Parameter(Mandatory)][string]$Name,
    [Parameter(Mandatory)][string]$SourcePath,
    [Parameter(Mandatory)][string]$TargetPath,
    [Parameter(Mandatory)][bool]$IsDryRun
  )

  if (-not (Test-Path -LiteralPath $SourcePath)) {
    throw "Source config not found: $SourcePath"
  }

  $sourceContent = Get-Content -LiteralPath $SourcePath -Raw

  Write-Info "Configuring $Name at '$TargetPath'."

  if (Test-Path -LiteralPath $TargetPath) {
    $targetContent = Get-Content -LiteralPath $TargetPath -Raw

    if ((ConvertTo-ComparableConfigContent -Content $targetContent) -eq (ConvertTo-ComparableConfigContent -Content $sourceContent)) {
      Add-SummaryItem -Bucket Ignored -Message "$Name is already up to date."
      return
    }
  }

  if ($IsDryRun) {
    Add-SummaryItem -Bucket Pending -Message "DryRun: would apply $Name to '$TargetPath'."

    if (Test-Path -LiteralPath $TargetPath) {
      Add-SummaryItem -Bucket Pending -Message "DryRun: would create timestamped backup before replacing '$TargetPath'."
    }

    return
  }

  $targetDirectory = Split-Path -Parent $TargetPath

  if (-not (Test-Path -LiteralPath $targetDirectory)) {
    New-Item -ItemType Directory -Path $targetDirectory -Force | Out-Null
    Add-SummaryItem -Bucket Executed -Message "Created directory '$targetDirectory'."
  }

  if (Test-Path -LiteralPath $TargetPath) {
    $backupPath = Get-BackupPath -Path $TargetPath
    Copy-Item -LiteralPath $TargetPath -Destination $backupPath -Force
    Add-ManagedBackup -State $State -OriginalPath $TargetPath -BackupPath $backupPath -Reason "Before replacing $Name"
    Add-SummaryItem -Bucket Executed -Message "Created backup '$backupPath'."
  }

  Set-Content -LiteralPath $TargetPath -Value $sourceContent -Encoding UTF8
  Add-ManagedConfigFile -State $State -Name $Name -Path $TargetPath -Source $SourcePath
  Add-SummaryItem -Bucket Executed -Message "Applied $Name to '$TargetPath'."
}

function Set-WezTermConfig {
  param(
    [Parameter(Mandatory)]$State,
    [Parameter(Mandatory)][bool]$IsDryRun
  )

  $sourcePath = Join-Path $script:ProjectRoot 'config/wezterm/wezterm.lua'
  $targetPath = Get-WezTermConfigTargetPath

  Copy-ManagedConfigFile `
    -State $State `
    -Name 'WezTerm config' `
    -SourcePath $sourcePath `
    -TargetPath $targetPath `
    -IsDryRun $IsDryRun
}

if ($MyInvocation.InvocationName -ne '.') {
  Set-StrictMode -Version Latest
  $ErrorActionPreference = 'Stop'

  $isDryRun = $args -contains '-DryRun'
  $profileArg = 'personal'
  $profileIndex = [array]::IndexOf($args, '-Profile')

  if ($profileIndex -ge 0 -and $args.Count -gt ($profileIndex + 1)) {
    $profileArg = [string]$args[$profileIndex + 1]
  }

  $projectRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
  . (Join-Path $projectRoot 'scripts/windows/lib/bootstrap-common.ps1')

  Initialize-BootstrapContext -ProjectRoot $projectRoot

  try {
    $config = Read-ProjectConfig -RequestedProfile $profileArg
    $statePath = Get-StatePath
    $state = Read-StateManifest -Config $config -StatePath $statePath -Profile $profileArg

    Set-WezTermConfig -State $state -IsDryRun $isDryRun
    Save-StateManifest -State $state -StatePath $statePath -IsDryRun $isDryRun
  }
  catch {
    Add-SummaryItem -Bucket Pending -Message $_.Exception.Message
    Write-FinalSummary
    throw
  }

  Write-FinalSummary
}
