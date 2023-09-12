package axollib;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.system.FlxAssets;
import flixel.system.FlxSound;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxAxes;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxDirectionFlags;
import flixel.util.FlxTimer;
import openfl.display.BitmapData;
import openfl.display.ShaderParameter;

using flixel.util.FlxSpriteUtil;

class DissolveState extends FlxTransitionableState
{
	private var baseColors:Array<FlxColor>;
	private var baseBitmapData:BitmapData;
	private var baseImage:FlxSprite;
	private var displayImage:FlxSprite;
	private var timer:Float = .25;
	private var shiftNo:Int = 0;
	private var timer2:Float = 0;
	private var timer3:Float = 1;

	private var strokeImage:FlxSprite;
	private var strokeBitmapData:BitmapData;
	private var strokeColors:Array<FlxColor>;

	private var madeinstlouis:FlxSprite;

	private var stage:Int = -1;

	private var parts:Array<Part>;

	private var checkedResolution:Bool = false;

	private var ohyeah:FlxSound;
	private var flixel:FlxSound;

	private var _times:Array<Float>;
	private var _sprite:FlxSprite;

	private var _text:FlxSprite;
	private var _curPart:Int = 0;

	private var _colors:Array<Int>;
	private var _functions:Array<Void->Void>;

	private var scale:Float;

	private var barColors:Array<FlxColor> = [
		0xff000000,
		0xffff00ff,
		0xff0000ff,
		0xff00ffff,
		0xff00ff00,
		0xffffff00,
		0xffff0000
	];
	private var bars:Array<FlxSprite> = new Array<FlxSprite>();


	private var dissolver:Dissolver = new Dissolver();

	private var screenWidth:Int;
	private var screenHeight:Int;
	

	public function new() {
		bgColor = FlxColor.WHITE;

		super(null, new TransitionData(TransitionType.FADE, FlxColor.WHITE, .66));

		FlxG.autoPause = false;
		#if mouse
		FlxG.mouse.visible = false;
		#end
	}

	override public function destroy():Void {
		baseColors = [];
		baseBitmapData = FlxDestroyUtil.dispose(baseBitmapData);
		baseImage = FlxDestroyUtil.destroy(baseImage);
		displayImage = FlxDestroyUtil.destroy(displayImage);
		strokeImage = FlxDestroyUtil.destroy(strokeImage);
		strokeBitmapData = FlxDestroyUtil.dispose(strokeBitmapData);
		madeinstlouis = FlxDestroyUtil.destroy(madeinstlouis);
		ohyeah = FlxDestroyUtil.destroy(ohyeah);
		strokeColors = [];
		for (p in parts) {
			p = null;
		}
		parts = [];

		super.destroy();
	}

