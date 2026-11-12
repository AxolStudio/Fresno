import desktop.DesktopOnline;
class FresnoFacadeTest {
 static function main(){
  if(DesktopOnline.start(""))throw "Missing key enabled network";
  #if arcade_regression
  if(DesktopOnline.start("11111111111111111111111111111111"))throw "Regression enabled network";
  #end
  DesktopOnline.sendEvent("test");
  var result=DesktopOnline.takeResult(DesktopOnline.submitScore(1,"AAA"));
  if(result==null||result.status!="unavailable")throw "Offline completion missing";
  trace("Facade offline isolation passed");
 }
}
