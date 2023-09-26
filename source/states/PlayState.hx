package states;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.math.FlxVelocity;
import flixel.math.FlxPoint;
import axollib.AxolAPI;
import flixel.util.FlxDestroyUtil;
import flixel.graphics.frames.FlxBitmapFont;
import flixel.text.FlxBitmapText;
import ui.Frame;
import flixel.FlxSubState;
import flixel.input.actions.FlxActionInput;
import objects.IAnimal;
import objects.Skunk;
import objects.Dog;
import flixel.util.FlxSort;
import lime.ui.ScanCode;
import objects.Powerup;
import openfl.display.BlendMode;
import ui.HUD;
import flixel.util.FlxColor;
import objects.Obstacle;
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
import globals.Sound;
import objects.Player;
import globals.NGAPI;

class PlayState extends FlxState
{
	public var levelTheme:globals.Game.Theme;

	public var lyrBackground:FlxTypedGroup<FlxSprite>; // background repeating images
	public var lyrBackDeco:FlxTypedGroup<Decoration>;
	public var lyrStreet:FlxTypedGroup<Road>;
	public var lyrStreetObjects:FlxTypedGroup<Obstacle>;
	public var lyrPowerups:FlxTypedGroup<Powerup>;
	public var lyrShadow:FlxTypedGroup<Shadow>;
	public var lyrPlayer:FlxTypedGroup<Player>;
	public var lyrHUD:FlxTypedGroup<FlxSprite>;
	public var lyrStars:FlxTypedGroup<Star>;

	public var player:Player;

	public var levelSpeed:Float = 0;
	public var levelSpeedMax:Float = 100;
	public var levelAcc:Float = 300;

	public var lastObjectX:Float = 0;

	public var zoneTop:Float = 80;
	public var zoneBottom:Float = 160;

	public var roadY:Float = 64;

	public var movementAllowed:Bool = false;

	public var laneX:Array<Float>;

	public var difficulty:Float = 0;

	public var gameStarted:Bool = false;

	public var vignette:FlxSprite;

	public var hud:HUD;

	public var levelDistance:Float = 0;

	public var levelDistanceMax:Float = 0;

	public var levelEndingX:Float = -1;

	public var ready:Bool = false;

	override public function destroy():Void
	{
		lyrBackground = FlxDestroyUtil.destroy(lyrBackground);
		lyrBackDeco = FlxDestroyUtil.destroy(lyrBackDeco);
		lyrStreet = FlxDestroyUtil.destroy(lyrStreet);
		lyrStreetObjects = FlxDestroyUtil.destroy(lyrStreetObjects);
		lyrPowerups = FlxDestroyUtil.destroy(lyrPowerups);
		lyrShadow = FlxDestroyUtil.destroy(lyrShadow);
		lyrPlayer = FlxDestroyUtil.destroy(lyrPlayer);
		vignette = FlxDestroyUtil.destroy(vignette);
		hud = FlxDestroyUtil.destroy(hud);
		lyrStars = FlxDestroyUtil.destroy(lyrStars);

		super.destroy();
	}

	override public function create()
	{
		FlxG.autoPause = true;
		FlxG.camera.pixelPerfectRender = true;

		Game.State = this;

		#if debug
		// Game.CurrentLevel = 2;
		#end

		levelTheme = Game.LevelThemes.get(Game.CurrentLevel);

		add(lyrBackground = new FlxTypedGroup<FlxSprite>());
		if (levelTheme == WOODS)
			add(lyrBackDeco = new FlxTypedGroup<Decoration>());
		add(lyrStreet = new FlxTypedGroup<Road>());
		vignette = FlxGradient.createGradientFlxSprite(FlxG.width, FlxG.height, [
			0xff2d4275, 0xff2d4275, 0xff2d4275, 0xff2d4275, 0xff2d4275, FlxColor.TRANSPARENT, FlxColor.TRANSPARENT, FlxColor.TRANSPARENT,
			FlxColor.TRANSPARENT, FlxColor.TRANSPARENT, 0xff2d4275
		], 1, 90, true);
		vignette.alpha = .95;
		vignette.blend = BlendMode.MULTIPLY;
		vignette.scrollFactor.set(0, 0);
		add(vignette);
		add(lyrShadow = new FlxTypedGroup<Shadow>());
		add(lyrStreetObjects = new FlxTypedGroup<Obstacle>());
		add(lyrPowerups = new FlxTypedGroup<Powerup>());
		add(lyrPlayer = new FlxTypedGroup<Player>());

		createBackground();

		if (levelTheme == WOODS)
			createStartingDeco();

		createStartingRoad();

		createStartingObstacles();

		createPlayer();

		levelDistanceMax = Game.LevelLengths.get(levelTheme);

		add(hud = new HUD(this));
		add(lyrStars = new FlxTypedGroup<Star>());

		levelDistance = -FlxG.width;

		difficulty = Game.StartingDifficulty.get(levelTheme);

		Sound.playMusic(Game.LevelMusic[Game.CurrentLevel]);

		FlxG.camera.fade(Game.OUR_BLACK, 1, true, () ->
		{
			ready = true;
			movementAllowed = true;
			gameStarted = true;
			player.animation.play("walk");
			// player.giveSkateboard();
		});

		AxolAPI.sendEvent('Started Level ${Game.CurrentLevel + 1}');

		super.create();
	}

