package objects;

import flixel.FlxSprite;

class Shadow extends FlxSprite
{
	public var target:FlxSprite;

	public function new():Void
	{
		super("assets/images/shadow.png");
		alpha = 0.5;
		blend = MULTIPLY;
	}

	public function spawn(Target:FlxSprite):Void
	{
		target = Target;
	}

	public override function update(elapsed:Float):Void
	{
		if (target != null)
		{
			x = target.x + 1 + (target.width - width) / 2;
			y = target.y + target.height - (height / 2);
			if (!target.exists)
				kill();
		}
		else
			kill();

		super.update(elapsed);
	}
}