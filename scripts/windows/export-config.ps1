function Export-WorkstationConfig {
  param(
    [Parameter(Mandatory)]$State,
    [Parameter(Mandatory)][bool]$IsDryRun
  )

  $timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
  $exportRoot = Join-Path $script:ProjectRoot 'exports'
  $exportPath = Join-Path $exportRoot $timestamp

  if ($IsDryRun) {
    Add-SummaryItem -Bucket Pending -Message "DryRun: would export workstation state to '$exportPath'."
    return
  }

  New-Item -ItemType Directory -Path $exportPath -Force | Out-Null

  $statePath = Get-StatePath

  if (Test-Path -LiteralPath $statePath) {
    Copy-Item -LiteralPath $statePath -Destination (Join-Path $exportPath 'state.json') -Force
  }

  Get-HostSnapshot | ConvertTo-Json -Depth 10 | Set-Content -LiteralPath (Join-Path $exportPath 'host.json') -Encoding UTF8

  $windowsApps = @()
  if (Test-CommandAvailable -Name 'winget') {
    try {
      $windowsApps = & winget list --accept-source-agreements 2>$null
    }
    catch {
      Add-SummaryItem -Bucket Pending -Message "Could not export winget package list."
    }
  }
  $windowsApps | Set-Content -LiteralPath (Join-Path $exportPath 'winget-list.txt') -Encoding UTF8

  $wslStatus = @()
  $wslList = @()
  if (Test-CommandAvailable -Name 'wsl.exe') {
    try {
      $wslStatus = & wsl.exe --status 2>$null
      $wslList = & wsl.exe --list --verbose 2>$null
    }
    catch {
      Add-SummaryItem -Bucket Pending -Message "Could not export WSL status."
    }
  }
  $wslStatus | Set-Content -LiteralPath (Join-Path $exportPath 'wsl-status.txt') -Encoding UTF8
  $wslList | Set-Content -LiteralPath (Join-Path $exportPath 'wsl-list.txt') -Encoding UTF8

  if (Test-CommandAvailable -Name 'code') {
    try {
      & code --list-extensions | Set-Content -LiteralPath (Join-Path $exportPath 'vscode-extensions.txt') -Encoding UTF8
    }
    catch {
      Add-SummaryItem -Bucket Pending -Message "Could not export VS Code extensions."
    }
  }

  $wslConfigPath = Join-Path $HOME '.wslconfig'
  if (Test-Path -LiteralPath $wslConfigPath) {
    Copy-Item -LiteralPath $wslConfigPath -Destination (Join-Path $exportPath '.wslconfig') -Force
  }

  $weztermConfigPath = Join-Path (Join-Path $HOME '.config/wezterm') 'wezterm.lua'
  if (Test-Path -LiteralPath $weztermConfigPath) {
    Copy-Item -LiteralPath $weztermConfigPath -Destination (Join-Path $exportPath 'wezterm.lua') -Force
  }

  if ($State.PSObject.Properties.Name -contains 'lastExportPath') {
    $State.lastExportPath = $exportPath
  }
  else {
    $State | Add-Member -MemberType NoteProperty -Name lastExportPath -Value $exportPath
  }

  Add-SummaryItem -Bucket Executed -Message "Exported workstation configuration to '$exportPath'."
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
  . (Join-Path $projectRoot 'scripts/windows/check-prereqs.ps1')

  Initialize-BootstrapContext -ProjectRoot $projectRoot

  try {
    $config = Read-ProjectConfig -RequestedProfile $profileArg
    $statePath = Get-StatePath
    $state = Read-StateManifest -Config $config -StatePath $statePath -Profile $profileArg

    Export-WorkstationConfig -State $state -IsDryRun $isDryRun
    Save-StateManifest -State $state -StatePath $statePath -IsDryRun $isDryRun
  }
  catch {
    Add-SummaryItem -Bucket Pending -Message $_.Exception.Message
    Write-FinalSummary
    throw
  }

  Write-FinalSummary
}
