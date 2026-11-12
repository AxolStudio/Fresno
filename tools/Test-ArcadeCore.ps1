$ErrorActionPreference='Stop'
Push-Location (Split-Path -Parent $PSScriptRoot)
try {
 $dep=(git -C ci-dependency rev-parse HEAD).Trim()
 if($LASTEXITCODE -ne 0 -or $dep -ne '7ad35e46be22517cc4d2677abcf48ec3f1808cb9'){throw 'Private dependency pin mismatch'}
 haxe -cp source -cp tests/compat -main DesktopCompatTest -D desktop -D FLX_DEBUG --macro 'desktop.DesktopCompatibility.install()' --interp
 if($LASTEXITCODE -ne 0){throw 'Desktop compatibility macro tests failed'}
 node tools/check-arcade-contract.cjs
 if($LASTEXITCODE -ne 0){throw 'Existing source contract failed'}
 python tests/native/TestNormalText.py
 if($LASTEXITCODE -ne 0){throw 'NormalText regression failed'}
 python tools/Test-ArcadePreservation.py
 if($LASTEXITCODE -ne 0){throw 'Non-desktop preservation failed'}
 foreach($script in @('tools/Test-DesktopControls.ps1','tools/Test-DesktopOnline.ps1')) {
  if(!(Test-Path $script)){throw "Missing required runner $script"}
  & $script
  if($LASTEXITCODE -ne 0){throw "Test runner failed $script"}
 }
} finally {Pop-Location}