	override public function create():Void {
		FlxG.autoPause = false;

		if (AxolAPI.init != null) {
			AxolAPI.init();
		}

		baseImage = new FlxSprite();
		baseImage.loadGraphic("axollib/images/color-logo.png", false);

		baseImage.screenCenter();

		scale = .15 / (baseImage.width / FlxG.width);
		screenWidth = Std.int(FlxG.width / scale);
		screenHeight = Std.int(FlxG.height / scale);

		camera.setScale(scale, scale);

		strokeImage = new FlxSprite();
		strokeImage.loadGraphic("axollib/images/color-stroke.png", false);

		baseColors = [0xffff00ff, 0xff0000ff, 0xff00ffff, 0xff00ff00, 0xffffff00, 0xffff0000];

		strokeColors = [0xff000000, 0xff000000, 0xff000000, 0xff000000, 0xff000000, 0xff000000];

		displayImage = new FlxSprite();
		displayImage.makeGraphic(Std.int(baseImage.width), Std.int(baseImage.height + 50), 0x00000000);
		displayImage.x = baseImage.x;
		displayImage.y = baseImage.y - 50;
		add(displayImage);

		madeinstlouis = new FlxSprite();
		madeinstlouis.loadGraphic("axollib/images/madeinstlouis.png", false);
		madeinstlouis.screenCenter(FlxAxes.X);
		madeinstlouis.y = displayImage.y + displayImage.height + 10;
		madeinstlouis.alpha = 0;
		add(madeinstlouis);

		baseBitmapData = baseImage.pixels.clone();
		strokeBitmapData = strokeImage.pixels.clone();

		parts = new Array<Part>();
		for (y in 0...baseBitmapData.height) {
			for (x in 0...baseBitmapData.width) {
				var c = baseBitmapData.getPixel32(x, y);
				if (c != 0 && c != 0xff000000) {
					var p = new Part(x, y + 50);
					parts.push(p);
				}
			}
		}

		displayImage.pixels.fillRect(displayImage.pixels.rect, 0x00000000);

		ohyeah = new FlxSound();
		ohyeah.loadEmbedded("axollib/sounds/madeinstl.wav");
		ohyeah.volume = .5;

		flixel = new FlxSound();
		flixel.loadEmbedded(FlxAssets.getSound("flixel/sounds/flixel"));
		flixel.volume = .5;

		_times = [0.041, 0.184, 0.334, 0.495, 0.636];
		_colors = [0x00b922, 0xffc132, 0xf5274e, 0x3641ff, 0x04cdfb];
		_functions = [drawGreen, drawYellow, drawRed, drawBlue, drawLightBlue];

		_sprite = new FlxSprite();
		_sprite.makeGraphic(40, 40, 0x00000000);
		// _sprite.frames = GraphicsCache.loadAtlasFrames("axollib/images/haxeflixel-logo-anim.png", "axollib/images/haxeflixel-logo-anim.xml", false,
		// 	"haxeflixel-logo");
		// _sprite.animation.frameName = "haxeflixel-01.png";
		// _sprite.scale.set(0.5, 0.5);
		// _sprite.updateHitbox();
		// _sprite.visible = false;

		_sprite.screenCenter(FlxAxes.XY);

		_text = new FlxSprite();
		_text.loadGraphic("axollib/images/haxeflixel-text.png", false);
		_text.scale.set(0.5, 0.5);
		_text.updateHitbox();
		_text.screenCenter(FlxAxes.X);

		_text.y = _sprite.y + _sprite.height + 10;

		_text.visible = false;

		add(_sprite);
		add(_text);

		buildBars();

		// trace(camera.height, FlxG.height, camera.height * scale, camera.height / scale);

		new FlxTimer().start(.25, (_) ->
		{
			spreadBars();
			
		});

		new FlxTimer().start(1, (_) ->
		{
			addGuys();
			startFlixel();
		});

		super.create();
	}

	private function addGuys():Void
	{
		var guy:Guy = new Guy("guy");
		guy.x = (FlxG.width / 2) - (screenWidth / 2) - guy.width - 60;
		guy.y = (FlxG.height / 2) - (screenHeight / 2) + 24;
		add(guy);

		guy = new Guy("sting");
		guy.x = (FlxG.width / 2) + (screenWidth / 2) + 60;
		guy.y = (FlxG.height / 2) + (screenHeight / 2) - guy.height - 24;
		add(guy);
	}

	private function spreadBars():Void
	{
		for (i in 0...Std.int(bars.length / 2))
		{
			var bar:FlxSprite = bars[i * 2];
			var offset:Float = (bars.length / 2) - 1 - i;

			FlxTween.tween(bar, {y: (bar.y - bar.height) + (offset * 4)}, .25, {type: FlxTweenType.ONESHOT, ease: FlxEase.quadOut, startDelay: offset * .1});

			bar = bars[(i * 2) + 1];

			FlxTween.tween(bar, {y: (bar.y + bar.height) - (offset * 4)}, .25, {type: FlxTweenType.ONESHOT, ease: FlxEase.quadOut, startDelay: offset * .1});

		}
	}

