function Read-VSCodeExtensionList {
  $extensionsPath = Join-Path $script:ProjectRoot 'packages/vscode-extensions.txt'

  if (-not (Test-Path -LiteralPath $extensionsPath)) {
    Add-SummaryItem -Bucket Ignored -Message "VS Code extension list not found; skipping VS Code extensions."
    return @()
  }

  $extensions = Get-Content -LiteralPath $extensionsPath |
    ForEach-Object { $_.Trim() } |
    Where-Object { -not [string]::IsNullOrWhiteSpace($_) -and -not $_.StartsWith('#') }

  return @($extensions)
}

function Get-InstalledVSCodeExtensions {
  try {
    $extensions = & code --list-extensions 2>$null
  }
  catch {
    $message = (($_.Exception.Message -split 'No [A-Z]:\\')[0]).Trim()
    Add-SummaryItem -Bucket Pending -Message "Could not list VS Code extensions: $message"
    return $null
  }

  if ($LASTEXITCODE -ne 0) {
    Add-SummaryItem -Bucket Pending -Message "Could not list VS Code extensions; code exited with code $LASTEXITCODE."
    return $null
  }

  $normalizedExtensions = $extensions | ForEach-Object { $_.Trim() } | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
  return @($normalizedExtensions)
}

function Install-VSCodeExtensions {
  param(
    [Parameter(Mandatory)]$State,
    [Parameter(Mandatory)][bool]$IsDryRun
  )

  if (-not (Test-CommandAvailable -Name 'code')) {
    Add-SummaryItem -Bucket Pending -Message "code command was not found; VS Code configuration skipped."
    return
  }

  $desiredExtensions = @(Read-VSCodeExtensionList)

  if ($desiredExtensions.Count -eq 0) {
    return
  }

  $installedExtensions = @(Get-InstalledVSCodeExtensions)

  if ($null -eq $installedExtensions) {
    Add-SummaryItem -Bucket Pending -Message "Could not determine installed VS Code extensions."
    return
  }

  foreach ($extensionId in $desiredExtensions) {
    Write-Info "Checking VS Code extension '$extensionId'."

    if ($installedExtensions -contains $extensionId) {
      Add-SummaryItem -Bucket Ignored -Message "VS Code extension '$extensionId' is already installed; not marked as managed by this project."
      continue
    }

    if ($IsDryRun) {
      Add-SummaryItem -Bucket Pending -Message "DryRun: would install VS Code extension '$extensionId'."
      continue
    }

    & code --install-extension $extensionId

    if ($LASTEXITCODE -ne 0) {
      throw "Failed to install VS Code extension '$extensionId'; code exited with code $LASTEXITCODE."
    }

    Add-ManagedVSCodeExtension -State $State -ExtensionId $extensionId
    Add-SummaryItem -Bucket Executed -Message "Installed VS Code extension '$extensionId'."
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

    Install-VSCodeExtensions -State $state -IsDryRun $isDryRun
    Save-StateManifest -State $state -StatePath $statePath -IsDryRun $isDryRun
  }
  catch {
    Add-SummaryItem -Bucket Pending -Message $_.Exception.Message
    Write-FinalSummary
    throw
  }

  Write-FinalSummary
}
