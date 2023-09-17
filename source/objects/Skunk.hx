package objects;

import flixel.FlxG;
import globals.Game;

class Skunk extends Obstacle implements IAnimal
{
	public function new():Void
	{
		super();
		loadGraphic("assets/images/skunk.png", true, 32, 32, false, "skunk");

		animation.add("idle", [0, 1, 2, 3, 4, 5], 16, false);
		animation.add("run", [8, 9, 10, 11, 12, 13, 14, 15], 16, true);
		animation.add("spray", [16, 17, 18, 19, 20], 16, false);

		animation.finishCallback = (name:String) ->
		{
			if (name == "idle")
			{
				animation.play("idle", true);
			}
			if (name == "spray")
			{
				animation.play("run", true);
				velocity.x = 200;
			}
		}

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

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (animation.name == "idle")
		{
			if (x + width <= Game.State.player.x + 80)
			{
				animation.play("spray", true);
				spray();
			}
		}

		if (x + width < FlxG.camera.scroll.x - 16 || x > FlxG.camera.scroll.x + FlxG.width + 16)
		{
			kill();
		}
	}

	public function spray():Void
	{
		var spray:Spray = cast Game.State.lyrStreetObjects.recycle(Spray);
		if (spray == null)
			spray = new Spray();
		spray.start(x, y + height);
		Game.State.lyrStreetObjects.add(spray);
	}
}

class Spray extends Obstacle
{
	public function new():Void
	{
		super();
		loadGraphic("assets/images/skunk_gas.png", true, 64, 32, false, "skunk_gas");
		animation.add("spray", [0, 0, 0, 1, 2, 3, 4, 5, 6, 7], 16, false);
		animation.finishCallback = (name:String) ->
		{
			if (name == "spray")
			{
				kill();
			}
		}

		updateHitbox();

		width = 20;
		offset.x = 21;
		offset.y = 17;
		height = 10;
		ZHeight = 10;

		kill();
	}

	public function start(X:Float, Y:Float):Void
	{
		animation.play("spray");
		var newX:Float = X - width;
		var newY:Float = Y - height;
		reset(newX, newY);
	}
}
