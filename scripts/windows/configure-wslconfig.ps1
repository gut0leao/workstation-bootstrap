function Get-RecommendedWslConfigValues {
  $totalMemoryGb = 8
  $logicalProcessors = [Environment]::ProcessorCount
  $usedMemoryFallback = $false

  try {
    $computer = Get-CimInstance -ClassName Win32_ComputerSystem
    $totalMemoryGb = [math]::Floor($computer.TotalPhysicalMemory / 1GB)
  }
  catch {
    $usedMemoryFallback = $true
    Add-SummaryItem -Bucket Pending -Message "Could not read total physical memory; using conservative fallback."
  }

  if ($totalMemoryGb -le 0) {
    $totalMemoryGb = 8
  }

  if ($logicalProcessors -le 0) {
    $logicalProcessors = 2
  }

  $memoryGb = [math]::Max(2, [math]::Min(16, [math]::Floor($totalMemoryGb / 2)))
  $maxProcessors = if ($usedMemoryFallback) { 4 } else { 8 }
  $processors = [math]::Max(1, [math]::Min($maxProcessors, [math]::Floor($logicalProcessors / 2)))
  $swapGb = [math]::Max(2, [math]::Min(8, [math]::Floor($memoryGb / 2)))

  return [ordered]@{
    Memory       = "${memoryGb}GB"
    Processors   = [string]$processors
    Swap         = "${swapGb}GB"
    UsedFallback = $usedMemoryFallback
  }
}

function New-WslConfigContent {
  $templatePath = Join-Path $script:ProjectRoot 'config/wsl/wslconfig.template'

  if (-not (Test-Path -LiteralPath $templatePath)) {
    throw "WSL config template not found: $templatePath"
  }

  $values = Get-RecommendedWslConfigValues
  $content = Get-Content -LiteralPath $templatePath -Raw

  $content = $content.Replace('{{WSL_MEMORY}}', $values.Memory)
  $content = $content.Replace('{{WSL_PROCESSORS}}', $values.Processors)
  $content = $content.Replace('{{WSL_SWAP}}', $values.Swap)

  return [ordered]@{
    Content = $content
    Values  = $values
    Source  = $templatePath
  }
}

function Get-BackupPath {
  param([Parameter(Mandatory)][string]$Path)

  $timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
  return "$Path.backup-$timestamp"
}

function ConvertTo-ComparableConfigContent {
  param([Parameter(Mandatory)][string]$Content)

  return (($Content -replace "`r`n", "`n") -replace "`r", "`n").TrimEnd()
}

function Set-WslConfig {
  param(
    [Parameter(Mandatory)]$State,
    [Parameter(Mandatory)][bool]$IsDryRun
  )

  $targetPath = Join-Path $HOME '.wslconfig'
  $generated = New-WslConfigContent
  $desiredContent = $generated.Content

  Write-Info "Configuring WSL settings at '$targetPath'."

  if (Test-Path -LiteralPath $targetPath) {
    if ($generated.Values.UsedFallback) {
      Add-SummaryItem -Bucket Ignored -Message "Existing .wslconfig was preserved because hardware details could not be read safely."
      return
    }

    $currentContent = Get-Content -LiteralPath $targetPath -Raw

    if ((ConvertTo-ComparableConfigContent -Content $currentContent) -eq (ConvertTo-ComparableConfigContent -Content $desiredContent)) {
      Add-SummaryItem -Bucket Ignored -Message ".wslconfig is already up to date."
      return
    }
  }

  if ($IsDryRun) {
    Add-SummaryItem -Bucket Pending -Message "DryRun: would write .wslconfig with memory=$($generated.Values.Memory), processors=$($generated.Values.Processors), swap=$($generated.Values.Swap)."

    if (Test-Path -LiteralPath $targetPath) {
      Add-SummaryItem -Bucket Pending -Message "DryRun: would create timestamped backup before replacing '$targetPath'."
    }

    return
  }

  if (Test-Path -LiteralPath $targetPath) {
    $backupPath = Get-BackupPath -Path $targetPath
    Copy-Item -LiteralPath $targetPath -Destination $backupPath -Force
    Add-ManagedBackup -State $State -OriginalPath $targetPath -BackupPath $backupPath -Reason 'Before replacing .wslconfig'
    Add-SummaryItem -Bucket Executed -Message "Created backup '$backupPath'."
  }

  Set-Content -LiteralPath $targetPath -Value $desiredContent -Encoding UTF8
  Add-ManagedConfigFile -State $State -Name '.wslconfig' -Path $targetPath -Source $generated.Source
  Add-SummaryItem -Bucket Executed -Message "Wrote .wslconfig with memory=$($generated.Values.Memory), processors=$($generated.Values.Processors), swap=$($generated.Values.Swap)."
  Add-SummaryItem -Bucket Pending -Message "Run 'wsl --shutdown' for .wslconfig changes to take effect if WSL is running."
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

    Set-WslConfig -State $state -IsDryRun $isDryRun
    Save-StateManifest -State $state -StatePath $statePath -IsDryRun $isDryRun
  }
  catch {
    Add-SummaryItem -Bucket Pending -Message $_.Exception.Message
    Write-FinalSummary
    throw
  }

  Write-FinalSummary
}
