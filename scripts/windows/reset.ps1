function Get-LatestBackupForPath {
  param(
    [Parameter(Mandatory)]$State,
    [Parameter(Mandatory)][string]$Path
  )

  $backups = @($State.managed.backups) |
    Where-Object { $_.originalPath -eq $Path -and (Test-Path -LiteralPath $_.backupPath) } |
    Sort-Object createdAt -Descending

  return $backups | Select-Object -First 1
}

function Restore-ManagedConfigFiles {
  param(
    [Parameter(Mandatory)]$State,
    [Parameter(Mandatory)][bool]$IsDryRun,
    [Parameter(Mandatory)][bool]$ConfirmDestructive
  )

  $configFiles = @($State.managed.configFiles)

  if ($configFiles.Count -eq 0) {
    Add-SummaryItem -Bucket Ignored -Message "No managed config files recorded for reset."
    return
  }

  foreach ($configFile in $configFiles) {
    $backup = Get-LatestBackupForPath -State $State -Path $configFile.path

    if ($null -eq $backup) {
      Add-SummaryItem -Bucket Pending -Message "No backup found for '$($configFile.path)'; leaving managed config in place."
      continue
    }

    if (-not $ConfirmDestructive) {
      Add-SummaryItem -Bucket Pending -Message "Would restore '$($configFile.path)' from '$($backup.backupPath)'; pass -ConfirmDestructive to apply."
      continue
    }

    if ($IsDryRun) {
      Add-SummaryItem -Bucket Pending -Message "DryRun: would restore '$($configFile.path)' from '$($backup.backupPath)'."
      continue
    }

    Copy-Item -LiteralPath $backup.backupPath -Destination $configFile.path -Force
    Add-SummaryItem -Bucket Executed -Message "Restored '$($configFile.path)' from '$($backup.backupPath)'."
  }
}

function Reset-ManagedWindowsApps {
  param(
    [Parameter(Mandatory)]$State,
    [Parameter(Mandatory)][bool]$IsDryRun,
    [Parameter(Mandatory)][bool]$ConfirmDestructive
  )

  $apps = @($State.managed.windowsApps)

  if ($apps.Count -eq 0) {
    Add-SummaryItem -Bucket Ignored -Message "No managed Windows apps recorded for reset."
    return
  }

  if (-not $ConfirmDestructive) {
    Add-SummaryItem -Bucket Pending -Message "Windows app reset requires -ConfirmDestructive."
    return
  }

  foreach ($app in $apps) {
    if ($IsDryRun) {
      Add-SummaryItem -Bucket Pending -Message "DryRun: would uninstall managed Windows app '$($app.name)' ($($app.wingetId))."
      continue
    }

    & winget uninstall --id $app.wingetId --exact --silent

    if ($LASTEXITCODE -eq 0) {
      Add-SummaryItem -Bucket Executed -Message "Uninstalled managed Windows app '$($app.name)' ($($app.wingetId))."
    }
    else {
      Add-SummaryItem -Bucket Pending -Message "Could not uninstall managed Windows app '$($app.name)' ($($app.wingetId)); winget exited with code $LASTEXITCODE."
    }
  }
}

function Reset-ManagedWslDistributions {
  param(
    [Parameter(Mandatory)]$State,
    [Parameter(Mandatory)][bool]$IsDryRun,
    [Parameter(Mandatory)][bool]$ConfirmDestructive
  )

  $distributions = @($State.managed.wslDistributions)

  if ($distributions.Count -eq 0) {
    Add-SummaryItem -Bucket Ignored -Message "No managed WSL distributions recorded for reset."
    return
  }

  if (-not $ConfirmDestructive) {
    Add-SummaryItem -Bucket Pending -Message "WSL distro reset requires -ConfirmDestructive."
    return
  }

  foreach ($distribution in $distributions) {
    if ($IsDryRun) {
      Add-SummaryItem -Bucket Pending -Message "DryRun: would unregister managed WSL distribution '$($distribution.name)'."
      continue
    }

    & wsl.exe --unregister $distribution.name

    if ($LASTEXITCODE -eq 0) {
      Add-SummaryItem -Bucket Executed -Message "Unregistered managed WSL distribution '$($distribution.name)'."
    }
    else {
      Add-SummaryItem -Bucket Pending -Message "Could not unregister managed WSL distribution '$($distribution.name)'; wsl exited with code $LASTEXITCODE."
    }
  }
}

function Reset-ManagedUbuntuTools {
  param(
    [Parameter(Mandatory)]$State,
    [Parameter(Mandatory)][bool]$IsDryRun,
    [Parameter(Mandatory)][bool]$ConfirmDestructive
  )

  $null = $State
  $null = $IsDryRun
  $null = $ConfirmDestructive
  Add-SummaryItem -Bucket Pending -Message "Ubuntu tool reset is intentionally conservative; apt packages are not removed because they are not tracked as project-owned."
}

function Invoke-Reset {
  param(
    [Parameter(Mandatory)]$State,
    [Parameter(Mandatory)][string]$ResetScope,
    [Parameter(Mandatory)][bool]$IsDryRun,
    [Parameter(Mandatory)][bool]$ConfirmDestructive
  )

  Write-Warn "Reset mode active. Only project-managed items recorded in the manifest are eligible."

  switch ($ResetScope) {
    'Config' {
      Restore-ManagedConfigFiles -State $State -IsDryRun $IsDryRun -ConfirmDestructive $ConfirmDestructive
    }
    'UbuntuTools' {
      Reset-ManagedUbuntuTools -State $State -IsDryRun $IsDryRun -ConfirmDestructive $ConfirmDestructive
    }
    'WindowsApps' {
      Reset-ManagedWindowsApps -State $State -IsDryRun $IsDryRun -ConfirmDestructive $ConfirmDestructive
    }
    'WSLDistro' {
      Reset-ManagedWslDistributions -State $State -IsDryRun $IsDryRun -ConfirmDestructive $ConfirmDestructive
    }
    'All' {
      Restore-ManagedConfigFiles -State $State -IsDryRun $IsDryRun -ConfirmDestructive $ConfirmDestructive
      Reset-ManagedWindowsApps -State $State -IsDryRun $IsDryRun -ConfirmDestructive $ConfirmDestructive
      Reset-ManagedWslDistributions -State $State -IsDryRun $IsDryRun -ConfirmDestructive $ConfirmDestructive
      Reset-ManagedUbuntuTools -State $State -IsDryRun $IsDryRun -ConfirmDestructive $ConfirmDestructive
    }
  }
}
