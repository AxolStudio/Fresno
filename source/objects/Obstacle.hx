package objects;

import flixel.FlxG;
import axollib.GraphicsCache;
import globals.Game;
import flixel.FlxSprite;

class Obstacle extends FlxSprite
{
	public var ZHeight:Float = 0;

	public function new():Void
	{
		super();
		kill();
	}

	public function spawn(X:Float, Y:Float, LaneNo:Int, Style:RoadStyle):Void
	{
		if ((LaneNo == 0))
		{
			if (FlxG.random.bool(Style == STREET ? 30 : 0))
			{
				frames = GraphicsCache.loadAtlasFrames("assets/images/city_side_objects.png", "assets/images/city_side_objects.xml", false,
					"city_side_objects");

				animation.frameName = Game.StreetSideObjs[FlxG.random.weightedPick(Game.StreetSideObjsRarity)];
			}
			else
			{
				frames = GraphicsCache.loadAtlasFrames("assets/images/vehicles.png", "assets/images/vehicles.xml", false, "vehicles");

				animation.frameName = Game.Vehicles[FlxG.random.weightedPick(Game.VehiclesRarity)];
			}
		}
		else
		{
			switch (Style)
			{
				case GROUND:
					frames = GraphicsCache.loadAtlasFrames("assets/images/camp_objects.png", "assets/images/camp_objects.xml", false, "camp_objects");

					animation.frameName = Game.Obstacles.get(Style)[FlxG.random.weightedPick(Game.ObstaclesRarity.get(Style))];

				case STREET:
					frames = GraphicsCache.loadAtlasFrames("assets/images/street_objects.png", "assets/images/street_objects.xml", false, "street_objects");

					animation.frameName = Game.Obstacles.get(Style)[FlxG.random.weightedPick(Game.ObstaclesRarity.get(Style))];
			}
		}

		updateHitbox();

		var sizes:Array<String> = animation.frameName.split("_");

		ZHeight = Std.parseFloat(sizes[3]);
		offset.y = height - Std.parseFloat(sizes[2]);
		height = Std.parseFloat(sizes[2]);
		width = Std.parseFloat(sizes[1]);

		var newX:Float = X + 8 - Std.int(Math.min(8, width / 2));
		var newY:Float = Y - (height + Math.max(0, 16 - height));

		reset(newX, newY);
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		if (x + width < FlxG.camera.scroll.x - 16)
			kill();
	}
}
