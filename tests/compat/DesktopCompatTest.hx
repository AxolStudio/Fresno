class DesktopCompatTest {
 static function main(){
  var text=new flixel.text.FlxBitmapText();text.checkPendingChanges();
  if(text.calls!=1)throw 'recursive pending update not guarded';
  text.checkPendingChanges();if(text.calls!=2)throw 'guard did not reset';
  var log=new flixel.system.debug.log.BitmapLog();log.clear();
  if(log.index!=-1||!log.cleared||log.entries.length!=0)throw 'clear invariant';
  trace('3 desktop compatibility macro assertions passed');
 }
}
