package states;

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

	private var hiScoreMsg:RainbowText;
	private var inits:Array<NormalText> = [];
	private var whichInit:Int = 0;
	private var initVals:Array<Int> = [0, 0, 0];
	private var cursor:FlxSprite;
	private var nextText:NormalText;
	private var title:FlxBitmapText;
	private var frameWidth:Float = 0;
	private var frameHeight:Float = 0;
	private var frame:InnerFrame;

	private var ready:Bool = false;


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

		hiScoreMsg = new RainbowText("* * * New Hi-Score! * * *");
		hiScoreMsg.alpha = 0;

		var init:NormalText;
		init = new NormalText(letters[Game.RememberInits[0]]);
		init.alpha = 0;
		inits.push(init);

		init = new NormalText(letters[Game.RememberInits[1]]);
		init.alpha = 0;
		inits.push(init);

		init = new NormalText(letters[Game.RememberInits[2]]);
		init.alpha = 0;
		inits.push(init);

		nextText = new NormalText("Press Any Key");
		nextText.alpha = 0;

        cursor = new FlxSprite();
        cursor.loadGraphic("assets/images/cursor.png", true, 15, 17, false, "cursor");
        cursor.animation.add("blink", [0,1],10, true);
        cursor.animation.play("blink");
        cursor.visible = false;


		AxolAPI.getScores(scoresGot);

		super.create();
	}

	private function scoresGot(Msg:Object):Void
	{
		var hasHi:Bool = false;
		var hiScoreSlot:Int = -1;
		var hiScores:Array<Object> = Msg.data.scores.scores;

		trace(hiScores);

		for (h in 0...hiScores.length)
		{
			if (hiScores[h].amount <= playerTotal)
			{
				hasHi = true;
				hiScoreSlot = h;
			}
		}

		if (hasHi)
		{
			frameHeight += inits[0].height + hiScoreMsg.height + 12;
			if ((inits[0].width * 3) + 8 > frameWidth)
				frameWidth = (inits[0].width * 3) + 8;
		}
		else
		{
			frameHeight += nextText.height;
		}

		frame = new InnerFrame(frameWidth + 64 + 12, frameHeight);
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

		if (hasHi)
		{
			hiScoreMsg.screenCenter(FlxAxes.X);
			hiScoreMsg.y = scoresLeft[scoresLeft.length - 1].y + scoresLeft[scoresLeft.length - 1].height + 4;

			add(hiScoreMsg);

			for (i in 0...inits.length)
			{
				inits[i].x = (FlxG.width / 2) - (((inits[i].width * 3) + 8) / 2) + (i * (inits[i].width + 4));
				inits[i].y = hiScoreMsg.y + hiScoreMsg.height + 4;
				add(inits[i]);
			}

            setCursor(0);
			add(cursor);
		
		}
		else
		{
			nextText.screenCenter(FlxAxes.X);
			nextText.y = scoresLeft[scoresLeft.length - 1].y + scoresLeft[scoresLeft.length - 1].height + 4;
			add(nextText);
		}

		FlxTween.tween(this, {alpha: 1}, .5, {
			onComplete: (_) ->
			{
				cursor.visible = true;
				ready = true;

			}
		});
	}

    private function setCursor(Which:Int):Void
    {
        whichInit = Which;
        cursor.x = inits[whichInit].x - 5;
        cursor.y = inits[whichInit].y - 5;
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
        hiScoreMsg.alpha = alpha;
        nextText.alpha = alpha;

        for (i in inits)
        {
            i.alpha = alpha;
        }

        return alpha;
    }
}
