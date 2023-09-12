package objects;

import flixel.FlxSprite;

class Shadow extends FlxSprite
{
	public var target:Player;

	public function new(Target:Player):Void
	{
		super("assets/images/shadow.png");

		target = Target;
	}

	public override function update(elapsed:Float):Void
	{
		super.update(elapsed);
		x = target.x + 1 + (target.width - width) / 2;
		y = target.y + target.height - (height / 2); // + target.jumpHeight;
	}
}