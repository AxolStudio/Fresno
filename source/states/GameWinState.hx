package states;

import flixel.util.typeLimit.OneOfTwo;
import flixel.FlxSubState;
import globals.Actions;
import flixel.FlxG;
import flixel.math.FlxMath;
import flixel.tweens.FlxTween;
import flixel.util.FlxAxes;
import ui.Frame;
import flixel.graphics.frames.FlxBitmapFont;
import flixel.text.FlxBitmapText;
import flixel.FlxSprite;
import ui.RainbowText;
import globals.Game;
import ui.NormalText;
import openfl.utils.Object;
import axollib.AxolAPI;
import flixel.FlxState;

class GameWinState extends FlxState
{
	public var scoresReady:Bool = false;

	public var letters:Array<String> = [
		" ", "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "0", "1", "2",
		"3", "4", "5", "6", "7", "8", "9", "!"
	];

	private var scoresLeft:Array<NormalText> = [];
	private var scoresRight:Array<NormalText> = [];

	private var playerTotal:Int = 0;

	private var submitScoreMsg:NormalText;
	private var inits:Array<NormalText> = [];
	private var whichInit:Int = 0;
	private var initVals:Array<Int> = [0, 0, 0];
	private var cursor:FlxSprite;
	private var title:FlxBitmapText;
	private var frameWidth:Float = 0;
	private var frameHeight:Float = 0;
	private var frame:InnerFrame;

	private var ready:Bool = false;

	private var end:FlxSprite;

	public var alpha(default, set):Float = 0;

	override public function create():Void
	{
		// get the current hiscores

		title = new FlxBitmapText(FlxBitmapFont.fromAngelCode("assets/images/fat_text.png", "assets/image/fat_text.xml"));
		title.text = "You Win!";
		title.alpha = 0;

		frameWidth = title.width;
		frameHeight = 12 + title.height;

		// show the player's score breakdown for each level

		var scoreL:NormalText;
		var scoreR:NormalText;
		var scoreAmt:Int = 0;
		for (i in 0...3)
		{
			scoreAmt = Game.Scores.get(i);
			scoreL = new NormalText(switch (i)
			{
				case 0: "Forest";
				case 1: "Suburbs";
				case 2: "City";
				default:
					"";
			});

			scoreR = new NormalText(Std.string(scoreAmt));
			scoreL.alpha = 0;
			scoreR.alpha = 0;
			scoresLeft.push(scoreL);
			scoresRight.push(scoreR);
			playerTotal += scoreAmt;
		}

		scoreL = new NormalText("Total");
		scoreL.alpha = 0;
		scoresLeft.push(scoreL);

		scoreR = new NormalText(Std.string(playerTotal));
		scoreR.alpha = 0;
		scoresRight.push(scoreR);

		var scoresWidth:Float = 0;
		for (s in 0...scoresLeft.length)
		{
			scoresWidth = Math.min(scoresLeft[s].width + scoresRight[s].width + 10, FlxG.width - 64);
			frameHeight += scoresLeft[s].height;
		}

		submitScoreMsg = new NormalText("Submit Your Score");
		submitScoreMsg.alpha = 0;

		initVals = [Game.RememberInits[0], Game.RememberInits[1], Game.RememberInits[2]];

		var init:NormalText;
		init = new NormalText("X");
		init.alpha = 0;
		inits.push(init);

		init = new NormalText("X");
		init.alpha = 0;
		inits.push(init);

		init = new NormalText("X");
		init.alpha = 0;
		inits.push(init);

		cursor = new FlxSprite();
		cursor.loadGraphic("assets/images/cursor.png", true, 15, 17, false, "cursor");
		cursor.animation.add("blink", [0, 1], 10, true);
		cursor.animation.play("blink");
		cursor.visible = false;

		frameHeight += submitScoreMsg.height + 4 + 4 + inits[0].height + 4;

		end = new FlxSprite("assets/images/end.png");
		end.alpha = 0;

		frame = new InnerFrame(frameWidth + 32 + 12, frameHeight);
		frame.screenCenter(FlxAxes.X);
		frame.y = 8;
		frame.alpha = 0;
		add(frame);

		title.screenCenter(FlxAxes.X);
		title.y = frame.y + 3;
		add(title);

		for (s in 0...scoresLeft.length)
		{
			scoresLeft[s].x = frame.x + 3;
			scoresRight[s].x = frame.x + frame.width - scoresRight[s].width - 3;
			scoresRight[s].y = scoresLeft[s].y = title.y + title.height + 2 + (scoresLeft[s].height * s);
			add(scoresLeft[s]);
			add(scoresRight[s]);
		}

		submitScoreMsg.screenCenter(FlxAxes.X);
		submitScoreMsg.y = scoresLeft[scoresLeft.length - 1].y + scoresLeft[scoresLeft.length - 1].height + 4;
		add(submitScoreMsg);

		var w:Float = 16;
		var space:Float = 4;
		var totalWidth:Float = (w * 4) + (space * 3);
		var startX:Float = (FlxG.width / 2) - (totalWidth / 2);
		trace(startX, totalWidth);
		for (i in 0...inits.length)
		{
			inits[i].x = startX + (w * i) + (space * i) + ((w - inits[i].width) / 2);

			inits[i].text = letters[initVals[i]];
			inits[i].y = submitScoreMsg.y + submitScoreMsg.height + 4;
			add(inits[i]);
		}

		end.x = inits[2].x + w + space;
		end.y = inits[2].y;
		add(end);

		setCursor(0);
		add(cursor);

		FlxTween.tween(this, {alpha: 1}, .5, {
			onComplete: (_) ->
			{
				cursor.visible = true;
				ready = true;
			}
		});
		super.create();
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (!ready)
			return;

		var left:Bool = Actions.leftUI.triggered;
		var right:Bool = Actions.rightUI.triggered;
		var up:Bool = Actions.upUI.triggered;
		var down:Bool = Actions.downUI.triggered;
		var any:Bool = Actions.any.triggered;

		if (left && right)
			left = right = false;
		if (up && down)
			up = down = false;
		if ((left || right) && (up || down))
			left = right = false;
		if (up)
			changeLetter(-1);
		else if (down)
			changeLetter(1);
		else if (right)
		{
			if (whichInit < 3)
				setCursor(whichInit + 1);
			else
				setCursor(0);
		}
		else if (left)
		{
			if (whichInit > 0)
				setCursor(whichInit - 1);
			else
				setCursor(3);
		}
		else if (any)
		{
			if (whichInit < 3)
				setCursor(whichInit + 1)
			else
				submit();
		}
	}

