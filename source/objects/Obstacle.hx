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

	public function spawn(X:Float, Y:Float, LaneNo:Int, LevelTheme:Theme):Void
	{

		if ((LaneNo == 0) && FlxG.random.bool(60))
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
        
		var sizes:Array<String> = animation.frameName.split("_");

		ZHeight = Std.parseFloat(sizes[3]);
		offset.y = height - Std.parseFloat(sizes[2]);
		height = Std.parseFloat(sizes[2]);
		width = Std.parseFloat(sizes[1]);

		reset(X, Y - height);
		
	}
}