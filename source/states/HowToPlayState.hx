package states;

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

class HowToPlayState extends FlxSubState
{
	public var ready:Bool = false;

	public function new(CB:Void->Void)
	{
		super();
		closeCallback = CB;
	}

	override public function create():Void
	{
		bgColor = FlxColor.TRANSPARENT;

		var frame:Frame = new Frame(FlxG.width - 8, FlxG.height - 8);
		frame.screenCenter();
		add(frame);

		var text:NormalText = new NormalText("How to Play");
		text.color = Game.OUR_BLACK;
		text.y = frame.y + 6;
		text.screenCenter(FlxAxes.X);
		add(text);

		var inner:InnerFrame = new InnerFrame(frame.width - 12, frame.height - (text.height - 2) - 12 - 32);
		inner.x = frame.x + 6;
		inner.y = text.y + text.height - 2;
		add(inner);

		var controller:FlxSprite = new FlxSprite("assets/images/controller.png");
		controller.x = inner.x + (inner.width / 4) - (controller.width / 2);
		controller.y = inner.y + (inner.height / 2) - (controller.height / 2);
		add(controller);

		var keyboard:FlxSprite = new FlxSprite("assets/images/kb_controls.png");
		keyboard.x = inner.x + (inner.width / 4) * 3 - (keyboard.width / 2);
		keyboard.y = inner.y + (inner.height / 2) - (keyboard.height / 2);
		add(keyboard);

		var instructions:NormalText = new NormalText("Avoid obstacles to make it home to Fresno before sunrise!\nJump over obstacles to gain Stars. 5 x Stars = reward!");
		instructions.color = Game.OUR_BLACK;
		instructions.autoSize = false;
		instructions.fieldWidth = Std.int(inner.width) - 16;
		instructions.multiLine = true;
		instructions.wordWrap = true;
		instructions.alignment = FlxTextAlign.CENTER;
		instructions.x = inner.x + 3;
		instructions.y = inner.y + inner.height + 2;
		add(instructions);

		ready = true;

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
			close();
		}
	}
}