	public function pause():Void
	{
		if (!ready)
			return;
		ready = false;
		AxolAPI.sendEvent('Paused');
		openSubState(new PauseSubState(returnFromPause));
	}

	private function returnFromPause():Void
	{
		AxolAPI.sendEvent('Resumed');
		ready = true;
	}

	override public function onFocusLost():Void
	{
		if (ready)
			pause();
	}

	private function createStartingObstacles():Void
	{
		laneX = [
			FlxG.width + 16,
			FlxG.width + 16,
			FlxG.width + 16,
			FlxG.width + 16,
			FlxG.width + 16
		];

		for (i in 0...10)
		{
			lyrStreetObjects.add(new Obstacle());
		}
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

	public function gameOver():Void
	{
		FlxG.camera.fade(Game.OUR_BLACK, 1, false, () ->
		{
			// FlxG.switchState(new PlayState());
			AxolAPI.sendEvent('Died on level ${Game.CurrentLevel + 1}');
			FlxG.resetState();
		});
	}

	public function spawnPowerup():Void
	{
		var powerup:Powerup = lyrPowerups.recycle(Powerup);
		if (powerup == null)
		{
			powerup = new Powerup();
		}
		var pX:Float = FlxG.camera.scroll.x + FlxG.width;
		var pY:Float = zoneTop + (FlxG.random.int(1, 4) * 16);


		if (FlxG.random.bool((1 - ((player.health - 1) / 4)) * 100))
		{
			powerup.spawn(pX, pY, HEALTH);
		}
		else
		{
			powerup.spawn(pX, pY, SKATE);
		}
		lyrPowerups.add(powerup);
		addShadow(powerup);
		Sound.play("power_spawn");
	}

	public function addShadow(Target:FlxSprite):Void
	{
		var shadow:Shadow = lyrShadow.recycle(Shadow);
		if (shadow == null)
		{
			shadow = new Shadow();
		}
		shadow.spawn(Target);
		lyrShadow.add(shadow);
	}

	private function createPlayer():Void
	{
		player = new Player(this);
		player.x = 40;
		player.y = 64 + ((FlxG.height - 64) / 2) - player.height;

		player.animation.play("idle");

		lyrPlayer.add(player);

		var shad:Shadow = new Shadow();
		lyrShadow.add(shad);
		shad.spawn(player);

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
			road.regen(levelTheme == WOODS ? GROUND : STREET);
			road.x = i * 16;
			road.y = roadY;
		}
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (!ready || !gameStarted || !player.alive)
			return;
		if (Actions.pause.triggered)
		{
			pause();
			return;
		}

		levelSpeed += levelAcc * elapsed;
		levelSpeed = Math.min(levelSpeed, levelSpeedMax);

		levelDistance += player.velocity.x * elapsed;

		player.velocity.x = levelSpeed * (player.skateTimer > 0 ? 1.5 : 1);

		checkBackgrounds();
		if (movementAllowed)
			player.movement(elapsed);
		checkBounds();
		checkCollisions();

		if (levelDistance >= levelDistanceMax && levelEndingX == -1)
		{
			levelEndingX = FlxG.camera.scroll.x;
		}
		if (levelEndingX != -1 && FlxG.camera.scroll.x >= levelEndingX + FlxG.width)
		{
			if (FlxG.camera.target != null)
				FlxG.camera.follow(null);
			if (player.x > FlxG.camera.scroll.x + FlxG.width)
			{
				FlxG.camera.fade(Game.OUR_BLACK, 1, false, () ->
				{
					Game.Scores.set(Game.CurrentLevel, player.score);
					#if (html5 && ng)
					{
						NGAPI.unlockMedalByName(switch (Game.CurrentLevel)
						{
							case 0: "Forest";
							case 1: "Suburbs";
							case 2: "City";
							default: "";
						});

						NGAPI.postPlayerHiscore(switch (Game.CurrentLevel)
						{
							case 0:
								"Top Suburbs Scores";
							case 1:
								"Top Forest Scores";
							case 2:
								"Top City Scores";
							default:
								"";
						}, player.score);

						if (Game.CurrentLevel == 2)
						{
							NGAPI.postPlayerHiscore("Total Scores", Game.Scores.get(0) + Game.Scores.get(1) + Game.Scores.get(2), (_) ->
							{
								AxolAPI.sendEvent('Game Won!');
								FlxG.switchState(new GameWinState());
							});
						}
						else
						{
							Game.CurrentLevel++;
							AxolAPI.sendEvent('Cleared Level ${Game.CurrentLevel + 1}');

							FlxG.switchState(new PlayState());
						}
					}
					#else
					if (Game.CurrentLevel < 2)
					{
						Game.CurrentLevel++;
						AxolAPI.sendEvent('Cleared Level ${Game.CurrentLevel + 1}');

						FlxG.switchState(new PlayState());
					}
					else
					{
						// game win!?
						AxolAPI.sendEvent('Game Won!');
						FlxG.switchState(new GameWinState());
					}
					#end
				});
			}
		}
		lyrStreetObjects.sort(sortObjects, FlxSort.ASCENDING);
	}

