package axollib;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxFrame;
import flixel.util.FlxColor;

class ColorSprite extends FlxSprite
{
	
	public var source:FlxGraphic;
	public var rainbowing:Bool = false;
	public var hue(default, set):Float = 0;
	private var hueRate:Float = 0;
	
	public function new(Graphic:String, Animated:Bool = false, Width:Int = 0, Height:Int = 0, Hue:Float = 0 )
	{
		super();
		source = FlxG.bitmap.get(Graphic + "-master");
		if (source == null)
		{
			source =  FlxG.bitmap.add(Graphic, false, Graphic + "-master");
			
		}
		loadGraphic(source, Animated, Width, Height, true);
		hue = Hue;
	}
	
	private function colorShift(Hue:Float):Void
	{	
		
		_frame.parent.bitmap.lock();
		for (w in Std.int(_frame.frame.x)...Std.int(_frame.frame.right))
		{
			for (h in Std.int(_frame.frame.y)...Std.int(_frame.frame.bottom))
			{
				var p:Int = source.bitmap.getPixel32(w, h);
				var m:FlxColor = FlxColor.fromInt(p);
				m.hue += hue;
				_frame.parent.bitmap.setPixel32(w, h, m);
			}
		}
		_frame.parent.bitmap.unlock();
		dirty = true;
		drawFrame(true);
		
	}
	
	public function startRainbow(Rate:Float):Void
	{
		if (rainbowing)
			return;
		rainbowing = true;
		hueRate = Rate;
	}
	
	public function stopRainbow():Void
	{
		rainbowing = false;
	}
	
	override public function update(elapsed:Float):Void 
	{
		if (rainbowing)
		{
			hue += (hueRate * elapsed);
		}
		
		super.update(elapsed);
	}
	
	private function set_hue(Value:Float):Float
	{
		hue = Value;
		while (hue >= 360)
			hue-= 360;
		colorShift(hue);
		return hue;
	}
	
	override function set_frame(Value:FlxFrame):FlxFrame 
	{
		var frame:FlxFrame = super.set_frame(Value);
		colorShift(hue);
		return frame;
	}
	
}