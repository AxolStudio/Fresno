package axollib;
import flixel.FlxState;
class AxolAPI
{
	public static var firstState:Class<FlxState>;
	public static var init:Void->Void;
	public static function initialize(game:String = "", player:String = ""):Void {}
	public static function sendEvent(name:String, value:Float = 0):Void {}
	public static function sendScore(amount:Int, initials:String, callback:Dynamic->Void):Void {}
}
