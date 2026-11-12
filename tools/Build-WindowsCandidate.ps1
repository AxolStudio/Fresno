$ErrorActionPreference = 'Stop'
Push-Location (Split-Path -Parent $PSScriptRoot)
try {
  # Compile only: production telemetry must never run in CI.
  haxelib run lime build windows -nolaunch
  if ($LASTEXITCODE -ne 0) { throw 'Windows candidate compilation failed' }
  $bin = Join-Path (Get-Location) 'export/local/windows/bin'
  if (!(Test-Path (Join-Path $bin 'fresno.exe'))) { throw 'Missing Windows executable' }
  New-Item -ItemType Directory -Force candidate | Out-Null
  $sha = (git rev-parse HEAD).Trim()
  $manifest = @{ game='The Long Road to Fresno'; sourceCommit=$sha; configuration='windows'; startup='fullscreen'; deployment='none'; dependencyCommit='7ad35e46be22517cc4d2677abcf48ec3f1808cb9'; caveats=@('Physical controller/hotplug and cabinet acceptance pending','Live API delivery not tested','Full campaign/balance not verified; death and ending tests use labeled fixtures'); files=@(Get-ChildItem $bin -File -Recurse | ForEach-Object { @{path=[IO.Path]::GetRelativePath($bin,$_.FullName);sha256=(Get-FileHash $_.FullName -Algorithm SHA256).Hash} }) }
  $manifest | ConvertTo-Json -Depth 6 | Set-Content candidate/manifest.json
  Compress-Archive -Path "$bin/*" -DestinationPath candidate/fresno-Windows.zip -Force
  Get-FileHash candidate/fresno-Windows.zip -Algorithm SHA256 | Format-List | Out-File candidate/SHA256.txt
} finally { Pop-Location }
