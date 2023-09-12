package axollib;

import flash.display.BitmapData;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxMath;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.util.FlxColor;

class CyclingSprite extends FlxSprite 
{

	public var colors:Array<FlxColor>;
	public var changeRate:Float;
	private var currentIndex:Int = 0;
	private var baseImage:BitmapData;
	
	
	public function new(?X:Float=0, ?Y:Float=0, ?SimpleGraphic:FlxGraphicAsset, Colors:Array<FlxColor>, ChangeRate:Float = 500) 
	{
		super(X, Y, SimpleGraphic);
		baseImage = pixels.clone();
		colors = Colors;
		changeRate = ChangeRate;
		
	}
	
	override public function loadGraphic(Graphic:FlxGraphicAsset, Animated:Bool = false, Width:Int = 0, Height:Int = 0, Unique:Bool = false, ?Key:String):FlxSprite 
	{
		var f:FlxSprite = super.loadGraphic(Graphic, Animated, Width, Height, Unique, Key);
		baseImage = f.pixels.clone();
		return f;
	}
	
	override public function loadGraphicFromSprite(Sprite:FlxSprite):FlxSprite 
	{
		var f:FlxSprite = super.loadGraphicFromSprite(Sprite);
		baseImage = f.pixels.clone();
		return f;
	}
	
	override public function draw():Void 
	{
		var newIndex:Int = Std.int((FlxG.game.ticks / changeRate) % colors.length);
		if (currentIndex != newIndex)
		{
			currentIndex = newIndex;
			for (i in 0...colors.length)
			{
				pixels.threshold(baseImage, baseImage.rect, _flashPointZero, "==", colors[i], colors[FlxMath.wrap(i + currentIndex, 0, colors.length - 1)], 0xffffffff, false);		
			}
			dirty = true;
		}
		
		super.draw();
	}
	
	override public function update(elapsed:Float):Void 
	{
		
		
		
		super.update(elapsed);
	}
	
}