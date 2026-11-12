#if desktop
package desktop;
import flixel.FlxState;
import flixel.FlxG;
import flixel.FlxSprite;
/** Desktop initialization stays on the engine thread. */
class DesktopBoot extends FlxState {
 var remaining=1.5;
 var switched=false;
 override public function create():Void {
  super.create();
  globals.Game.initializeGame();
  var logo=new FlxSprite(0,0,"axollib/images/white-logo-w-rainbow.png");
  var scale=Math.min(1,Math.min(288/logo.width,148/logo.height));
  logo.scale.set(scale,scale);logo.updateHitbox();logo.screenCenter();add(logo);
 }
 override public function update(elapsed:Float):Void {
  super.update(elapsed);remaining-=elapsed;
  if(!switched&&remaining<=0){switched=true;FlxG.switchState(()->new states.TitleState());}
 }
}
#end
