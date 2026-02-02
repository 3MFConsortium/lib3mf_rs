$ErrorActionPreference = "Stop"

$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $Root

$LibDir = Join-Path $Root "libraries"
$TargetDir = Join-Path $Root "target"
$ExeDir = Join-Path $TargetDir "examples"
$Default3mf = Join-Path $Root "data\cube.3mf"

if (!(Test-Path $ExeDir)) { New-Item -ItemType Directory -Path $ExeDir | Out-Null }

cargo build --offline

$versionExe = Join-Path $ExeDir "version.exe"
$createExe = Join-Path $ExeDir "create_cube.exe"
$readExe = Join-Path $ExeDir "read_meshes.exe"

rustc --edition 2021 examples\version.rs `
  -L target\debug `
  --extern lib3mf=target\debug\liblib3mf.rlib `
  -o $versionExe

rustc --edition 2021 examples\create_cube.rs `
  -L target\debug `
  --extern lib3mf=target\debug\liblib3mf.rlib `
  -o $createExe

rustc --edition 2021 examples\read_meshes.rs `
  -L target\debug `
  --extern lib3mf=target\debug\liblib3mf.rlib `
  -o $readExe

$env:PATH = "$LibDir;$env:PATH"

& $versionExe
& $createExe

if ($args.Length -ge 1) {
  & $readExe $args
} elseif (Test-Path $Default3mf) {
  & $readExe $Default3mf
} else {
  Write-Host "Skipping read_meshes (provide a 3MF file path as an argument)"
}

Write-Host "Done. Output file: $Root\cube.3mf"
