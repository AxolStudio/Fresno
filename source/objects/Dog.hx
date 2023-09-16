package objects;

import flixel.math.FlxPoint;
import flixel.math.FlxVelocity;
import flixel.FlxG;
import globals.Game;
import flixel.FlxSprite;

class Dog extends Obstacle
{
	public function new():Void
	{
		super();
		loadGraphic("assets/images/dog.png", true, 25, 19, false, "dog");

		animation.add("sit", [0], 0, false, true);
		animation.add("run", [1, 2, 3, 4, 5, 6, 7, 8], 30, true, true);

		updateHitbox();

		ZHeight = 14;
		offset.y = height - 4;
		height = 4;
		width = 14;
        offset.x  = 5;

		kill();
	}

	override public function spawn(X:Float, Y:Float, LaneNo:Int, Style:RoadStyle):Void
	{
		animation.play("sit");

		var newX:Float = X + 8 - Std.int(Math.min(8, width / 2));
		var newY:Float = Y - (height + Math.max(0, 16 - height));
		reset(newX, newY);
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (animation.name == "sit")
		{
			if (x < FlxG.camera.scroll.x + FlxG.width - 16)
			{
				if (FlxG.random.bool(5))
				{
					FlxVelocity.moveTowardsPoint(this, FlxPoint.get(Game.State.player.x, Game.State.player.y), 200);
					animation.play("run");
				}
			}
		}

		if (x < FlxG.camera.scroll.x - 16)
		{
			kill();
		}
	}
}