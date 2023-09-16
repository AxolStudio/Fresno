package objects;

import globals.Game;

class Skunk extends Obstacle
{
	public function new():Void
	{
		super();
		loadGraphic("assets/images/skunk.png", true, 32, 32, false, "skunk");

		animation.add("idle", [0], 0, false);
		animation.add("run", [8, 9, 10, 11, 12, 13, 14, 15], 30, true);
		animation.add("spray", [16, 17, 18, 19, 20], 30, false);

		updateHitbox();

		width = 14;
		offset.x = 10;
		offset.y = 28;
		height = 4;
		ZHeight = 10;

		kill();
	}

	override public function spawn(X:Float, Y:Float, LaneNo:Int, Style:RoadStyle):Void
	{
		animation.play("idle");

		var newX:Float = X + 8 - Std.int(Math.min(8, width / 2));
		var newY:Float = Y - (height + Math.max(0, 16 - height));
		reset(newX, newY);
	}
}