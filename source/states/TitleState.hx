package states;

import flixel.math.FlxMath;
import ui.NormalText;
import ui.Frame;
import flixel.FlxSubState;
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
		FlxTween.tween(title, {y: 33, alpha: 1}, 1.2, {
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
					FlxTween.cancelTweensOf(pressAnyKey);

					FlxTween.tween(pressAnyKey, {y: FlxG.height}, .2, {
						ease: FlxEase.sineIn,
						onComplete: (_) ->
						{
							openSubState(new Menu());
						}
					});
					// FlxG.camera.fade(Game.OUR_BLACK, .5, true, () ->
					// {
					// 	Game.CurrentLevel = 0;
					// 	FlxG.switchState(new PlayState());
					// });
				});
			}
		}
	}
}

class Menu extends FlxSubState
{
	private var frame:Frame;

	private var options:Array<NormalText>;
	private var selector:FlxSprite;

	public var alpha(default, set):Float = 1;

	public var selected:Int = 0;

	public var ready:Bool = false;

	override public function create():Void
	{
		var widest:Float = 0;

		options = [];

		var opt:NormalText = new NormalText("PLAY!");
		options.push(opt);

		opt = new NormalText("How to Play");
		options.push(opt);

		opt = new NormalText("Settings");
		options.push(opt);

		opt = new NormalText("Credits");
		options.push(opt);

		selector = new FlxSprite("assets/images/selector.png");

		for (o in options)
		{
			if (o.width > widest)
				widest = o.width;
		}

		frame = new Frame(widest + (selector.width * 2) + 32, options.length * (options[0].height + 2) + 8);
		frame.x = FlxG.width - frame.width - 8;
		frame.y = FlxG.height - frame.height - 8;

		add(frame);

		for (i in 0...options.length)
		{
			opt = options[i];
			opt.x = frame.x + 16 + selector.width;
			opt.y = frame.y + 8 + i * (opt.height + 2);
			opt.color = Game.OUR_BLACK;
			add(opt);
		}
		selector.x = frame.x + 8;
		selector.y = options[0].y + (options[0].height - selector.height) / 2;
		add(selector);

		alpha = 0;

		FlxTween.tween(this, {alpha: 1}, .33, {
			ease: FlxEase.sineOut,
			onComplete: (_) ->
			{
				ready = true;
			}
		});
		super.create();
	}

	function set_alpha(Value:Float):Float
	{
		alpha = FlxMath.bound(Value, 0, 1);
		frame.alpha = selector.alpha = alpha;
		for (o in options)
			o.alpha = alpha;
		return alpha;
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (!ready)
			return;

		if (Actions.upUI.triggered && !Actions.downUI.triggered)
		{
			selected--;
			if (selected < 0)
				selected = options.length - 1;
			selector.y = options[selected].y + (options[selected].height - selector.height) / 2;
		}
		else if (Actions.downUI.triggered && !Actions.upUI.triggered)
		{
			selected++;
			if (selected > options.length - 1)
				selected = 0;
			selector.y = options[selected].y + (options[selected].height - selector.height) / 2;
		}
		else if (Actions.any.triggered)
		{
			ready = false;

			switch (selected)
			{
				case 0:
					FlxG.camera.fade(Game.OUR_BLACK, .5, false, () ->
					{
						Game.CurrentLevel = 0;
						FlxG.switchState(new PlayState());
					});
				case 1:
					openSubState(new HowToPlayState(returnFromSubState));
				case 2:
				// openSubState(new Settings());
				// break;
				case 3:
					FlxG.camera.fade(Game.OUR_BLACK, .5, false, () ->
					{
						FlxG.switchState(new CreditsState());
					});
			}

		}
	}

	private function returnFromSubState():Void
	{
		ready = true;
	}
}