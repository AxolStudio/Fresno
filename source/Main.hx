package;

import flixel.system.scaleModes.PixelPerfectScaleMode;
import flixel.FlxG;
import flixel.FlxGame;
import openfl.display.Sprite;

class Main extends Sprite
{
	public function new()
	{
		super();
		addChild(new FlxGame(320, 180, states.PlayState));
		FlxG.scaleMode = new PixelPerfectScaleMode();
	}
}
