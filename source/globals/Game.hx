package globals;

import states.PlayState;
import flixel.FlxG;
import axollib.GraphicsCache;
import flixel.FlxSprite;
import flixel.util.FlxColor;

class Game
{

	public static var State:PlayState;

	public static var Backgrounds:Map<String, String>;

	public static var Decorations:Map<String, Array<String>>;
	public static var DecorationsRarity:Map<String, Array<Float>>;

	public static var Obstacles:Map<RoadStyle, Array<String>>;
	public static var ObstaclesRarity:Map<RoadStyle, Array<Float>>;

	public static var Vehicles:Array<String>;
	public static var VehiclesRarity:Array<Float>;
	public static var StreetSideObjs:Array<String>;
	public static var StreetSideObjsRarity:Array<Float>;

	public static var gameInitialized:Bool = false;

	public static var OUR_BLACK:FlxColor = 0xff344a58;

	public static function initializeGame():Void
	{
		if (gameInitialized)
			return;

		Actions.init();


		buildBackgrounds();

		buildDecorations();

		buildObstacles();
	}


	private static function buildBackgrounds():Void
	{
		Backgrounds = [];

		Backgrounds[WOODS] = "assets/images/forest_back.png";
		Backgrounds[SUBURBS] = "assets/images/suburbs_back.png";
		// Backgrounds[Theme.CITY] = "assets/images/backgrounds/city.png";
	}

	private static function buildObstacles():Void {
		Obstacles = [];
		ObstaclesRarity = [];

		var woods:Array<String> = [];
		var woodRarity:Array<Float> = [];
		var suburbs:Array<String> = [];
		var suburbsRarity:Array<Float> = [];

		var s:FlxSprite = new FlxSprite();
		s.frames = GraphicsCache.loadAtlasFrames("assets/images/camp_objects.png", "assets/images/camp_objects.xml", false, "camp_objects");
		for (f in 0...s.animation.numFrames)
		{
			s.animation.frameIndex = f;
			woods.push(s.animation.frameName);
			woodRarity.push(1 - (s.width / 16 / 100));
		}

		Obstacles.set(GROUND, woods);
		ObstaclesRarity.set(GROUND, woodRarity);

		s.frames = GraphicsCache.loadAtlasFrames("assets/images/street_objects.png", "assets/images/street_objects.xml", false, "street_objects");
		for (f in 0...s.animation.numFrames)
		{
			s.animation.frameIndex = f;
			suburbs.push(s.animation.frameName);
			suburbsRarity.push(1 - (s.width / 16 / 100));
		}

		Obstacles.set(STREET, suburbs);
		ObstaclesRarity.set(STREET, suburbsRarity);


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

		StreetSideObjs = [];
		StreetSideObjsRarity = [];

		var sideObjs:Array<String> = [];
		var sideObjsRarity:Array<Float> = [];

		s = new FlxSprite();
		s.frames = GraphicsCache.loadAtlasFrames("assets/images/city_side_objects.png", "assets/images/city_side_objects.xml", false, "city_side_objects");
		for (f in 0...s.animation.numFrames)
		{
			s.animation.frameIndex = f;
			sideObjs.push(s.animation.frameName);
			sideObjsRarity.push(1 - (s.width / 16 / 100));
		}

		StreetSideObjs = sideObjs;
		StreetSideObjsRarity = sideObjsRarity;

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

enum abstract RoadStyle(String) from String to String
{
	var GROUND = "ground";
	var STREET = "street";
}
