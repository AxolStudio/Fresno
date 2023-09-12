package axollib;

// import aseprite.Aseprite;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.system.FlxAssets;
import flixel.system.FlxSound;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import openfl.Lib;

using flixel.graphics.FlxAsepriteUtil;

class NewIntro extends FlxTransitionableState
{
	private var ohyeah:FlxSound;
	private var flixel:FlxSound;
	// private var intro:aseprite.Aseprite;
	private var intro:FlxSprite;


	public function new()
	{
		super(null, new TransitionData(TransitionType.FADE, FlxColor.WHITE, .66));


		bgColor = FlxColor.BLACK;

		FlxG.autoPause = false;
		#if mouse
		FlxG.mouse.visible = false;
		#end
	}

	override public function create():Void
	{
		FlxG.autoPause = false;

		if (AxolAPI.init != null)
		{
			AxolAPI.init();
		}

		add(intro = new FlxSprite());

		intro.loadAseAtlasAndTagsByIndex("axollib/images/axol-intro.png", "axollib/images/axol-intro.json");

		var stageWidth:Int = FlxG.width; // Lib.current.stage.stageWidth;
		var stageHeight:Int = FlxG.height; // Lib.current.stage.stageHeight;

		// set the camera scale to fit the intro

		FlxG.camera.zoom = Math.min(stageWidth / intro.width, stageHeight / intro.height);

		intro.screenCenter();

		intro.animation.finishCallback = (a:String) ->
		{
			trace("!!!!!");
			intro.animation.stop();
			FlxG.switchState(cast Type.createInstance(AxolAPI.firstState, []));
		}

		ohyeah = new FlxSound();
		ohyeah.loadEmbedded("axollib/sounds/madeinstl.wav");
		ohyeah.volume = .5;

		flixel = new FlxSound();
		flixel.loadEmbedded(FlxAssets.getSound("flixel/sounds/flixel"));
		flixel.volume = .5;

		new FlxTimer().start(.33, (_) ->
		{

			new FlxTimer().start(.5, (_) ->
			{
				
				flixel.play();
			});

			new FlxTimer().start(5.0, (_) ->
			{
				ohyeah.play();
			});

			intro.animation.play("intro-anim");

		});

		super.create();
	}
}