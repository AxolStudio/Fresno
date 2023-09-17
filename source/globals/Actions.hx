package globals;

import flixel.input.actions.FlxActionInput;
import flixel.input.actions.FlxActionSet;
import flixel.FlxG;
import flixel.input.actions.FlxActionManager;
import flixel.input.actions.FlxAction;

class Actions
{
	public static var actions:FlxActionManager;

	public static var menuIndex:Int = -1;
	public static var gameIndex:Int = -1;

	public static var up:FlxActionDigital;
	public static var down:FlxActionDigital;
	public static var jump:FlxActionDigital;

	public static var upUI:FlxActionDigital;
	public static var downUI:FlxActionDigital;
	public static var leftUI:FlxActionDigital;
	public static var rightUI:FlxActionDigital;
	public static var pressUI:FlxActionDigital;
	public static var pressUIPress:FlxActionDigital;
	public static var pause:FlxActionDigital;
	public static var any:FlxActionDigital;

	public static var leftStick:FlxActionAnalog;

	public static function init():Void
	{
		if (Actions.actions != null)
			return;
		Actions.actions = FlxG.inputs.add(new FlxActionManager());
		Actions.actions.resetOnStateSwitch = ResetPolicy.NONE;

		Actions.up = new FlxActionDigital();
		Actions.down = new FlxActionDigital();
		Actions.jump = new FlxActionDigital();

		Actions.upUI = new FlxActionDigital();
		Actions.downUI = new FlxActionDigital();
		Actions.leftUI = new FlxActionDigital();
		Actions.rightUI = new FlxActionDigital();
		Actions.pressUI = new FlxActionDigital();
		Actions.pressUIPress = new FlxActionDigital();
		Actions.pause = new FlxActionDigital();
		Actions.any = new FlxActionDigital();

		Actions.leftStick = new FlxActionAnalog();

		var menuSet:FlxActionSet = new FlxActionSet("MenuControls", [
			Actions.upUI,
			Actions.downUI,
			Actions.leftUI,
			Actions.rightUI,
			Actions.pressUI,
			Actions.pressUIPress,
			Actions.any
		], [Actions.leftStick]);

		menuIndex = Actions.actions.addSet(menuSet);

		var gameSet:FlxActionSet = new FlxActionSet("GameControls", [Actions.up, Actions.down, Actions.jump, Actions.pause, Actions.any], [Actions.leftStick]);

		gameIndex = Actions.actions.addSet(gameSet);

		Actions.up.addKey(UP, PRESSED);
		Actions.up.addKey(W, PRESSED);
		Actions.down.addKey(DOWN, PRESSED);
		Actions.down.addKey(S, PRESSED);

		Actions.jump.addKey(SPACE, PRESSED);
		Actions.jump.addKey(X, PRESSED);

		Actions.pause.addKey(P, JUST_PRESSED);
		Actions.pause.addKey(ESCAPE, JUST_PRESSED);

		Actions.up.addGamepad(DPAD_UP, PRESSED);
		Actions.down.addGamepad(DPAD_DOWN, PRESSED);

		Actions.pause.addGamepad(START, JUST_PRESSED);

		Actions.upUI.addKey(UP, JUST_RELEASED);
		Actions.upUI.addKey(W, JUST_RELEASED);
		Actions.downUI.addKey(DOWN, JUST_RELEASED);
		Actions.downUI.addKey(S, JUST_RELEASED);
		Actions.leftUI.addKey(LEFT, JUST_RELEASED);
		Actions.leftUI.addKey(A, JUST_RELEASED);
		Actions.rightUI.addKey(TAB, JUST_RELEASED);
		Actions.rightUI.addKey(RIGHT, JUST_RELEASED);
		Actions.rightUI.addKey(D, JUST_RELEASED);

		Actions.pressUI.addKey(ENTER, JUST_RELEASED);
		Actions.pressUI.addKey(SPACE, JUST_RELEASED);

		Actions.pressUIPress.addKey(ENTER, PRESSED);
		Actions.pressUIPress.addKey(SPACE, PRESSED);

		Actions.upUI.addGamepad(DPAD_UP, JUST_RELEASED);
		Actions.downUI.addGamepad(DPAD_DOWN, JUST_RELEASED);
		Actions.leftUI.addGamepad(DPAD_LEFT, JUST_RELEASED);
		Actions.rightUI.addGamepad(DPAD_RIGHT, JUST_RELEASED);
		Actions.pressUI.addGamepad(A, JUST_RELEASED);
		Actions.pressUI.addGamepad(B, JUST_RELEASED);
		Actions.pressUI.addGamepad(X, JUST_RELEASED);
		Actions.pressUI.addGamepad(Y, JUST_RELEASED);
		Actions.pressUI.addGamepad(START, JUST_RELEASED);
		Actions.pressUIPress.addGamepad(A, PRESSED);
		Actions.pressUIPress.addGamepad(B, PRESSED);
		Actions.pressUIPress.addGamepad(X, PRESSED);
		Actions.pressUIPress.addGamepad(Y, PRESSED);
		Actions.pressUIPress.addGamepad(START, PRESSED);

		Actions.leftStick.addGamepad(LEFT_ANALOG_STICK, MOVED, EITHER);

		Actions.any.addGamepad(A, JUST_RELEASED);
		Actions.any.addGamepad(B, JUST_RELEASED);
		Actions.any.addGamepad(X, JUST_RELEASED);
		Actions.any.addGamepad(Y, JUST_RELEASED);
		Actions.any.addGamepad(START, JUST_RELEASED);

		Actions.any.addKey(ANY, JUST_RELEASED);

		setActive(gameIndex);
	}

	public static function setActive(index:Int):Void
	{
		Actions.actions.activateSet(index, FlxInputDevice.ALL, FlxInputDeviceID.ALL);
	}
}