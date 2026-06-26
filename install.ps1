<#
.SYNOPSIS
  Remote installer for workstation-bootstrap on Windows.

.DESCRIPTION
  Downloads the repository ZIP when run outside a clone and invokes bootstrap.ps1
  with the same high-level parameters.
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
  [string]$Profile = 'personal',
  [string]$Repository = 'gut0leao/workstation-bootstrap',
  [string]$Branch = 'main'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-BootstrapParameters {
  $parameters = @{
    ResetScope = $ResetScope
    Profile    = $Profile
  }

  if ($DryRun) { $parameters.DryRun = $true }
  if ($SkipWSL) { $parameters.SkipWSL = $true }
  if ($SkipWindowsApps) { $parameters.SkipWindowsApps = $true }
  if ($SkipUbuntuPackages) { $parameters.SkipUbuntuPackages = $true }
  if ($Export) { $parameters.Export = $true }
  if ($Reset) { $parameters.Reset = $true }
  if ($ConfirmDestructive) { $parameters.ConfirmDestructive = $true }

  return $parameters
}

function Invoke-LocalBootstrap {
  param([Parameter(Mandatory)][string]$BootstrapPath)

  if (-not (Test-Path -LiteralPath $BootstrapPath)) {
    throw "bootstrap.ps1 not found at '$BootstrapPath'."
  }

  $parameters = Get-BootstrapParameters
  & $BootstrapPath @parameters
}

function Get-InstallerRoot {
  $pathProperty = $script:MyInvocation.MyCommand.PSObject.Properties['Path']

  if ($pathProperty -and -not [string]::IsNullOrWhiteSpace([string]$pathProperty.Value)) {
    return Split-Path -Parent ([string]$pathProperty.Value)
  }

  return $null
}

$installerRoot = Get-InstallerRoot

if (-not [string]::IsNullOrWhiteSpace($installerRoot)) {
  $localBootstrapPath = Join-Path $installerRoot 'bootstrap.ps1'

  if (Test-Path -LiteralPath $localBootstrapPath) {
    Write-Host "[INFO] Found local bootstrap.ps1; running from current checkout."
    Invoke-LocalBootstrap -BootstrapPath $localBootstrapPath
    exit $LASTEXITCODE
  }
}

$downloadUrl = "https://github.com/$Repository/archive/refs/heads/$Branch.zip"
$tempRoot = Join-Path ([IO.Path]::GetTempPath()) "workstation-bootstrap-$([guid]::NewGuid())"
$zipPath = Join-Path $tempRoot 'repo.zip'
$extractPath = Join-Path $tempRoot 'repo'

if ($DryRun) {
  Write-Host "[INFO] DryRun: would download '$downloadUrl'."
  Write-Host "[INFO] DryRun: would extract and run bootstrap.ps1."
  exit 0
}

New-Item -ItemType Directory -Path $tempRoot -Force | Out-Null

try {
  Write-Host "[INFO] Downloading $downloadUrl"
  Invoke-WebRequest -Uri $downloadUrl -OutFile $zipPath

  Expand-Archive -LiteralPath $zipPath -DestinationPath $extractPath -Force

  $bootstrapPath = Get-ChildItem -LiteralPath $extractPath -Filter 'bootstrap.ps1' -Recurse |
    Select-Object -First 1 -ExpandProperty FullName

  Invoke-LocalBootstrap -BootstrapPath $bootstrapPath
}
finally {
  if (Test-Path -LiteralPath $tempRoot) {
    Remove-Item -LiteralPath $tempRoot -Recurse -Force
  }
}
