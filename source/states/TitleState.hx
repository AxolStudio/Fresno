package states;

import flixel.input.actions.FlxActionInput;
import globals.Actions;
import flixel.text.FlxText;
import flixel.graphics.frames.FlxBitmapFont;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import globals.Game;
import flixel.text.FlxBitmapText;
import flixel.FlxG;
import flixel.util.FlxAxes;
import flixel.FlxSprite;
import flixel.FlxState;

class TitleState extends FlxState
{
	private var moon:FlxSprite;
	private var title:FlxSprite;

	public var ready:Bool = false;

	private var pressAnyKey:FlxBitmapText;

	override public function create():Void
	{
		add(new FlxSprite(0, 0, "assets/images/title_back.png"));

		add(moon = new FlxSprite(0, 0, "assets/images/title_moon.png"));

		add(new FlxSprite(0, 0, "assets/images/title_clouds.png"));

		add(title = new FlxSprite(0, 0, "assets/images/title_text.png"));

		moon.screenCenter();
		moon.y -= FlxG.height / 4;

		title.screenCenter();
		title.y += FlxG.height / 4;

		title.alpha = 0;

		add(pressAnyKey = new FlxBitmapText(FlxBitmapFont.fromAngelCode("assets/images/fat_text.png", "assets/images/fat_text.xml")));
		pressAnyKey.alignment = FlxTextAlign.CENTER;
		pressAnyKey.text = "Press Any Key";
		pressAnyKey.screenCenter(FlxAxes.X);
		pressAnyKey.y = FlxG.height;
		pressAnyKey.alpha = 0;

		FlxTween.tween(moon, {y: 27}, 1.2, {ease: FlxEase.sineOut});
		FlxTween.tween(title, {y: 43, alpha: 1}, 1.2, {
			ease: FlxEase.sineOut,
			startDelay: 0.5,
			onComplete: (_) ->
			{
				FlxG.camera.flash(0xff63b556, .5, () ->
				{
					FlxTween.tween(pressAnyKey, {y: FlxG.height - pressAnyKey.height - 20, alpha: 1}, .5, {
						ease: FlxEase.sineOut,
						onComplete: (_) ->
						{
							ready = true;
							FlxTween.tween(pressAnyKey, {y: pressAnyKey.y - 10}, 3, {type: FlxTweenType.PINGPONG, ease: FlxEase.sineInOut});
						}
					});
				});
			}
		});

		FlxG.camera.fade(Game.OUR_BLACK, 1, true);

		super.create();
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (ready)
		{
			if (Actions.any.triggered)
			{
				ready = false;

				FlxG.camera.flash(0xff63b556, .5, () ->
				{
					FlxG.camera.fade(Game.OUR_BLACK, .5, true, () ->
					{
						Game.CurrentLevel = 0;
						FlxG.switchState(new PlayState());
					});
				});
			}
		}
	}
}