	public function checkCollisions():Void
	{
		if (!player.alive)
			return;
		FlxG.overlap(lyrPlayer, lyrStreetObjects, playerHitObstacle, checkPlayerHitObstacle);
		FlxG.overlap(lyrPlayer, lyrPowerups, playerHitPowerup, checkPlayerHitPowerup);
	}

	private function checkPlayerHitPowerup(P:Player, U:Powerup):Bool
	{
		return P.alive && P.exists && U.alive && U.exists;
	}

	private function playerHitPowerup(P:Player, U:Powerup):Void
	{
		U.kill();
		switch (U.type)
		{
			case PowerupType.HEALTH:
				Sound.play("heart");

				player.health++;
				if (player.health > 5)
					player.health = 5;

			case PowerupType.SKATE:
				player.giveSkateboard();
		}
	}

	private function checkPlayerHitObstacle(P:Player, O:Obstacle):Bool
	{
		if (P.jumpingHeight > O.ZHeight)
		{
			if (!P.wasJumpingOver.contains(O))
				P.wasJumpingOver.push(O);
		}
		return P.jumpingHeight <= O.ZHeight;
	}

	private function playerHitObstacle(P:Player, O:Obstacle):Void
	{
		player.hurt(1);
	}

	public function checkBounds():Void
	{
		if (!player.alive)
			return;
		if (player.y < zoneTop)
			player.y = zoneTop;
		else if (player.y + player.height > zoneBottom)
			player.y = zoneBottom - player.height;
	}

	public function checkBackgrounds():Void
	{
		// if the left-most background object has scrolled off the screen to the left, move it to the end of the last background object
		var bg:FlxSprite = lyrBackground.members[0];

		if (bg.x + bg.width < camera.scroll.x - 32)
		{
			bg.x = lyrBackground.members[lyrBackground.length - 1].x + lyrBackground.members[lyrBackground.length - 1].width;
			lyrBackground.remove(bg, true);
			lyrBackground.add(bg);
		}

		if (levelTheme == WOODS)
		{
			var deco:Decoration = lyrBackDeco.members[0];
			if (deco.x + deco.width < camera.scroll.x - 32)
			{
				lyrBackDeco.remove(deco, true);

				deco.regen();
				deco.x = Math.max(FlxG.width + camera.scroll.x + 1, lastObjectX);
				deco.y = 64 - FlxG.random.int(0, 16) - deco.height;
				lastObjectX = deco.x + deco.width + (16 * FlxG.random.int(1, 4));

				lyrBackDeco.add(deco);
			}
		}

		var road:Road = lyrStreet.members[0];
		if (road.x + road.width < camera.scroll.x)
		{
			lyrStreet.remove(road, true);

			road.regen(levelTheme == WOODS ? GROUND : STREET);
			road.x = lyrStreet.members[lyrStreet.length - 1].x + lyrStreet.members[lyrStreet.length - 1].width;
			road.y = roadY;

			lyrStreet.add(road);
			difficulty += Game.DifficultyRate.get(levelTheme);

			addObstacles(road.x);
		}
	}

