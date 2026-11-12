#if desktop
package desktop;
import flixel.FlxG;
class DesktopControls {
 public static function neutral():Bool {
  if(FlxG.keys.anyPressed([ANY])||FlxG.gamepads.anyButton())return false;
  for(pad in FlxG.gamepads.getActiveGamepads())if(Math.abs(pad.getXAxis(LEFT_ANALOG_STICK))>.5||Math.abs(pad.getYAxis(LEFT_ANALOG_STICK))>.5)return false;
  return true;
 }
 public static function allow(gate:DesktopGate):Bool return gate.update(FlxG.game.ticks,neutral());
}
#end
