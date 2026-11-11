package axollib;
import flixel.FlxState;
class AxolAPI
{
	public static inline var testMode:Bool = true;
	public static var firstState:Class<FlxState>;
	public static var init:Void->Void;
	public static function initialize(game:String = "", player:String = ""):Void {}
	public static function sendEvent(name:String, value:Float = 0):Void {}
	public static var scoreCallback:Dynamic->Void;
	public static function sendScore(amount:Int, initials:String, callback:Dynamic->Void):Void
	{
		scoreCallback = callback;
	}
	public static function deliverScore(value:Dynamic):Void
	{
		var callback = scoreCallback;
		scoreCallback = null;
		if (callback != null)
			callback(value);
	}
}
