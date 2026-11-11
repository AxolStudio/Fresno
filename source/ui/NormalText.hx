package ui;

import globals.Game;
import flixel.text.FlxBitmapText;

class NormalText extends FlxBitmapText
{
	public function new(?Text:String = ""):Void
	{
		super(0, 0, "", Game.NormalFont);
		text = Text;
	}
}