	private function changeLetter(Amount:Int):Void
	{
		if (whichInit == 3)
			return;
		initVals[whichInit] += Amount;
		if (initVals[whichInit] < 0)
			initVals[whichInit] = letters.length - 1;
		else if (initVals[whichInit] >= letters.length)
			initVals[whichInit] = 0;

		inits[whichInit].text = letters[initVals[whichInit]];
	}

	private function submit():Void
	{
		ready = false;

		Game.RememberInits = [initVals[0], initVals[1], initVals[2]];
		AxolAPI.sendScore(playerTotal, inits[0].text + inits[1].text + inits[2].text, scoreSent);
	}

	private function scoreSent(Msg:Object):Void
	{
		FlxTween.tween(this, {alpha: 0}, .5, {
			onComplete: (_) ->
			{
				openSubState(new HiScoreState(Msg));
			}
		});
	}

	private function setCursor(Which:Int):Void
	{
		whichInit = Which;
		if (whichInit == 3)
		{
			cursor.x = end.x - 5;
			cursor.y = end.y - 5;
		}
		else
		{
			cursor.x = inits[whichInit].x - 5;
			cursor.y = inits[whichInit].y - 5;
		}
	}

	function set_alpha(Value:Float):Float
	{
		alpha = FlxMath.bound(Value, 0, 1);

		frame.alpha = alpha;

		for (s in 0...scoresLeft.length)
		{
			scoresRight[s].alpha = scoresLeft[s].alpha = alpha;
		}

		title.alpha = alpha;
		submitScoreMsg.alpha = alpha;

		for (i in inits)
		{
			i.alpha = alpha;
		}

		end.alpha = alpha;
		cursor.alpha = alpha;

		return alpha;
	}
}

