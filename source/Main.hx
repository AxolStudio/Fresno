package;

import openfl.Lib;
#if !desktop
import axollib.DissolveState;
#end
import states.TitleState;
import axollib.AxolAPI;
import globals.Game;
import flixel.system.scaleModes.PixelPerfectScaleMode;
import flixel.FlxG;
import flixel.FlxGame;
import openfl.display.Sprite;

class Main extends Sprite
{
	public function new()
	{
		super();
		#if !desktop
		AxolAPI.firstState = TitleState;
		AxolAPI.init = Game.initializeGame;

		Lib.application.window.onClose.add(() ->
		{
			AxolAPI.sendEvent("GameExited");
		});

		var startFull:Bool = true;
		#if html5
		startFull = false;
		#end
		#if debug
		startFull = false;
		#end

		addChild(new FlxGame(320, 180, DissolveState, 60, 60, true, startFull));

		#else
		Lib.application.window.onClose.add(() -> {
			#if !arcade_regression
			desktop.DesktopOnline.sendEvent("GameExited");
			#end
		});
		addChild(new FlxGame(320, 180, desktop.DesktopBoot, 60, 60, true, true));
		#end

		FlxG.scaleMode = new PixelPerfectScaleMode();
	}
}