	private function closeBars():Void
	{
		for (i in 0...Std.int(bars.length / 2))
		{
			var bar:FlxSprite = bars[i * 2];
			// var offset:Float = (bars.length / 2) - 1 - i;

			FlxTween.tween(bar, {y: (FlxG.height / 2) - bar.height}, .25, {type: FlxTweenType.ONESHOT, ease: FlxEase.quadOut, startDelay: i * .1});

			bar = bars[(i * 2) + 1];

			FlxTween.tween(bar, {y: (FlxG.height / 2)}, .25, {type: FlxTweenType.ONESHOT, ease: FlxEase.quadOut, startDelay: i * .1});
		}
	}

	private function buildBars():Void
	{
		var bar:FlxSprite;
		for (i in 0...barColors.length)
		{
			bar = new FlxSprite();
			bar.makeGraphic(screenWidth, Std.int(screenHeight / 2), barColors[barColors.length - 1 - i]);
			bar.x = (FlxG.width / 2) - (bar.width / 2);
			bar.y = (FlxG.height / 2) - bar.height;
			bars.push(bar);
			add(bar);

			bar = new FlxSprite();
			bar.makeGraphic(screenWidth, Std.int(screenHeight / 2), barColors[barColors.length - 1 - i]);
			bar.x = (FlxG.width / 2) - (bar.width / 2);
			bar.y = (FlxG.height / 2);
			bars.push(bar);
			add(bar);
		}
	}


	private function startFlixel():Void
	{
		flixel.play();

		for (time in _times)
		{
			new FlxTimer().start(time, timerCallback);
		}


	}

	function timerCallback(Timer:FlxTimer):Void
	{
		_functions[_curPart]();
		_text.color = _colors[_curPart];
		_curPart++;

		if (_curPart == 5)
		{
			_sprite.shader = dissolver;
			dissolver.percent = 0;

			// dissolver.fromColor = FlxColor.TRANSPARENT;

			_text.shader = dissolver;

			// Make the logo a tad bit longer, so our users fully appreciate our hard work :D
			FlxTween.tween(dissolver, {percent: 1}, 0.5, {startDelay: 1, ease: FlxEase.quadOut, onComplete: onComplete});
			// FlxTween.tween(_text, {alpha: 0}, 0.5, {startDelay: 1, ease: FlxEase.quadOut});
		}
	}

	function drawGreen():Void
	{
		_sprite.visible = _text.visible = true;
		_sprite.drawPolygon([
			FlxPoint.weak(20, 5),
			FlxPoint.weak(21, 5),
			FlxPoint.weak(35, 20),
			FlxPoint.weak(35, 21),
			FlxPoint.weak(21, 35),
			FlxPoint.weak(20, 35),
			FlxPoint.weak(5, 21),
			FlxPoint.weak(5, 20),
			FlxPoint.weak(20, 5),
		], 0xff00b922, {
			thickness: 0,
			color: 0xff00b922
		}, {smoothing: true});

	}

	function drawYellow():Void
	{
		_sprite.drawPolygon([
			FlxPoint.weak(0, 0),
			FlxPoint.weak(10, 0),
			FlxPoint.weak(20, 5),
			FlxPoint.weak(5, 20),
			FlxPoint.weak(0, 10),
			FlxPoint.weak(0, 0)
		], 0xffffc132, {
			thickness: 0,
			color: 0xffffc132
		}, {smoothing: true});
	}

	function drawRed():Void
	{
		_sprite.drawPolygon([
			FlxPoint.weak(40, 0),
			FlxPoint.weak(30, 0),
			FlxPoint.weak(21, 5),
			FlxPoint.weak(35, 20),
			FlxPoint.weak(40, 10),
			FlxPoint.weak(40, 0)
		], 0xfff5274e, {
			thickness: 0,
			color: 0xfff5274e
		}, {smoothing: true});
	}

