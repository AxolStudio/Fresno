package;

import openfl.Lib;
import axollib.DissolveState;
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

		

		FlxG.scaleMode = new PixelPerfectScaleMode();
	}
}
