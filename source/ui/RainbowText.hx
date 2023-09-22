package ui;

import flixel.util.FlxColor;

class RainbowText extends NormalText
{
	private static var COLORS:Array<FlxColor> = [0xffe63f38, 0xfff8d239, 0xff64b63b, 0xff3d56d2, 0xff95e3e3, 0xff974d9e];

	private var current:Float = 0;

	public function new(Text:String):Void
	{
		super(Text);
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		current += elapsed * 5;
		if (current > COLORS.length)
			current -= COLORS.length;
		color = COLORS[Std.int(current)];
	}
}