	function drawBlue():Void
	{
		_sprite.drawPolygon([
			FlxPoint.weak(0, 40),
			FlxPoint.weak(10, 40),
			FlxPoint.weak(20, 35),
			FlxPoint.weak(5, 21),
			FlxPoint.weak(0, 30),
			FlxPoint.weak(0, 40)
		], 0xff3641ff, {
			thickness: 0,
			color: 0xff3641ff
		}, {smoothing: true});
	}

	function drawLightBlue():Void
	{
		_sprite.drawPolygon([
			FlxPoint.weak(40, 40),
			FlxPoint.weak(30, 40),
			FlxPoint.weak(21, 35),
			FlxPoint.weak(35, 21),
			FlxPoint.weak(40, 30),
			FlxPoint.weak(40, 40)
		], 0xff04cdfb, {
			thickness: 0,
			color: 0xff04cdfb
		}, {smoothing: true});
	}

	function onComplete(Tween:FlxTween):Void
	{
		_sprite.kill();
		_text.kill();

		var t:FlxTimer = new FlxTimer().start(.25, (_) ->
		{
			startAxol();
		});
	}

	private function startAxol():Void
	{
		stage = 0;
		new FlxTimer().start(.55, function(_)
		{
			ohyeah.play();
		});

	}

	private function colorStroke():Void {
		for (y in 0...Std.int(strokeBitmapData.height)) {
			for (x in 0...Std.int(strokeBitmapData.width)) {
				var color:FlxColor = strokeBitmapData.getPixel32(x, y);
				var c:Int = -1;
				if (color != 0 && color != 0xff000000) {
					for (j in 0...baseColors.length) {
						if (color == baseColors[j])
							c = j;
					}
				}
				if (c != -1) {
					if (y + 50 < displayImage.height)
						displayImage.pixels.setPixel32(x, y + 50, strokeColors[c]);
				}
			}
		}
		displayImage.dirty = true;
	}

	private function shiftColors():Void {
		if (shiftNo < 6) {
			strokeColors.pop();
			strokeColors.unshift(baseColors[shiftNo]);
			shiftNo++;
			colorStroke();
		} else if (shiftNo < 12) {
			strokeColors.pop();
			strokeColors.unshift(baseColors[5 - (shiftNo - 6)]);
			shiftNo++;
			colorStroke();
		} else if (shiftNo < 18) {
			strokeColors.pop();
			strokeColors.unshift(baseColors[0xff000000]);
			shiftNo++;
			colorStroke();
		} else if (shiftNo == 18) {
			shiftNo++;
			stage = 2;
		}
	}

	private function checkResolution():Void {
		checkedResolution = true;
	}

