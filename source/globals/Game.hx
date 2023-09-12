package globals;

import flixel.FlxG;
import axollib.GraphicsCache;
import flixel.FlxSprite;
import flixel.util.FlxColor;

class Game
{
	public static var SkyGradients:Map<String, Array<FlxColor>>;

	public static var Backgrounds:Map<String, String>;

	public static var Decorations:Map<String, Array<String>>;
	public static var DecorationsRarity:Map<String, Array<Float>>;

	public static var Obstacles:Map<String, Array<String>>;
	public static var ObstaclesRarity:Map<String, Array<Float>>;

	public static var Vehicles:Array<String>;
	public static var VehiclesRarity:Array<Float>;

	public static var gameInitialized:Bool = false;

	public static function initializeGame():Void
	{
		if (gameInitialized)
			return;

		Actions.init();

		buildSkyGradients();

		buildBackgrounds();

		buildDecorations();

		buildObstacles();
	}

	private static function buildSkyGradients():Void
	{
		SkyGradients = [];

		var woods:Array<FlxColor> = [0xfff5d1c3, 0xfff2c5cc, 0xffbdd8e0, 0xff97e7ee, 0xff62ecf8];
		SkyGradients.set(WOODS, woods);
	}

	private static function buildBackgrounds():Void
	{
		Backgrounds = [];

		Backgrounds[WOODS] = "assets/images/forest_back.png";
		// Backgrounds[Theme.SUBURBS] = "assets/images/backgrounds/suburbs.png";
		// Backgrounds[Theme.CITY] = "assets/images/backgrounds/city.png";
	}

	private static function buildObstacles():Void {
		Obstacles = [];
		ObstaclesRarity = [];

		var woods:Array<String> = [];
		var woodRarity:Array<Float> = [];

		var s:FlxSprite = new FlxSprite();
		s.frames = GraphicsCache.loadAtlasFrames("assets/images/camp_objects.png", "assets/images/camp_objects.xml", false, "camp_objects");
		for (f in 0...s.animation.numFrames)
		{
			s.animation.frameIndex = f;
			woods.push(s.animation.frameName);
			woodRarity.push(1 - (s.width / 16 / 100));
		}

		Obstacles.set(WOODS, woods);
		ObstaclesRarity.set(WOODS, woodRarity);

		Vehicles = [];
		VehiclesRarity = [];

		var vehicles:Array<String> = [];
		var vehicleRarity:Array<Float> = [];

		s = new FlxSprite();
		s.frames = GraphicsCache.loadAtlasFrames("assets/images/vehicles.png", "assets/images/vehicles.xml", false, "vehicles");
		for (f in 0...s.animation.numFrames)
		{
			s.animation.frameIndex = f;
			vehicles.push(s.animation.frameName);
			vehicleRarity.push(1 - (s.width / 16 / 100));
		}

		Vehicles = vehicles;
		VehiclesRarity = vehicleRarity;

	}

	private static function buildDecorations():Void
	{
		Decorations = [];
		DecorationsRarity = [];

		var woods:Array<String> = [];
		var woodRarity:Array<Float> = [];

		var s:FlxSprite = new FlxSprite();
		s.frames = GraphicsCache.loadAtlasFrames("assets/images/camp_deco.png", "assets/images/camp_deco.xml", false, "camp_deco");

		// for each frame in the sprite, add it to the list of decorations - and give it a rarity based on how large it is (larger = rarer)
		var frameName:String = "";
		for (f in 0...s.animation.numFrames)
		{
			s.animation.frameIndex = f;
			frameName = s.animation.frameName;
			woods.push(frameName);
			woodRarity.push(1 - (s.width / 16 / 100));
		}

		Decorations.set(WOODS, woods);
		DecorationsRarity.set(WOODS, woodRarity);
	}
}

enum abstract Theme(String) from String to String
{
	var WOODS = "woods";
	var SUBURBS = "suburbs";
	var CITY = "city";
}
