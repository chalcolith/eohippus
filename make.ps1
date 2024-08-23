param(
  [Parameter(Position=0, HelpMessage="The action to take (fetch, build, test, install, package, clean).")]
  [string]
  $Command = 'build',

  [Parameter(HelpMessage="The target(s) to build or test (test, eohippus-fmt, eohippus-lsp)")]
  [string]
  $Target = 'test,parser-perf,eohippus-fmt,eohippus-lsp',

  [Parameter(HelpMessage="The build configuration (Release, Debug).")]
  [string]
  $Config = 'Release',

  [Parameter(HelpMessage="The version number to set.")]
  [string]
  $Version = '',

  [Parameter(HelpMessage="Architecture (native, x64).")]
  [string]
  $Arch = 'x86-64'
)

$ErrorActionPreference = "Stop"

$rootDir = Split-Path $script:MyInvocation.MyCommand.Path

if ($Config -ieq "Release")
{
  $configFlag = ""
  $buildDir = Join-Path -Path $rootDir -ChildPath "build/release"
}
elseif ($Config -ieq "Debug")
{
  $configFlag = "--debug"
  $buildDir = Join-Path -Path $rootDir -ChildPath "build/debug"
}
else
{
  throw "Invalid -Config '$Config'; must be one of (Debug, Release)."
}

if (($Version -eq "") -and (Test-Path -Path "$rootDir\VERSION"))
{
  $Version = (Get-Content "$rootDir\VERSION") + "-" + (& git 'rev-parse' '--short' '--verify' 'HEAD^')
}

$ponyArgs = "--define openssl_0.9.0"

Write-Host "Command:          $Command"
Write-Host "Target:           $Target"
Write-Host "Configuration:    $Config"
Write-Host "Arch:             $Arch"
Write-Host "Version:          $Version"
Write-Host "Root directory:   $rootDir"
Write-Host "Build directory:  $buildDir"

# generate pony templated files if necessary
if (($Command -ne "clean") -and (Test-Path -Path "$rootDir\VERSION"))
{
  $versionTimestamp = (Get-ChildItem -Path "$rootDir\VERSION").LastWriteTimeUtc
  Get-ChildItem -Path $rootDir -Include "*.pony.in" -Recurse | ForEach-Object {
    $templateFile = $_.FullName
    $ponyFile = $templateFile.Substring(0, $templateFile.Length - 3)
    $ponyFileTimestamp = [DateTime]::MinValue
    if (Test-Path $ponyFile)
    {
      $ponyFileTimestamp = (Get-ChildItem -Path $ponyFile).LastWriteTimeUtc
    }
    if (($ponyFileTimestamp -lt $versionTimestamp) -or ($ponyFileTimestamp -lt $_.LastWriteTimeUtc))
    {
      Write-Host "$templateFile -> $ponyFile"
      ((Get-Content -Path $templateFile) -replace '%%VERSION%%', $Version) | Set-Content -Path $ponyFile
    }
  }
}
function Run
{
  param($cmd)

  Write-Host $cmd
  $output = Invoke-Expression $cmd
  $exitCode = $LastExitCode
  if ($exitCode -ne 0) {
    $output | ForEach-Object { Write-Host $_ }
    exit $exitCode
  }
  $output | ForEach-Object { Write-Host $_ }
}

function Build
{
  param($targets)

  if ($targets -like 'test') {
    Run("corral.exe run -- ponyc $configFlag $ponyArgs --cpu `"$Arch`" --output `"$buildDir`" `"$rootDir\eohippus\test`"")
  }
  if ($targets -like 'parser-perf') {
    Run("corral.exe run -- ponyc $configFlag $ponyArgs --cpu `"$Arch`" --output `"$buildDir`" `"$rootDir\eohippus\test\parser-perf`"")
  }
  if ($targets -like 'eohippus-lsp') {
    Run("corral.exe run -- ponyc $configFlag $ponyArgs --cpu `"$Arch`" --output `"$buildDir`" `"$rootDir\eohippus-lsp`"")
  }
  if ($targets -like 'eohippus-fmt') {
    Run("corral.exe run -- ponyc $configFlag $ponyArgs --cpu `"$Arch`" --output `"$buildDir`" `"$rootDir\eohippus-fmt`"")
  }
}

switch ($Command.ToLower())
{
  "fetch"
  {
    Run('corral fetch')
    break
  }

  "build"
  {
    Build($Target)
    break
  }

  "test"
  {
    Build('test')
    Run("$buildDir\test.exe")
    break
  }

  "clean"
  {
    if (Test-Path "$buildDir")
    {
      Run("Remove-Item -Path `"$buildDir`" -Recurse -Force")
    }
    break
  }

  "distclean"
  {
    $distDir = Join-Path -Path $rootDir -ChildPath "build"
    if (Test-Path $distDir)
    {
      Run("Remove-Item -Path `"$distDir`" -Recurse -Force")
    }
    Run("Remove-Item -Path `"*.lib`" -Force")
  }

  default
  {
    throw "Unknown command '$Command'; must be one of (fetch, build, test, clean, distclean)."
  }
}
