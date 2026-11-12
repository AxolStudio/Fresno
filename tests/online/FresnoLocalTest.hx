import desktop.DesktopOnlineLocal;
import flixel.util.FlxSave;
class FresnoLocalTest {
 static function main(){
  FlxSave.allowBind=false;
  DesktopOnlineLocal.record(1368,"AAA");
  if(DesktopOnlineLocal.saved || FlxSave.flushes!=0)throw "Failed bind must not claim saved or flush";
  if(DesktopOnlineLocal.rows[0].amount!=1368)throw "Local fallback lost";
  trace("Local failure assertions passed");
 }
}
