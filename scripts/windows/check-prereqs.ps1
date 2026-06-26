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
  param(
    [Parameter(Mandatory)][bool]$SkipWindowsApps,
    [Parameter(Mandatory)][bool]$SkipWSL
  )

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

if ($MyInvocation.InvocationName -ne '.') {
  Set-StrictMode -Version Latest
  $ErrorActionPreference = 'Stop'

  $skipWindowsAppsDirect = $args -contains '-SkipWindowsApps'
  $skipWSLDirect = $args -contains '-SkipWSL'
  $projectRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
  . (Join-Path $projectRoot 'scripts/windows/lib/bootstrap-common.ps1')

  Initialize-BootstrapContext -ProjectRoot $projectRoot

  try {
    Invoke-HostPrerequisiteChecks `
      -SkipWindowsApps $skipWindowsAppsDirect `
      -SkipWSL $skipWSLDirect
  }
  catch {
    Add-SummaryItem -Bucket Pending -Message $_.Exception.Message
    Write-FinalSummary
    throw
  }

  Write-FinalSummary
}
