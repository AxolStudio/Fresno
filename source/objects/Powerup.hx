package objects;

import flixel.FlxSprite;

class Powerup extends FlxSprite
{
	public var type:PowerupType;

	public function new():Void
	{
		super();
		loadGraphic("assets/images/powerups.png", true, 16, 16, false, "powerups");
		kill();
	}

	public function spawn(X:Float, Y:Float, Type:PowerupType):Void
	{
		reset(X, Y);
		type = Type;
		animation.frameIndex = type == HEALTH ? 0 : 1;
	}
}

enum abstract PowerupType(String) from String to String
{
	var HEALTH = "health";
	var SKATE = "skate";
}