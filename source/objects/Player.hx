package objects;


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


	public function new():Void
    {
        super();

		loadGraphic("assets/images/ash.png", true, 16, 16, false, "player");

		animation.add("idle", [0], 0, false);

		animation.add("walk", [0, 1, 0, 2], 10, true);

		animation.add("jump", [2], 0, false);

		width = 8;
		height = 4;
		offset.x = 4;
		offset.y = 12;

		maxVelocity.y = 80;

		health = 3;

		// FlxG.watch.add(this, "jumping");
		// FlxG.watch.add(this, "jumpTimer");
		FlxG.watch.add(this, "jumpingHeight");
	}

	override public function hurt(damage:Float):Void
	{
		if (FlxFlicker.isFlickering(this))
			return;

		#if !debug
		super.hurt(damage);
		#end

		FlxFlicker.flicker(this, 1);
	}

	public function movement(elapsed:Float):Void
	{
		var up:Bool = Actions.up.triggered;
		var down:Bool = Actions.down.triggered;

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

		if (jumpTimer >= 0 && (jump || (jumpTimer > 0 && jumpTimer <= 0.25)))
		{
			onFloor = false;
			jumping = true;
			jumpTimer += elapsed;
		}
		else
			jumpTimer = -1;

		if (jumpTimer > 0 && jumpTimer < 0.75)
		{
			jumpingHeight += jumpVel * elapsed;
			if (jumpingHeight > 24)
				jumpingHeight = 24;
			animation.play("jump");
		}
		else if (jumpingHeight > 0)
			jumpingHeight -= jumpGravity * elapsed;

		if (jumpingHeight < 0)
		{

			jumpingHeight = 0;
			jumpTimer = -1;
			onFloor = true;
			animation.play("walk");
		}

	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		offset.y = 12 + jumpingHeight;
	}

}
