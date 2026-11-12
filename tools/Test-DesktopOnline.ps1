$ErrorActionPreference='Stop'
Push-Location (Split-Path -Parent $PSScriptRoot)
try {
 foreach($test in @('DesktopOnlineSessionTest','DesktopOnlineDispatcherTest','DesktopOnlineConcurrencyTest','DesktopOnlineBudgetTest','FresnoOnlineTest','FresnoViewTest','FresnoLocalTest','FresnoFacadeTest')) {
  haxe -cp source -cp tests/online -cp tests/online/stubs -main $test -D desktop --interp
  if($LASTEXITCODE -ne 0){throw "$test failed"}
 }
 haxe -cp source -cp tests/online -cp tests/online/http-stubs -main DesktopOnlineTransportTest -D desktop --interp
 if($LASTEXITCODE -ne 0){throw 'Transport failed'}
 haxe -cp source -cp tests/online -cp tests/online/stubs -main FresnoFacadeTest -D desktop -D arcade_regression --interp
 if($LASTEXITCODE -ne 0){throw 'Regression isolation failed'}
} finally {Pop-Location}
