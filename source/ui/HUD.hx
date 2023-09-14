package ui;

import flixel.text.FlxText;
import flixel.FlxG;
import flixel.graphics.frames.FlxBitmapFont;
import flixel.math.FlxMath;
import flixel.util.FlxAxes;
import axollib.GraphicsCache;
import states.PlayState;
import flixel.text.FlxBitmapText;
import flixel.FlxSprite;
import flixel.group.FlxGroup;

class HUD extends FlxGroup
{
	public var hearts:Array<UIHeart>;
	public var stars:Array<UIStar>;

	public var meter:FlxSprite;
	public var position:FlxSprite;
	public var flag:FlxSprite;

	public var score:FlxBitmapText;
	public var combo:FlxBitmapText;

	public var state:PlayState;

	private var posStart:Float;
	private var posEnd:Float;

	public function new(State:PlayState):Void
	{
		super();

		state = State;

		hearts = [];
		for (i in 0...5)
		{
			var heart = new UIHeart();
			heart.x = i * 10;
			heart.y = -2;
			hearts.push(heart);
			add(heart);
		}

		stars = [];
		for (i in 0...5)
		{
			var star = new UIStar();
			star.x = i * 10;
			star.y = 8;
			stars.push(star);
			add(star);
		}

		add(meter = new FlxSprite("assets/images/meter.png"));
		meter.y = 8;
		meter.screenCenter(FlxAxes.X);
		meter.scrollFactor.set();

		add(flag = new FlxSprite("assets/images/flag.png"));
		flag.y = meter.y + (meter.height / 2) - flag.height;
		flag.x = meter.x + (meter.width) - 10;
		flag.scrollFactor.set();

		posStart = meter.x + 8;
		posEnd = meter.x + (meter.width) - 8;

		add(position = new FlxSprite("assets/images/position.png"));
		position.y = meter.y + (meter.height / 2) - position.height;
		position.x = posStart - (position.width / 2);
		position.scrollFactor.set();

		add(score = new FlxBitmapText(FlxBitmapFont.fromAngelCode("assets/images/fat_numbers.png", "assets/images/fat_numbers.xml")));
		score.autoSize = false;
		score.fieldWidth = 80;
		score.y = 2;
		score.x = FlxG.width - 82;
		score.alignment = FlxTextAlign.RIGHT;
		score.text = "0";
		score.scrollFactor.set();

		add(combo = new FlxBitmapText(FlxBitmapFont.fromAngelCode("assets/images/small_fat_numbers.png", "assets/images/small_fat_numbers.xml")));
		combo.autoSize = false;
		combo.fieldWidth = 80;
		combo.y = score.y + score.height + 2;
		combo.x = FlxG.width - 82;
		combo.alignment = FlxTextAlign.RIGHT;
		combo.text = "x0";
		combo.scrollFactor.set();
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		for (i in 0...hearts.length)
		{
			hearts[i].full = i < state.player.health;
		}

		for (i in 0...stars.length)
			stars[i].full = i < state.player.energy;

		position.x = posStart + ((posEnd - posStart) * FlxMath.bound((state.levelDistance / state.levelDistanceMax), 0, 1)) - (position.width / 2);
		position.y = meter.y
			+ (meter.height / 2)
			- position.height
			- (Std.int(FlxMath.bound((state.levelDistance / state.levelDistanceMax), 0, 1) * 500) % 2);

		score.text = '${state.player.score}';
		combo.text = state.player.combo > 1 ? 'x${state.player.combo}' : "";
	}
}

class UIHeart extends FlxSprite
{
	public var full(default, set):Bool = true;

	public function new()
	{
		super();

		scrollFactor.set();

		frames = GraphicsCache.loadAtlasFrames("assets/images/hud_heart.png", "assets/images/hud_heart.xml", false, "hud_heart");
		animation.frameName = "heart_filled";
	}

	private function set_full(Value:Bool):Bool
	{
		if (full != Value)
		{
			full = Value;
			animation.frameName = full ? "heart_filled" : "heart_empty";
		}
		return full;
	}
}

class UIStar extends FlxSprite
{
	public var full(default, set):Bool = false;

	public function new()
	{
		super();

		scrollFactor.set();

		frames = GraphicsCache.loadAtlasFrames("assets/images/hud_star.png", "assets/images/hud_star.xml", false, "hud_star");
		animation.frameName = "star_empty";
	}

	private function set_full(Value:Bool):Bool
	{
		if (full != Value)
		{
			full = Value;
			animation.frameName = full ? "star_filled" : "star_empty";
		}
		return full;
	}
}