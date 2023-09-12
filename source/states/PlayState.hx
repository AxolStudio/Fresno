package states;

import objects.Shadow;
import globals.Actions;
import objects.Road;
import objects.Decoration;
import flixel.math.FlxRect;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tile.FlxTilemap;
import flixel.util.FlxGradient;
import globals.Game;
import objects.Player;

class PlayState extends FlxState
{
	public var levelTheme:globals.Game.Theme;

	public var lyrSky:FlxSprite; // the actual background sky colors
	public var lyrSkyStuff:FlxTypedGroup<FlxSprite>; // stars, moon, sun
	public var lyrClouds:FlxTypedGroup<FlxSprite>; // clouds
	public var lyrBackground:FlxTypedGroup<FlxSprite>; // background repeating images
	public var lyrBackDeco:FlxTypedGroup<Decoration>;
	public var lyrStreet:FlxTypedGroup<Road>;
	public var lyrStreetObjects:FlxTypedGroup<FlxSprite>;
	public var lyrShadow:FlxTypedGroup<Shadow>;
	public var lyrPlayer:FlxTypedGroup<Player>;
	public var lyrFrontDeco:FlxTypedGroup<FlxSprite>;

	public var lyrHUD:FlxTypedGroup<FlxSprite>;

	public var player:Player;

	public var levelSpeed:Float = 100;

	public var lastObjectX:Float = 0;

	public var zoneTop:Float = 80;
	public var zoneBottom:Float = 160;

	public var roadY:Float = 64;

	public var movementAllowed:Bool = false;

	public var playerHitbox:FlxSprite;

	public function new():Void
	{
		super();

		Game.initializeGame();

		levelTheme = WOODS;
	}

	private function makeSky():FlxSprite
	{
		return FlxGradient.createGradientFlxSprite(FlxG.width, Math.ceil(FlxG.height / 6), Game.SkyGradients.get(levelTheme).copy(), 1, -90, true);
	}

	override public function create()
	{
		add(lyrSky = makeSky());
		lyrSky.scrollFactor.set(0, 0);
		add(lyrSkyStuff = new FlxTypedGroup<FlxSprite>());
		add(lyrClouds = new FlxTypedGroup<FlxSprite>());
		add(lyrBackground = new FlxTypedGroup<FlxSprite>());
		add(lyrBackDeco = new FlxTypedGroup<Decoration>());
		add(lyrStreet = new FlxTypedGroup<Road>());
		add(lyrStreetObjects = new FlxTypedGroup<FlxSprite>());
		add(lyrShadow = new FlxTypedGroup<Shadow>());
		add(lyrPlayer = new FlxTypedGroup<Player>());
		add(lyrFrontDeco = new FlxTypedGroup<FlxSprite>());
		add(lyrHUD = new FlxTypedGroup<FlxSprite>());

		createBackground();

		createStartingDeco();

		createStartingRoad();

		createPlayer();

		movementAllowed = true;

		super.create();
	}

	private function createStartingDeco():Void
	{
		var startX:Float = FlxG.random.int(-100, 100);
		var deco:Decoration = null;

		while (startX < FlxG.width * 2)
		{
			lyrBackDeco.add(deco = new Decoration(levelTheme));

			deco.x = startX;
			deco.y = 64 - FlxG.random.int(0, 16) - deco.height;
			startX += deco.width + (16 * FlxG.random.int(1, 4));
		}
		lastObjectX = startX;
	}

	private function createPlayer():Void
	{
		playerHitbox = new FlxSprite();
		player = new Player(playerHitbox);
		player.x = 40;
		player.y = 64 + ((FlxG.height - 64) / 2) - player.height;

		player.velocity.x = levelSpeed;

		player.animation.play("walk");

		lyrPlayer.add(player);

		lyrShadow.add(new Shadow(player));

		// add(playerHitbox);

		FlxG.camera.follow(player);
		FlxG.camera.deadzone = FlxRect.get(40, 80, 0, FlxG.height - 80);
		FlxG.camera.setScrollBoundsRect(0, 0, 1000000, FlxG.height, true);
	}

	private function createBackground():Void
	{
		var bg:FlxSprite = new FlxSprite(0, 0, Game.Backgrounds.get(levelTheme));
		for (i in 0...Std.int(Math.max(2, Math.ceil(FlxG.width / bg.width))))
		{
			lyrBackground.add(new FlxSprite(i * bg.width, 0, Game.Backgrounds.get(levelTheme)));
		}
	}

	private function createStartingRoad():Void
	{
		var road:Road = null;
		for (i in 0...Math.ceil(FlxG.width / 16) + 1)
		{
			lyrStreet.add(road = new Road());
			road.regen(levelTheme);
			road.x = i * 16;
			road.y = roadY;
		}
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		checkBackgrounds();
		if (movementAllowed)
			player.movement(elapsed);
		checkBounds();
	}

	public function checkBounds():Void
	{
		if (player.y < zoneTop)
			player.y = zoneTop;
		else if (player.y + player.height > zoneBottom)
			player.y = zoneBottom - player.height;
	}

	public function checkBackgrounds():Void
	{
		// if the left-most background object has scrolled off the screen to the left, move it to the end of the last background object
		var bg:FlxSprite = lyrBackground.members[0];
		// trace(bg.x + bg.width + " < " + camera.scroll.x);
		if (bg.x + bg.width < camera.scroll.x)
		{
			bg.x = lyrBackground.members[lyrBackground.length - 1].x + lyrBackground.members[lyrBackground.length - 1].width;
			lyrBackground.remove(bg, true);
			lyrBackground.add(bg);
		}

		var deco:Decoration = lyrBackDeco.members[0];
		if (deco.x + deco.width < camera.scroll.x)
		{
			lyrBackDeco.remove(deco, true);

			deco.regen();
			deco.x = Math.max(FlxG.width + camera.scroll.x + 1, lastObjectX);
			deco.y = 64 - FlxG.random.int(0, 16) - deco.height;
			lastObjectX = deco.x + deco.width + (16 * FlxG.random.int(1, 4));

			lyrBackDeco.add(deco);
		}

		var road:Road = lyrStreet.members[0];
		if (road.x + road.width < camera.scroll.x)
		{
			lyrStreet.remove(road, true);

			road.regen(levelTheme);
			road.x = lyrStreet.members[lyrStreet.length - 1].x + lyrStreet.members[lyrStreet.length - 1].width;
			road.y = roadY;

			lyrStreet.add(road);
		}
	}
}
