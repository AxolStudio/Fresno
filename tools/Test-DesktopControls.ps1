$ErrorActionPreference='Stop'
Push-Location (Split-Path -Parent $PSScriptRoot)
try {
 haxe -cp source -cp tests/input -main DesktopControlsTest -D desktop --interp
 if($LASTEXITCODE -ne 0){throw 'Desktop controls test failed'}
} finally {Pop-Location}
