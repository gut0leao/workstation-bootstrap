function Get-UserFontsDirectory {
  return Join-Path $env:LOCALAPPDATA 'Microsoft/Windows/Fonts'
}

function Test-JetBrainsMonoNerdFontInstalled {
  $userFontsDirectory = Get-UserFontsDirectory
  $systemFontsDirectory = Join-Path $env:WINDIR 'Fonts'

  $expectedFiles = @(
    (Join-Path $userFontsDirectory 'JetBrainsMonoNerdFont-Regular.ttf'),
    (Join-Path $systemFontsDirectory 'JetBrainsMonoNerdFont-Regular.ttf')
  )

  foreach ($file in $expectedFiles) {
    if (Test-Path -LiteralPath $file) {
      return $true
    }
  }

  return $false
}

function Install-JetBrainsMonoNerdFont {
  param(
    [Parameter(Mandatory)]$State,
    [Parameter(Mandatory)][bool]$IsDryRun
  )

  $fontName = 'JetBrainsMono Nerd Font'
  $downloadUrl = 'https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip'
  $userFontsDirectory = Get-UserFontsDirectory

  Write-Info "Checking font '$fontName'."

  if (Test-JetBrainsMonoNerdFontInstalled) {
    Add-SummaryItem -Bucket Ignored -Message "$fontName is already installed; not marked as managed by this project."
    return
  }

  if ($IsDryRun) {
    Add-SummaryItem -Bucket Pending -Message "DryRun: would download and install $fontName for the current user."
    return
  }

  if (-not (Test-Path -LiteralPath $userFontsDirectory)) {
    New-Item -ItemType Directory -Path $userFontsDirectory -Force | Out-Null
    Add-SummaryItem -Bucket Executed -Message "Created user fonts directory '$userFontsDirectory'."
  }

  $tempRoot = Join-Path ([IO.Path]::GetTempPath()) "workstation-bootstrap-fonts-$([guid]::NewGuid())"
  $zipPath = Join-Path $tempRoot 'JetBrainsMono.zip'
  $extractPath = Join-Path $tempRoot 'JetBrainsMono'

  New-Item -ItemType Directory -Path $tempRoot -Force | Out-Null

  try {
    Invoke-WebRequest -Uri $downloadUrl -OutFile $zipPath
    Expand-Archive -LiteralPath $zipPath -DestinationPath $extractPath -Force

    $fontFiles = Get-ChildItem -LiteralPath $extractPath -Filter '*.ttf' -Recurse
    $registryPath = 'HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Fonts'

    if (-not (Test-Path -LiteralPath $registryPath)) {
      New-Item -Path $registryPath -Force | Out-Null
    }

    foreach ($fontFile in $fontFiles) {
      $targetPath = Join-Path $userFontsDirectory $fontFile.Name
      Copy-Item -LiteralPath $fontFile.FullName -Destination $targetPath -Force

      $registryName = "$($fontFile.BaseName) (TrueType)"
      New-ItemProperty -Path $registryPath -Name $registryName -Value $targetPath -PropertyType String -Force | Out-Null
      Add-ManagedFont -State $State -Name $registryName -Path $targetPath -Source $downloadUrl
    }

    Add-SummaryItem -Bucket Executed -Message "Installed $($fontFiles.Count) JetBrainsMono Nerd Font files for the current user."
  }
  finally {
    if (Test-Path -LiteralPath $tempRoot) {
      Remove-Item -LiteralPath $tempRoot -Recurse -Force
    }
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

  Initialize-BootstrapContext -ProjectRoot $projectRoot

  try {
    $config = Read-ProjectConfig -RequestedProfile $profileArg
    $statePath = Get-StatePath
    $state = Read-StateManifest -Config $config -StatePath $statePath -Profile $profileArg

    Install-JetBrainsMonoNerdFont -State $state -IsDryRun $isDryRun
    Save-StateManifest -State $state -StatePath $statePath -IsDryRun $isDryRun
  }
  catch {
    Add-SummaryItem -Bucket Pending -Message $_.Exception.Message
    Write-FinalSummary
    throw
  }

  Write-FinalSummary
}
