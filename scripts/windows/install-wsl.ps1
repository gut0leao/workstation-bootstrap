function Get-WslDistributionNames {
  try {
    $output = & wsl.exe --list --quiet 2>$null
  }
  catch {
    $message = (($_.Exception.Message -split 'No [A-Z]:\\')[0]).Trim()
    Add-SummaryItem -Bucket Pending -Message "Could not list WSL distributions: $message"
    return $null
  }

  if ($LASTEXITCODE -ne 0) {
    Add-SummaryItem -Bucket Pending -Message "Could not list WSL distributions; wsl.exe exited with code $LASTEXITCODE."
    return $null
  }

  $distributionNames = @(
    $output |
      ForEach-Object { ($_ -replace "`0", '').Trim() } |
      Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
  )

  return ,$distributionNames
}

function Test-WslCommandAvailable {
  return $null -ne (Get-Command 'wsl.exe' -ErrorAction SilentlyContinue)
}

function Install-WslDistribution {
  param(
    [Parameter(Mandatory)]$State,
    [Parameter(Mandatory)][string]$DistributionName,
    [Parameter(Mandatory)][bool]$IsDryRun
  )

  if (-not (Test-WslCommandAvailable)) {
    Add-SummaryItem -Bucket Pending -Message "wsl.exe was not found; WSL installation cannot continue."
    return
  }

  Write-Info "Checking WSL distribution '$DistributionName'."

  $distributionNames = Get-WslDistributionNames

  if ($null -eq $distributionNames) {
    Add-SummaryItem -Bucket Pending -Message "Could not determine whether WSL distribution '$DistributionName' exists."
    return
  }

  if ($distributionNames -contains $DistributionName) {
    Add-SummaryItem -Bucket Ignored -Message "WSL distribution '$DistributionName' already exists; not marked as managed by this project."
    return
  }

  if ($IsDryRun) {
    Add-SummaryItem -Bucket Pending -Message "DryRun: would install WSL distribution '$DistributionName' with 'wsl --install -d $DistributionName'."
    return
  }

  & wsl.exe --install -d $DistributionName

  if ($LASTEXITCODE -ne 0) {
    throw "wsl --install -d $DistributionName failed with exit code $LASTEXITCODE."
  }

  Add-ManagedWslDistribution -State $State -Name $DistributionName -Source 'wsl --install'
  Add-SummaryItem -Bucket Executed -Message "Installed WSL distribution '$DistributionName'."
  Add-SummaryItem -Bucket Pending -Message "A Windows restart may be required before WSL is fully available."
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

    Install-WslDistribution `
      -State $state `
      -DistributionName ([string]$config.wslDistribution) `
      -IsDryRun $isDryRun

    Save-StateManifest -State $state -StatePath $statePath -IsDryRun $isDryRun
  }
  catch {
    Add-SummaryItem -Bucket Pending -Message $_.Exception.Message
    Write-FinalSummary
    throw
  }

  Write-FinalSummary
}
