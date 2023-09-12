package axollib;

import flixel.FlxG;
import flixel.text.FlxText;
import flixel.FlxState;

class Blocked extends FlxState {
	override public function create():Void {
		add(new FlxText(5, 5, FlxG.width - 10,
			"You appear to be accessing this software Illegally. Please contact help@axolstudio.com for help or visit https://axolstudio.com/\n\nYour Activity and Personal Information has been logged."));

		super.create();
	}
}