class HiScoreState extends FlxSubState
{
	var frame:InnerFrame;
	var title:FlxBitmapText;
	var scoresLeft:Array<OneOfTwo<NormalText, RainbowText>> = [];
	var scoresRight:Array<OneOfTwo<NormalText, RainbowText>> = [];
	var scores:Array<Object>;
	var exitText:NormalText;
	var hiSlot:Int = -1;

	public var alpha(default, set):Float = 0;

	var ready:Bool = false;

	public function new(Msg:Object):Void
	{
		super();
		trace(Msg);
		scores = Msg.data.scores.scores;
		hiSlot = Std.parseInt(Msg.data.scores.lastId);
	}

	override public function create():Void
	{
		FlxG.camera.pixelPerfectRender = true;

		title = new FlxBitmapText(FlxBitmapFont.fromAngelCode("assets/images/fat_text.png", "assets/image/fat_text.xml"));
		title.text = "Hi-Scores";
		title.screenCenter(FlxAxes.X);
		title.alpha = 0;

		var frameHeight:Float = title.height + 12;
		var scoreL:OneOfTwo<NormalText, RainbowText>;
		var scoreR:OneOfTwo<NormalText, RainbowText>;

		var score:Object;
		var showedMe:Bool = false;
		for (s in 0...10)
		{
			if (scores.length <= s)
				break;
			score = scores[s];
			trace(hiSlot, score.id);
			if (hiSlot == score.id)
			{
				showedMe = true;
				scoreL = new RainbowText('${score.position}: ${score.initials}');
				scoreR = new RainbowText(Std.string(score.amount));
			}
			else
			{
				scoreL = new NormalText('${score.position}: ${score.initials}');
				scoreR = new NormalText(Std.string(score.amount));
			}
			cast(scoreL, NormalText).alpha = 0;
			cast(scoreR, NormalText).alpha = 0;
			scoresLeft.push(scoreL);
			scoresRight.push(scoreR);
			frameHeight += cast(scoreL, NormalText).height;
		}

		if (!showedMe)
		{
			for (s in 10...scores.length)
			{
				if (scores[s].id == hiSlot)
				{
					score = scores[s];
					scoreL = new RainbowText('${score.position}: ${score.initials}');
					scoreR = new RainbowText(Std.string(score.amount));
					cast(scoreL, NormalText).alpha = 0;
					cast(scoreR, NormalText).alpha = 0;
					scoresLeft.push(scoreL);
					scoresRight.push(scoreR);
					frameHeight += cast(scoreL, NormalText).height;
				}
			}
		}

		exitText = new NormalText("Press Any Key to Quit");
		exitText.alpha = 0;
		frameHeight += exitText.height;

		frame = new InnerFrame(title.width + 32 + 12, frameHeight);
		frame.screenCenter(FlxAxes.X);
		frame.y = 8;
		frame.alpha = 0;
		add(frame);

		title.y = frame.y + 3;
		add(title);

		for (s in 0...scoresLeft.length)
		{
			cast(scoresLeft[s], NormalText).x = frame.x + 3;
			cast(scoresRight[s], NormalText).x = frame.x + frame.width - cast(scoresRight[s], NormalText).width - 3;
			cast(scoresRight[s], NormalText).y = cast(scoresLeft[s], NormalText).y = title.y + title.height + 2 + (cast(scoresLeft[s], NormalText).height * s);
			add(cast(scoresLeft[s], NormalText));
			add(cast(scoresRight[s], NormalText));
		}

		exitText.screenCenter(FlxAxes.X);
		exitText.y = cast(scoresLeft[scoresLeft.length - 1], NormalText).y + cast(scoresLeft[scoresLeft.length - 1], NormalText).height + 4;
		add(exitText);

		FlxTween.tween(this, {alpha: 1}, .5, {
			onComplete: (_) ->
			{
				ready = true;
			}
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

	private function set_alpha(Value:Float):Float
	{
		alpha = FlxMath.bound(Value, 0, 1);

		frame.alpha = alpha;

		for (s in 0...scoresLeft.length)
		{
			cast(scoresLeft[s], NormalText).alpha = alpha;
			cast(scoresRight[s], NormalText).alpha = alpha;
		}

		title.alpha = alpha;

		exitText.alpha = alpha;

		return alpha;
	}
}
