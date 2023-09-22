package ui;

import flixel.math.FlxRect;
import flixel.addons.display.FlxSliceSprite;

class Frame extends FlxSliceSprite
{
	public function new(Width:Float, Height:Float):Void
	{
		super("assets/images/ui_frame.png", FlxRect.get(15, 15, 4, 4), Width, Height);
	}
}

class InnerFrame extends FlxSliceSprite
{
	public function new(Width:Float, Height:Float):Void
	{
		super("assets/images/inner_frame.png", FlxRect.get(10, 5, 2, 2), Width, Height);
	}
}