	private function addObstacles(CurrentX:Float):Void
	{
		if (levelEndingX != -1)
			return;
		for (l in 0...laneX.length)
		{
			if (CurrentX >= laneX[l] && FlxG.random.bool(difficulty))
			{
				var obstacle = null;

				if (FlxG.random.bool(10))
				{
					var which:Class<Obstacle> = cast Game.Animals.get(levelTheme)[FlxG.random.weightedPick(Game.AnimalsRarity.get(levelTheme))];

					obstacle = lyrStreetObjects.recycle(which);
					if (obstacle == null)
					{
						obstacle = Type.createInstance(which, null);
					}
					addShadow(obstacle);
				}
				else
				{
					obstacle = lyrStreetObjects.recycle(Obstacle, null, true);
					if (obstacle == null)
					{
						obstacle = new Obstacle();
					}
				}
				obstacle.spawn(CurrentX, zoneTop + ((l + 1) * 16), l, levelTheme == WOODS ? GROUND : STREET);

				lyrStreetObjects.add(obstacle);

				laneX[l] = CurrentX + obstacle.width + (16 * FlxG.random.int(1, 4));
			}
		}
	}

	private function sortObjects(Direction:Int, A:Obstacle, B:Obstacle):Int
	{
		if (A.y + A.ZHeight > B.y + B.ZHeight)
			return 1;
		else if (A.y + A.ZHeight < B.y + B.ZHeight)
			return -1;
		else
			return 0;
	}

	public function spawnStar():Void
	{
		var star:Star = lyrStars.recycle(Star);
		if (star == null)
		{
			star = new Star();
		}
		star.spawn();
		lyrStars.add(star);
		Sound.play("star_spawn");
	}
}

class PauseSubState extends FlxSubState
{
	public var ready:Bool = false;

	var cb:Void->Void;

	public function new(CB:Void->Void):Void
	{
		super();
		cb = CB;
	}

	override public function create():Void
	{
		bgColor = 0x663a3a50;

		closeCallback = cb;

		var pauseText:FlxBitmapText = new FlxBitmapText(FlxBitmapFont.fromAngelCode("assets/images/fat_text.png", "assets/images/fat_text.xml"));
		pauseText.text = "* P A U S E D *";
		pauseText.screenCenter();
		pauseText.scrollFactor.set();

		var frame:Frame = new Frame(pauseText.width + 32, pauseText.height + 32);
		frame.screenCenter();
		frame.scrollFactor.set();

		add(frame);
		add(pauseText);

		FlxG.camera.flash(FlxColor.WHITE, .2, () ->
		{
			ready = true;
		});
		super.create();
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		if (!ready)
			return;
		if (Actions.pause.triggered)
		{
			ready = false;
			FlxG.camera.flash(FlxColor.WHITE, .2, () ->
			{
				close();
			});
		}
	}

	override public function destroy():Void
	{
		cb = null;
		super.destroy();
	}
}

class Star extends FlxSprite
{
	public function new()
	{
		super();
		loadGraphic("assets/images/star.png");
		scrollFactor.set();
	}

	public function spawn():Void
	{
		var playerPos:FlxPoint = Game.State.player.getScreenPosition();
		var newx:Float = playerPos.x + (Game.State.player.width / 2) - (width / 2);
		var newy:Float = playerPos.y + (height / 2);

		reset(newx, newy);
		alpha = 0;
		FlxTween.tween(this, {alpha: 1}, .25, {ease: FlxEase.sineIn});
		FlxVelocity.accelerateTowardsPoint(this, Game.State.hud.starPos, 1000, 1000);
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (alive && exists)
		{
			if (y < Game.State.hud.starPos.y)
			{
				Sound.play('star_${Game.State.player.energy + 1}');

				Game.State.player.energy++;
				kill();
			}
		}
	}
}
