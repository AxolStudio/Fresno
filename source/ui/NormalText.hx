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
    #if desktop
    // Refresh line widths before the fixed-width alignment path reads them.
    override public function computeTextSize():Void {
        var measuredWidth=textWidth;
        super.computeTextSize();
    }
    #end
}
