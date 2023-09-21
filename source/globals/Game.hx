package globals;

import axollib.AxolAPI;
import openfl.media.Sound;
import flixel.graphics.frames.FlxBitmapFont;
import objects.Rat;
import states.PlayState;
import flixel.FlxG;
import axollib.GraphicsCache;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import objects.Dog;
import objects.Skunk;
import objects.IAnimal;
import openfl.utils.ByteArray;

@:file("keys/axolapi") class AxolKey extends ByteArrayData {}

class Game
{
	static private var axolBytes = new AxolKey();

	static private var AXOL_KEY:String = StringTools.replace(axolBytes.readUTFBytes(axolBytes.length), "\n", "");

	public static var State:PlayState;
	public static var Backgrounds:Map<Theme, String> = [
		WOODS => "assets/images/forest_back.png",
		SUBURBS => "assets/images/suburbs_back.png",
		CITY => "assets/images/city_back.png"
	];

	public static var LevelLengths:Map<Theme, Float> = [WOODS => 13500, SUBURBS => 18000, CITY => 27000];

	public static var Animals:Map<Theme, Array<Class<IAnimal>>> = [WOODS => [Skunk], SUBURBS => [Dog, Skunk], CITY => [Rat, Dog, Skunk]];
	public static var AnimalsRarity:Map<Theme, Array<Float>> = [WOODS => [1], SUBURBS => [0.75, 0.25], CITY => [0.8, 0.1, 0.1]];

	public static var Decorations:Map<Theme, Array<String>>;
	public static var DecorationsRarity:Map<Theme, Array<Float>>;

	public static var Obstacles:Map<RoadStyle, Array<String>>;
	public static var ObstaclesRarity:Map<RoadStyle, Array<Float>>;

	public static var Vehicles:Array<String>;
	public static var VehiclesRarity:Array<Float>;
	public static var StreetSideObjs:Array<String>;
	public static var StreetSideObjsRarity:Array<Float>;

	public static var gameInitialized:Bool = false;

	public static var OUR_BLACK:FlxColor = 0xff3a3a50;

	public static var CurrentLevel:Int = -1;
	public static var LevelThemes:Map<Int, Theme> = [0 => WOODS, 1 => SUBURBS, 2 => CITY];

	public static var Scores:Map<Int, Int> = [0 => 0, 1 => 0, 2 => 0];

	public static var StartingDifficulty:Map<Theme, Float> = [WOODS => 2, SUBURBS => 2.25, CITY => 2.5];
	public static var DifficultyRate:Map<Theme, Float> = [WOODS => 0.025, SUBURBS => 0.03, CITY => 0.035];

	public static var NormalFont:FlxBitmapFont;

	public static var LevelMusic:Map<Int, String> = [0 => "forest", 1 => "suburbs", 2 => "city"];

	public static var RememberInits:Array<Int> = [1, 0, 0];

	public static function initializeGame():Void
	{
		if (gameInitialized)
			return;

		AxolAPI.initialize(AXOL_KEY);

		NormalFont = FlxBitmapFont.fromAngelCode("assets/images/skinny_text.png", "assets/images/skinny_text.xml");

		Actions.init();
		Sound.preloadSounds();

		buildDecorations();

		buildObstacles();
		gameInitialized = true;
	}

	public static function resetScores():Void
	{
		Scores = [0 => 0, 1 => 0, 2 => 0];
	}

	private static function buildObstacles():Void
	{
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
			s.updateHitbox();
			woods.push(s.animation.frameName);
			woodRarity.push(1 - (s.width / 16 / 10));
		}

		Obstacles.set(GROUND, woods);
		ObstaclesRarity.set(GROUND, woodRarity);

		s.frames = GraphicsCache.loadAtlasFrames("assets/images/street_objects.png", "assets/images/street_objects.xml", false, "street_objects");
		for (f in 0...s.animation.numFrames)
		{
			s.animation.frameIndex = f;
			s.updateHitbox();
			suburbs.push(s.animation.frameName);
			suburbsRarity.push(1 - (s.width / 16 / 10));
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
			s.updateHitbox();
			vehicles.push(s.animation.frameName);
			vehicleRarity.push(1 - (s.width / 16 / 10));
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
