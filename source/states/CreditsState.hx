package states;

import globals.Actions;
import flixel.FlxG;
import flixel.util.FlxAxes;
import globals.Game;
import flixel.graphics.frames.FlxBitmapFont;
import ui.NormalText;
import flixel.text.FlxBitmapText;
import flixel.FlxSprite;
import flixel.FlxState;

class CreditsState extends FlxState
{
	private var ready:Bool = false;

	public override function create():Void
	{
		FlxG.autoPause = false;
		FlxG.camera.pixelPerfectRender = true;

		bgColor = Game.OUR_BLACK;

		var t:NormalText;

		t = new NormalText("Created by");
		t.screenCenter(FlxAxes.X);
		t.y = 4;
		add(t);

		var logo:FlxSprite = new FlxSprite("assets/images/axol-logo-64px.png");
		logo.screenCenter(FlxAxes.X);
		logo.y = t.height + t.y + 4;
		// logo.y = 2;
		add(logo);

		var t2 = new NormalText("Axol Studio, LLC");
		t2.screenCenter(FlxAxes.X);
		t2.y = logo.y + logo.height + 4;
		add(t2);

		t = new NormalText("Additional Artwork:");
		t.screenCenter(FlxAxes.X);
		t.y = t2.y + t2.height + 8;
		add(t);

		t2 = new NormalText("Dog: NVPH Studio");
		t2.x = (FlxG.width / 4) - (t2.width / 2);
		t2.y = t.y + t.height + 2;
		add(t2);

		t = new NormalText("Animals: Ethen's Pixel Art Shop");
		t.x = (FlxG.width / 4 + FlxG.width / 2) - (t.width / 2);
		t.y = t2.y;
		add(t);

		t2 = new NormalText("Backgrounds & UI: LimeZu");
		t2.x = (FlxG.width / 4) - (t2.width / 2);
		t2.y = t.y + t.height + 2;
		add(t2);

		t = new NormalText("Press Any Key to Go Back");
		t.screenCenter(FlxAxes.X);
		t.y = FlxG.height - t.height - 2;
		add(t);

		t2 = new NormalText("Visit us Online at axolstudio.com");
		t2.screenCenter(FlxAxes.X);
		t2.y = t.y - t2.height - 2;
		add(t2);

		FlxG.camera.fade(Game.OUR_BLACK, .5, true, function()
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
		if (Actions.any.triggered)
		{
			ready = false;
			FlxG.camera.fade(Game.OUR_BLACK, .5, false, function()
			{
				FlxG.switchState(new TitleState());
			});
		}
	}
}
