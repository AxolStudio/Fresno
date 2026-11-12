#if desktop
package desktop;
import flixel.FlxG;
import globals.Actions;
class DesktopControls {
 public static function neutral():Bool {
  // Opening a substate resets raw devices, but FlxAction gamepad inputs retain
  // their own pressed/released state. Consume that transition before arming.
  for(action in [Actions.pressUI,Actions.backUI,Actions.pause,Actions.upUI,
   Actions.downUI,Actions.leftUI,Actions.rightUI,Actions.pressUIPress,Actions.pauseHeld,Actions.any])
   if(action!=null && action.triggered)return false;
  if(FlxG.keys.anyPressed([ANY])||FlxG.gamepads.anyButton())return false;
  for(pad in FlxG.gamepads.getActiveGamepads())if(Math.abs(pad.getXAxis(LEFT_ANALOG_STICK))>.5||Math.abs(pad.getYAxis(LEFT_ANALOG_STICK))>.5)return false;
  return true;
 }
 public static function allow(gate:DesktopGate):Bool return gate.update(FlxG.game.ticks,neutral());
}
#end
