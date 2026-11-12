#if desktop
package desktop;
/** Full release per modal, one evaluation per FlxAction render timestamp. */
class DesktopGate {
 public var armed(default,null)=false;
 var lastTick:Float=-1;
 public function new(){}
 public function reset():Void {armed=false;}
 public function update(tick:Float,neutral:Bool):Bool {
  if(lastTick==tick)return false;
  lastTick=tick;
  if(!armed){armed=neutral;return false;}
  return true;
 }
}
#end
