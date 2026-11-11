package;

import openfl.display.Sprite;
import flixel.FlxGame;
import flixel.FlxG;
import flixel.FlxState;
import flixel.input.actions.FlxAction;
import flixel.input.keyboard.FlxKey;
import flixel.input.gamepad.FlxGamepad;
import flixel.input.gamepad.FlxGamepadInputID;
import globals.Actions;
import globals.Game;
import objects.Player;
import states.PlayState;
import states.PlayState.PauseSubState;
import states.TitleState.Menu;
import states.GameWinState;
import sys.io.File;
import haxe.Json;

class ArcadeRegression extends Sprite
{
	public function new()
	{
		super();
		addChild(new FlxGame(320, 180, ArcadeTestState, 60, 60, true, false));
	}
}

class ArcadeTestState extends FlxState
{
	var ran:Bool = false;
	var frames:Int = 0;
	var checks:Array<Dynamic> = [];
	var pad:FlxGamepad;

	override public function create():Void
	{
		super.create();
		FlxG.autoPause = false;
		// Compile-time guard: never initialize the real analytics API in tests.
		if (!axollib.AxolAPI.testMode)
			throw "Tests require the no-network AxolAPI stub";
		Game.initializeGame();
		pad = @:privateAccess FlxG.gamepads.createByID(0, XINPUT);
	}

	function check(name:String, value:Bool):Void
	{
		checks.push({name: name, passed: value});
		trace(name + ": " + value);
	}

	function refresh():Void
	{
		var all:Array<FlxAction> = [
			Actions.up, Actions.down, Actions.jump, Actions.pause, Actions.pauseHeld, Actions.backUI,
			Actions.upUI, Actions.downUI, Actions.leftUI, Actions.rightUI, Actions.pressUI, Actions.pressUIPress, Actions.any
		];
		for (action in all)
		{
			@:privateAccess action._timestamp = -1;
			action.update();
		}
	}

	function neutral():Void
	{
		FlxG.keys.reset();
		pad.reset();
		refresh();
	}

	function keyboard(key:FlxKey, release:Bool = false):Void
	{
		neutral();
		var input = @:privateAccess FlxG.keys._keyListMap.get(key);
		input.press();
		if (release)
			input.release();
		refresh();
	}

	function controller(id:FlxGamepadInputID, release:Bool = false):Void
	{
		neutral();
		var raw = @:privateAccess pad.mapping.getRawID(id);
		var input = @:privateAccess pad.getButton(raw);
		input.press();
		if (release)
			input.release();
		refresh();
	}

	function pauseMenu():PauseSubState
	{
		neutral();
		var menu = new PauseSubState(() -> {});
		menu.create();
		// Complete the opening-input release guard before sending a fresh action.
		menu.update(0);
		return menu;
	}

	function writeReport(expectsExit:Bool):Void
	{
		var passed = true;
		for (entry in checks)
			if (!entry.passed)
				passed = false;
		File.saveContent(Sys.getEnv("FRESNO_TEST_RESULT"), Json.stringify({
			kind: "automated-native-input-tests",
			assertions_passed: passed,
			expects_clean_exit: expectsExit,
			checks: checks
		}, null, "  "));
	}

	function runTests():Void
	{
		keyboard(SPACE);
		check("keyboard jump binding", Actions.jump.triggered);
		var player = new Player(new PlayState());
		player.movement(.1);
		check("keyboard jump raises player", player.jumpingHeight > 0);
		controller(A);
		check("gamepad A jump binding", Actions.jump.triggered);
		player = new Player(new PlayState());
		player.movement(.1);
		check("gamepad jump raises player", player.jumpingHeight > 0);
		neutral();
		check("released jump is not held", !Actions.jump.triggered);
		controller(DPAD_UP);
		player.movement(.1);
		check("gamepad upward movement", player.velocity.y < 0);
		keyboard(DOWN);
		player.movement(.1);
		check("keyboard downward movement", player.velocity.y > 0);
		keyboard(ESCAPE);
		check("keyboard pause", Actions.pause.triggered && Actions.pauseHeld.triggered);
		controller(START);
		check("gamepad pause", Actions.pause.triggered && Actions.pauseHeld.triggered);

		var title = new Menu();
		title.create();
		title.ready = true;
		controller(B, true);
		title.update(0);
		check("gamepad Back does not confirm title menu", title.ready && title.selected == 0);
		keyboard(ESCAPE, true);
		title.update(0);
		check("keyboard Back does not confirm title menu", title.ready && title.selected == 0);

		var menu = pauseMenu();
		check("pause has resume restart title and quit", menu.options.length == 4);
		keyboard(DOWN, true);
		menu.update(0);
		check("keyboard pause navigation", menu.selected == 1);
		controller(DPAD_DOWN, true);
		menu.update(0);
		check("gamepad pause navigation", menu.selected == 2);
		controller(B, true);
		menu.update(0);
		check("gamepad Back resumes without choosing title", !menu.ready && @:privateAccess FlxG.game._nextState == null);

		menu = pauseMenu();
		keyboard(DOWN, true);
		menu.update(0);
		keyboard(ENTER, true);
		menu.update(0);
		check("keyboard restart requests state reset", @:privateAccess FlxG.game._nextState != null);
		@:privateAccess FlxG.game._nextState = null;

		menu = pauseMenu();
		for (i in 0...2)
		{
			controller(DPAD_DOWN, true);
			menu.update(0);
		}
		controller(A, true);
		menu.update(0);
		check("gamepad main menu requests state change", @:privateAccess FlxG.game._nextState != null);
		@:privateAccess FlxG.game._nextState = null;

		var ending = new GameWinState();
		ending.create();
		@:privateAccess ending.ready = false;
		controller(B, true);
		ending.update(0);
		check("ending Back works while awaiting a response", @:privateAccess ending.leaving);

		menu = pauseMenu();
		var keyboardExit = Sys.getEnv("FRESNO_EXIT_MODE") == "keyboard";
		for (i in 0...3)
		{
			if (keyboardExit)
				keyboard(DOWN, true);
			else
				controller(DPAD_DOWN, true);
			menu.update(0);
		}
		check("cabinet quit reachable by selected device", menu.selected == 3);
		writeReport(true);
		if (keyboardExit)
			keyboard(ENTER, true);
		else
			controller(A, true);
		menu.update(0);
		// A real System.exit(0) should have terminated the process above.
		check("cabinet quit exits process", false);
		writeReport(false);
		Sys.exit(1);
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		if (!ran && ++frames > 3)
		{
			ran = true;
			try
				runTests()
			catch (error:Dynamic)
			{
				check("runtime exception: " + Std.string(error), false);
				writeReport(false);
				Sys.exit(1);
			}
		}
	}
}
