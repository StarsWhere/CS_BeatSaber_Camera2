[CmdletBinding()]
param([Parameter(Mandatory = $true)][string]$GameRoot)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$game = (Resolve-Path -LiteralPath $GameRoot).Path
if (-not (Test-Path -LiteralPath (Join-Path $game 'Beat Saber_Data/Managed/Main.dll'))) {
    throw "Game assemblies not found under $game"
}
$obj = Join-Path $root '.tmp/obj/'
$out = Join-Path $root '.tmp/out/'
$inputRoot = Join-Path $root '.tmp/game-refs'
foreach ($directory in @('Beat Saber_Data/Managed', 'Plugins', 'Libs')) {
    $destination = Join-Path $inputRoot $directory
    New-Item -ItemType Directory -Path $destination -Force | Out-Null
    Copy-Item -Path (Join-Path $game "$directory/*.dll") -Destination $destination -Force
}
dotnet build (Join-Path $root 'Camera2.csproj') -c Release `
    "-p:BeatSaberDir=$inputRoot" "-p:GameDirectory=$inputRoot" "-p:BaseIntermediateOutputPath=$obj" "-p:OutputPath=$out" `
    '-p:DisableCopyToGame=True' '-p:DisableCopyToPlugins=True' '-p:DisableZipRelease=True'
if ($LASTEXITCODE -ne 0) { throw "Build failed ($LASTEXITCODE)" }
