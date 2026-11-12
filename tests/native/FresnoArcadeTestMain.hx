import openfl.display.Sprite;
import flixel.FlxGame;
class FresnoArcadeTestMain extends Sprite {
 public function new(){
  super();
  try {
  if(Sys.getEnv("FRESNO_TEST_DEVICE")!=null)
   addChild(new FresnoGuardedGame(320,180,FresnoArcadeSmoke,60,60,true,true));
  else addChild(new FresnoGuardedGame(320,180,FresnoArcadeRegression,60,60,true,true));
  flixel.FlxG.scaleMode=new flixel.system.scaleModes.PixelPerfectScaleMode();
  flixel.FlxG.autoPause=false;
  } catch(e:Dynamic) {
   sys.io.File.saveContent(Sys.getEnv("FRESNO_TEST_RESULT"),haxe.Json.stringify({passed:false,failures:1,error:Std.string(e)+"\n"+haxe.CallStack.toString(haxe.CallStack.exceptionStack())}));
   Sys.exit(1);
  }
 }
}
/** Never leave an invisible native error dialog waiting until the runner timeout. */
private class FresnoGuardedGame extends FlxGame {
 override function onEnterFrame(event:openfl.events.Event):Void {
  try super.onEnterFrame(event) catch(e:Dynamic){
   sys.io.File.saveContent(Sys.getEnv("FRESNO_TEST_RESULT"),haxe.Json.stringify({passed:false,failures:1,error:Std.string(e)+"\n"+haxe.CallStack.toString(haxe.CallStack.exceptionStack())}));
   Sys.exit(1);
  }
 }
}
