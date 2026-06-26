function Convert-ToWslPath {
  param(
    [Parameter(Mandatory)][string]$DistributionName,
    [Parameter(Mandatory)][string]$WindowsPath
  )

  $resolvedPath = (Resolve-Path -LiteralPath $WindowsPath).Path

  if ($resolvedPath -notmatch '^([A-Za-z]):\\(.+)$') {
    throw "Only local drive paths can be converted to WSL mount paths: $resolvedPath"
  }

  $drive = $matches[1].ToLowerInvariant()
  $path = $matches[2] -replace '\\', '/'

  return "/mnt/$drive/$path"
}

function Invoke-UbuntuBootstrap {
  param(
    [Parameter(Mandatory)][string]$DistributionName,
    [Parameter(Mandatory)][bool]$IsDryRun,
    [Parameter(Mandatory)][bool]$SkipUbuntuPackages
  )

  if (-not (Test-WslCommandAvailable)) {
    Add-SummaryItem -Bucket Pending -Message "wsl.exe was not found; Ubuntu bootstrap skipped."
    return
  }

  $distributionNames = Get-WslDistributionNames

  if ($null -eq $distributionNames) {
    Add-SummaryItem -Bucket Pending -Message "Could not determine whether WSL distribution '$DistributionName' exists; Ubuntu bootstrap skipped."
    return
  }

  if (-not ($distributionNames -contains $DistributionName)) {
    Add-SummaryItem -Bucket Pending -Message "WSL distribution '$DistributionName' does not exist; Ubuntu bootstrap skipped."
    return
  }

  $wslProjectRoot = Convert-ToWslPath -DistributionName $DistributionName -WindowsPath $script:ProjectRoot
  $arguments = @()

  if ($IsDryRun) {
    $arguments += '--dry-run'
  }

  if ($SkipUbuntuPackages) {
    $arguments += '--skip-ubuntu-packages'
  }

  $argumentText = ($arguments | ForEach-Object { "'$_'" }) -join ' '
  $command = "cd '$wslProjectRoot' && bash scripts/ubuntu/bootstrap.sh $argumentText"

  Write-Info "Running Ubuntu bootstrap in WSL distribution '$DistributionName'."

  & wsl.exe -d $DistributionName -- bash -lc $command

  if ($LASTEXITCODE -ne 0) {
    throw "Ubuntu bootstrap failed with exit code $LASTEXITCODE."
  }

  Add-SummaryItem -Bucket Executed -Message "Ubuntu bootstrap completed in WSL distribution '$DistributionName'."
}
