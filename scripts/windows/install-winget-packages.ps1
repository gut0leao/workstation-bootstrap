function Read-WingetPackageList {
  $packagesPath = Join-Path $script:ProjectRoot 'packages/windows.json'

  if (-not (Test-Path -LiteralPath $packagesPath)) {
    throw "Windows package list not found: $packagesPath"
  }

  try {
    return @(Get-Content -LiteralPath $packagesPath -Raw | ConvertFrom-Json)
  }
  catch {
    throw "Failed to parse Windows package list '$packagesPath': $($_.Exception.Message)"
  }
}

function Test-WingetPackageInstalled {
  param([Parameter(Mandatory)][string]$WingetId)

  try {
    $output = & winget list --id $WingetId --exact --accept-source-agreements 2>$null | Out-String
  }
  catch {
    $message = (($_.Exception.Message -split 'No [A-Z]:\\')[0]).Trim()
    Add-SummaryItem -Bucket Pending -Message "Could not query winget package '$WingetId': $message"
    return $null
  }

  if ($LASTEXITCODE -ne 0) {
    return $false
  }

  return $output -match [regex]::Escape($WingetId)
}

function Install-WingetPackage {
  param(
    [Parameter(Mandatory)][string]$Name,
    [Parameter(Mandatory)][string]$WingetId
  )

  & winget install `
    --id $WingetId `
    --exact `
    --source winget `
    --accept-package-agreements `
    --accept-source-agreements `
    --silent

  if ($LASTEXITCODE -ne 0) {
    throw "winget failed to install '$Name' ($WingetId) with exit code $LASTEXITCODE."
  }
}

function Invoke-WingetPackageInstall {
  param(
    [Parameter(Mandatory)]$State,
    [Parameter(Mandatory)][bool]$IsDryRun
  )

  if (-not (Test-CommandAvailable -Name 'winget')) {
    Add-SummaryItem -Bucket Pending -Message "winget command was not found; Windows app installation skipped."
    return
  }

  $packages = Read-WingetPackageList

  foreach ($package in $packages) {
    $name = [string]$package.name
    $wingetId = [string]$package.wingetId
    $enabled = [bool]$package.enabled

    if ([string]::IsNullOrWhiteSpace($name) -or [string]::IsNullOrWhiteSpace($wingetId)) {
      Add-SummaryItem -Bucket Pending -Message "Invalid Windows package entry in packages/windows.json."
      continue
    }

    if (-not $enabled) {
      Add-SummaryItem -Bucket Ignored -Message "Windows app '$name' is disabled in packages/windows.json."
      continue
    }

    Write-Info "Checking Windows app '$name' ($wingetId)."

    $isInstalled = Test-WingetPackageInstalled -WingetId $wingetId

    if ($null -eq $isInstalled) {
      Add-SummaryItem -Bucket Pending -Message "Could not determine whether Windows app '$name' is installed."
      continue
    }

    if ($isInstalled) {
      Add-SummaryItem -Bucket Ignored -Message "Windows app '$name' is already installed; not marked as managed by this project."
      continue
    }

    if ($IsDryRun) {
      Add-SummaryItem -Bucket Pending -Message "DryRun: would install Windows app '$name' ($wingetId)."
      continue
    }

    Install-WingetPackage -Name $name -WingetId $wingetId
    Add-ManagedWindowsApp -State $State -Name $name -WingetId $wingetId -Source 'winget'
    Add-SummaryItem -Bucket Executed -Message "Installed Windows app '$name' ($wingetId)."
  }
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

    Invoke-WingetPackageInstall -State $state -IsDryRun $isDryRun
    Save-StateManifest -State $state -StatePath $statePath -IsDryRun $isDryRun
  }
  catch {
    Add-SummaryItem -Bucket Pending -Message $_.Exception.Message
    Write-FinalSummary
    throw
  }

  Write-FinalSummary
}
