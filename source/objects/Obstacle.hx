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

	public function spawn(LaneNo:Int, LevelTheme:Theme):Void
	{
		var vChance:Bool = FlxG.random.bool(60);
		trace(LaneNo, vChance);
		if ((LaneNo == 0 || LaneNo == 5) && vChance)
		{
			frames = GraphicsCache.loadAtlasFrames("assets/images/vehicles.png", "assets/images/vehicles.xml", false, "vehicles");

			animation.frameName = Game.Vehicles[FlxG.random.weightedPick(Game.VehiclesRarity)];
		}
		else
		{
			switch (LevelTheme)
			{
				case WOODS:
					frames = GraphicsCache.loadAtlasFrames("assets/images/camp_objects.png", "assets/images/camp_objects.xml", false, "camp_objects");

					animation.frameName = Game.Obstacles.get(LevelTheme)[FlxG.random.weightedPick(Game.ObstaclesRarity.get(LevelTheme))];

				case CITY:

				case SUBURBS:
			}
		}

		updateHitbox();
        
		ZHeight = height;
		offset.y = height - 16;
		height = 16;
	}
}