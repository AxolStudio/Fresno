package objects;


import flixel.math.FlxPoint;
import flixel.math.FlxVelocity;
import flixel.FlxG;
import globals.Game;
import flixel.FlxSprite;

class Rat extends Obstacle implements IAnimal
{
	public function new():Void
	{
		super();
		loadGraphic("assets/images/rat.png", true, 32, 32, false, "rat");

		
		animation.add("run", [5, 6, 7, 8, 9], 16, true, true);

		updateHitbox();

		ZHeight = 14;
		offset.y = height - 8;
		height = 8;
		width = 14;
		offset.x = 5;

		kill();
	}

	override public function spawn(X:Float, Y:Float, LaneNo:Int, Style:RoadStyle):Void
	{
		animation.play("run");

		var newX:Float = X + 8 - Std.int(Math.min(8, width / 2));
		var newY:Float = Y - (height + Math.max(0, 16 - height));
		reset(newX, newY);
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		velocity.x = -80;

		if (x + width < FlxG.camera.scroll.x - 16)
		{
			kill();
		}
	}
}
