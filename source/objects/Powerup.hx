package objects;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxSprite;

class Powerup extends FlxSprite
{
	public var type:PowerupType;

	public function new():Void
	{
		super();
		loadGraphic("assets/images/powerups.png", true, 16, 16, false, "powerups");
		width = height = 16;
		offset.y = 8;
		kill();
	}

	public function spawn(X:Float, Y:Float, Type:PowerupType):Void
	{
		reset(X, Y);
		type = Type;
		animation.frameIndex = type == HEALTH ? 0 : 1;
		velocity.x = 20;
		offset.y = 8;
		FlxTween.tween(offset, {y: 4}, 1, {type: FlxTweenType.PINGPONG, ease: FlxEase.quadInOut});
	}
}

enum abstract PowerupType(String) from String to String
{
	var HEALTH = "health";
	var SKATE = "skate";
}