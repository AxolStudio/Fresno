package states;

import flixel.FlxState;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.math.FlxMath;
import globals.Actions;
import flixel.text.FlxText;
import haxe.macro.Tools;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.util.FlxAxes;
import ui.NormalText;
import globals.Game;
import ui.Frame;
import flixel.FlxG;
import flixel.FlxSubState;

class HowToPlayState extends FlxState
{

	public var ready:Bool = false;

	public function new()
	{
		super();
	}

	override public function create():Void
	{
		bgColor = FlxColor.TRANSPARENT;
		FlxG.autoPause = false;

		var frame:FlxSprite = new FlxSprite("assets/images/how-to-back.png");
		
		add(frame);

		var text:NormalText = new NormalText("How to Play");
		text.color = Game.OUR_BLACK;
		text.y = frame.y + 6;
		text.screenCenter(FlxAxes.X);
		add(text);

		// inner = new InnerFrame(frame.width - 12, frame.height - (text.height - 2) - 12 - 32);
		// inner.x = frame.x + 6;
		// inner.y = text.y + text.height - 2;
		// add(inner);

		var controller:FlxSprite = new FlxSprite("assets/images/controller.png");
		controller.x = frame.x + 6 + ((frame.width - 12) / 4) - (controller.width / 2);
		controller.y = text.y + text.height - 2 + (126 / 2) - (controller.height / 2);
		add(controller);

		var keyboard:FlxSprite = new FlxSprite("assets/images/kb_controls.png");
		keyboard.x = frame.x + 6 + ((frame.width - 12) / 4) * 3 - (keyboard.width / 2);
		keyboard.y = text.y + text.height - 2 + (126 / 2) - (keyboard.height / 2);
		add(keyboard);

		var instructions:NormalText = new NormalText("Avoid obstacles to make it home to Fresno before sunrise!\nJump over obstacles to gain Stars. 5 x Stars = reward!");
		instructions.color = Game.OUR_BLACK;
		instructions.autoSize = false;
		instructions.fieldWidth = Std.int(frame.width - 12) - 16;
		instructions.multiLine = true;
		instructions.wordWrap = true;
		instructions.alignment = FlxTextAlign.CENTER;
		instructions.x = frame.x + 9;
		instructions.y = text.y + text.height - 2 + 126 + 2;
		add(instructions);

		FlxG.camera.fade(Game.OUR_BLACK, .5, true, () ->
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
			FlxG.camera.fade(Game.OUR_BLACK, .5, false, () ->
			{
				FlxG.switchState(new TitleState());
			});
		}
	}

}