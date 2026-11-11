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
	var gameplay:PlayState;

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
		refresh();
		if (release)
		{
			input.release();
			refresh();
		}
	}

	function controller(id:FlxGamepadInputID, release:Bool = false):Void
	{
		neutral();
		var raw = @:privateAccess pad.mapping.getRawID(id);
		var input = @:privateAccess pad.getButton(raw);
		input.press();
		refresh();
		if (release)
		{
			input.release();
			refresh();
		}
	}

	function pauseMenu():PauseSubState
	{
		neutral();
		if (gameplay.subState != null)
		{
			gameplay.closeSubState();
			gameplay.resetSubState();
		}
		gameplay.ready = true;
		gameplay.pause();
		gameplay.resetSubState();
		var menu:PauseSubState = cast gameplay.subState;
		// Complete the opening-input release guard before sending a fresh action.
		neutral();
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
		// Exercise the real gameplay parent and callback, without an online API.
		Game.CurrentLevel = 0;
		gameplay = new PlayState();
		@:privateAccess gameplay._constructor = PlayState.new;
		@:privateAccess FlxG.game._state = gameplay;
		gameplay.create();
		FlxG.autoPause = false;
		FlxG.camera.update(1.1);
		check("real gameplay initialized", gameplay.ready && gameplay.gameStarted);
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
		gameplay.resetSubState();
		check("gamepad Back closes real pause substate", gameplay.subState == null);
		check("gamepad Back restores gameplay readiness", gameplay.ready);
		check("gamepad Back does not request title", @:privateAccess FlxG.game._nextState == null);
		var beforeSpeed = gameplay.levelSpeed;
		neutral();
		gameplay.update(.1);
		check("gameplay updates after resume", gameplay.levelSpeed > beforeSpeed);

		menu = pauseMenu();
		keyboard(DOWN, true);
		menu.update(0);
		keyboard(ENTER, true);
		menu.update(0);
		var next:FlxState = @:privateAccess FlxG.game._nextState.createInstance();
		check("keyboard restart targets a fresh PlayState", Std.isOfType(next, PlayState) && next != gameplay);
		check("keyboard restart preserves current level", Game.CurrentLevel == 0);
		check("keyboard restart resets gameplay progress", cast(next, PlayState).levelDistance == 0 && !cast(next, PlayState).gameStarted);
		@:privateAccess FlxG.game._nextState = null;

		menu = pauseMenu();
		for (i in 0...2)
		{
			controller(DPAD_DOWN, true);
			menu.update(0);
		}
		controller(A, true);
		menu.update(0);
		next = @:privateAccess FlxG.game._nextState.createInstance();
		check("gamepad main menu targets TitleState", Std.isOfType(next, states.TitleState));
		@:privateAccess FlxG.game._nextState = null;

		var ending = new GameWinState();
		ending.create();
		controller(B, true);
		ending.update(0);
		check("ending Back starts leaving during initial fade", @:privateAccess ending.leaving);
		FlxG.camera.update(.3);
		next = @:privateAccess FlxG.game._nextState.createInstance();
		check("ending Back reaches title despite initial fade", Std.isOfType(next, states.TitleState));
		@:privateAccess FlxG.game._nextState = null;

		FlxG.camera.stopFX();
		ending = new GameWinState();
		ending.create();
		FlxG.camera.update(.6);
		@:privateAccess ending.submit();
		check("score submission awaits stub callback", axollib.AxolAPI.scoreCallback != null);
		controller(B, true);
		ending.update(0);
		FlxG.camera.update(.3);
		next = @:privateAccess FlxG.game._nextState.createInstance();
		check("ending Back reaches title while API is pending", Std.isOfType(next, states.TitleState));
		@:privateAccess FlxG.game._nextState = null;
		axollib.AxolAPI.deliverScore({data: {scores: {scores: [], lastId: "0"}}});
		check("late score response cannot open leaderboard after Back", @:privateAccess ending._requestedSubState == null);

		for (response in [null, {data: {scores: {}}}])
		{
			FlxG.camera.stopFX();
			ending = new GameWinState();
			ending.create();
			FlxG.camera.update(.6);
			@:privateAccess ending.submit();
			axollib.AxolAPI.deliverScore(response);
			FlxG.camera.update(.3);
			check("invalid score response leaves ending safely", @:privateAccess FlxG.game._nextState != null);
			@:privateAccess FlxG.game._nextState = null;
		}
		var leaderboard = new states.GameWinState.HiScoreState({data: {scores: {scores: [], lastId: "0"}}});
		leaderboard.create();
		check("empty leaderboard renders without exception", true);

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