	override public function update(elapsed:Float):Void {
		if (!checkedResolution)
			checkResolution();


		if (stage == 0) {
			timer -= elapsed;
			if (timer <= 0) {
				timer = .02;
				stage = 1;

				// d.play();
			}
		} else if (stage == 1) {
			timer -= elapsed;
			if (timer <= 0) {
				timer = .01;

				displayImage.pixels.fillRect(displayImage.pixels.rect, 0x00000000);
				var anyNotDone:Bool = false;
				for (p in parts) {
					p.update();
					if (p.done) {
						displayImage.pixels.setPixel32(Std.int(p.x), Std.int(p.y), FlxColor.fromRGB(255, 255, 255, Std.int(p.alpha)));
					} else {
						displayImage.pixels.setPixel32(Std.int(p.x), Std.int(p.y), FlxColor.fromHSB(p.hue, 1, 1, Std.int(p.alpha)));
						anyNotDone = true;
					}
				}
				displayImage.dirty = true;
			}
		} else if (stage == 2) {
			for (p in parts)
				p.switchMode();
			timer = 1.5;
			stage = 3;
			FlxTween.tween(madeinstlouis, {alpha: 1}, .5, {type: FlxTweenType.ONESHOT, ease: FlxEase.sineIn});
		} else if (stage == 3) {
			timer -= elapsed;
			if (timer <= 0) {
				timer = .002;

				displayImage.pixels.fillRect(displayImage.pixels.rect, 0x00000000);
				var anyNotDone:Bool = false;
				for (p in parts) {
					p.update();

					displayImage.pixels.setPixel32(Std.int(p.x), Std.int(p.y), FlxColor.fromRGB(255, 255, 255, Std.int(p.alpha)));
					for (i in 0...5) {
						if (p.y + i < p.destY) {
							displayImage.pixels.setPixel32(Std.int(p.x), Std.int(p.y + i), FlxColor.fromRGB(255, 255, 255, Std.int(p.alpha - (i * 20))));
						}
					}

					if (!p.done && p.alpha > 0)
						anyNotDone = true;
				}
				displayImage.dirty = true;
				if (!anyNotDone) {
					stage = 4;
					timer = .33;
				}
			}
		} else if (stage == 4) {
			timer -= elapsed;
			if (timer <= 0) {
				displayImage.pixels.fillRect(displayImage.pixels.rect, 0x00000000);
				stage = 5;
				closeBars();
				new FlxTimer().start(1, (_) ->
				{
					FlxG.switchState(cast Type.createInstance(AxolAPI.firstState, []));
				});

				
			}
		}

		if (stage > 0)
		{
			if (timer3 > 0)
			{
				timer3 -= elapsed;
			}
			else if (shiftNo <= 18)
			{
				timer2 -= elapsed;
				if (timer2 <= 0)
				{
					timer2 = .025;
					shiftColors();
				}
			}
		}
		super.update(elapsed);
	}
}

class Guy extends FlxSprite
{
	public function new(?Which:String = "guy"):Void
	{
		super();
		loadGraphic("axollib/images/agents.png", true, 12, 12, false, "guy");
		animation.add("guy", [0, 1, 2, 3], 10, true);
		animation.add("sting", [4, 5, 6, 7], 10, true);
		animation.play(Which);
		setFacingFlip(FlxDirectionFlags.LEFT, true, false);
		setFacingFlip(FlxDirectionFlags.RIGHT, false, false);
		if (Which == "guy")
		{
			facing = FlxDirectionFlags.RIGHT;
			velocity.x = 65;
		}
		else
		{
			facing = FlxDirectionFlags.LEFT;
			velocity.x = -65;
		}

	}
}

class Dissolver extends FlxShader
{
	public var percent(default, set):Float;

	public var fromColor(default, set):Null<FlxColor> = null;

	@:glFragmentSource('
        #pragma header

        uniform bool useFrom;
        uniform vec4 fColor;
		uniform float pct;
        
		uniform vec2 u_resolution;

		float rand (vec2 co) {
    		return fract(sin(dot(co.xy ,vec2(12.9898,96.233))) * 43758.5453);
		}

        void main()
        {
			
			
			vec4 source = flixel_texture2D(bitmap, openfl_TextureCoordv);

			float alpha = source.a * step(pct, rand(openfl_TextureCoordv));

			if(source.a <= 0. || alpha <= 0.) discard;
            
			vec4 sample = source;

            if (useFrom)
            {    
				sample = fColor;
			}

			gl_FragColor = vec4(sample.rgb, alpha);


        }


    
    ')
	public function new():Void
	{
		super();
		data.useFrom.value = [false];
	}

	private function set_percent(Value:Float):Float
	{
		percent = FlxMath.bound(Value, 0, 1);

		data.pct.value = [percent];
		return percent;
	}

	private function set_fromColor(Value:FlxColor):FlxColor
	{
		fromColor = Value;
		if (fromColor == null)
		{
			data.useFrom.value = [false];
		}
		else
		{
			useFrom.value = [true];
			data.fColor.value = [
				fromColor.redFloat,
				fromColor.greenFloat,
				fromColor.blueFloat,
				fromColor.alphaFloat
			];
		}
		return fromColor;
	}
}