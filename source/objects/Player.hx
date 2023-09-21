package objects;


import globals.Sound;
import globals.Game;
import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import states.PlayState;
import flixel.FlxG;
import globals.Actions;
import flixel.FlxSprite;

using flixel.effects.FlxFlicker;

class Player extends FlxSprite {

	private var jumpTimer:Float = -1;
	private var jumping:Bool = false;
	private var onFloor:Bool = true;
	public var jumpingHeight:Float = 0;
	private var jumpVel:Float = 120;
	private var jumpGravity:Float = 100;
	public var energy(default, set):Int = 0;
	public var combo:Int = 1;
	public var score:Int = 0;
	public var skateTimer:Float = 0;

	public var wasJumpingOver:Array<Obstacle> = [];

	public var state:PlayState;

	public function new(State:PlayState):Void
    {
        super();
		state = State;

		loadGraphic("assets/images/ash.png", true, 16, 16, false, "player");

		animation.add("idle", [0], 0, false);

		animation.add("walk", [0, 1, 0, 2], 10, true);

		animation.add("jump", [2], 0, false);

		animation.add("skate", [3, 4], 8, true);

		animation.add("skatejump", [5, 6, 7, 8], 8, true);

		animation.add("die", [9], 0, false);

		width = 4;
		height = 2;
		offset.x = 6;
		offset.y = 14;

		maxVelocity.y = 80;

		health = 5;

		// FlxG.watch.add(this, "jumping");
		// FlxG.watch.add(this, "jumpTimer");
		// FlxG.watch.add(this, "jumpingHeight");
	}

	override public function hurt(damage:Float):Void
	{
		if (FlxFlicker.isFlickering(this) || !alive)
			return;

		Sound.play("collide");

		// #if !debug
		health = health - damage;
		// #end

		energy = 0;
		combo = 1;
		wasJumpingOver = [];

		if (health > 0)
		{
			FlxFlicker.flicker(this, 1);
			if (skateTimer > 0)
				skateTimer = 0;
			animation.play("walk", true);
		}
		else
		{
			alive = false;
			velocity.x = 0;
			animation.play("die", true);
			FlxTween.tween(this, {y: y - 18}, .5, {
				type: FlxTweenType.ONESHOT,
				ease: FlxEase.sineIn,
				onComplete: (_) ->
				{
					FlxTween.tween(this, {y: y + FlxG.height}, 0.5, {
						type: FlxTweenType.ONESHOT,
						ease: FlxEase.sineOut,
						onComplete: (_) ->
						{
							state.gameOver();
						}
					});
				},
				startDelay: .1
			});
		}
	}

	private function set_energy(Value:Int):Int
	{
		energy = Value;
		while (energy >= 5)
		{
			energy -= 5;
			
			Game.State.spawnPowerup();
		}
		return energy;
	}

	public function giveSkateboard():Void
	{
		Sound.play("skateboard");
		skateTimer += 10;
		animation.play(jumpingHeight > 0 ? "skatejump" : "skate", true);

		// puff of smoke?
	}


	public function movement(elapsed:Float):Void
	{
		var up:Bool = Actions.up.triggered;
		var down:Bool = Actions.down.triggered;
		var wasJumping:Bool = jumping;

		if (up && down)
		if (up && down)
			up = down = false;

		if (up)
			velocity.y = -maxVelocity.y;
		else if (down)
			velocity.y = maxVelocity.y;
		else
			velocity.y = 0;

		var jump:Bool = Actions.jump.triggered;

		if (jumping && !jump)
			jumping = false;

		if (onFloor && !jumping)
			jumpTimer = 0;

		if (jumpTimer >= 0 && (jump || (jumpTimer > 0 && jumpTimer <= (skateTimer > 0 ? 0.75 : 0.25))))
		{
			onFloor = false;
			jumping = true;
			jumpTimer += elapsed;
		}
		else
			jumpTimer = -1;

		if (jumpTimer > 0 && jumpTimer < (skateTimer > 0 ? 1.25 : 0.75))
		{
			jumpingHeight += jumpVel * elapsed;
			if (jumpingHeight > 24)
				jumpingHeight = 24;
			// animation.play(skateTimer > 0 ? "skatejump" : "jump");
		}
		else if (jumpingHeight > 0)
			jumpingHeight -= jumpGravity * elapsed;

		if (!wasJumping && jumping)
		{
			Sound.play("jump");
		}

		if (jumpingHeight < 0)
		{
			jumpingHeight = 0;
			jumpTimer = -1;
			onFloor = true;
			// animation.play("walk");
			if (wasJumpingOver.length > 0)
			{
				combo += wasJumpingOver.length;
				// energy += wasJumpingOver.length;

				for (i in 0...wasJumpingOver.length)
				{
					new FlxTimer().start(i * .1, (_) ->
					{
						Game.State.spawnStar();
					});
				}

				score += wasJumpingOver.length * combo;

				// if energy maxed, then spawn a powerup!
				wasJumpingOver = [];

			}
		}

	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		if (!alive)
			return;
		offset.y = 12 + jumpingHeight;
		if (skateTimer > 0)
			skateTimer -= elapsed;
		updateAnimations();
	}

	private function updateAnimations():Void
	{
		if (animation.name != "idle")
		{
			if (jumpingHeight > 0 && !onFloor)
			{
				changeAnimation(skateTimer > 0 ? "skatejump" : "jump");
			}
			else
				changeAnimation(skateTimer > 0 ? "skate" : "walk");
		}
	}

	public function changeAnimation(NewAnimation:String):Void
	{
		if (animation.name != NewAnimation)
			animation.play(NewAnimation, true);
	}

}
