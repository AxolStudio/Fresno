package axollib;

import flixel.FlxBasic;
import flixel.FlxSprite;
import openfl.display.BitmapData;
import openfl.display.Sprite;
import openfl.geom.Matrix;
import openfl.geom.Point;
import openfl.geom.Rectangle;

class FlxScrollZone extends FlxBasic
{
	private static var members:Map<FlxSprite, ScrollMember> = [];
	private static var zeroPoint:Point = new Point();

	public static function add(Source:FlxSprite, Region:Rectangle, DistanceX:Float, DistanceY:Float, ?OnlyScrollOnScreen:Bool = true,
			?ClearRegion:Bool = false):Void
	{
		if (members.exists(Source))
		{
			throw "FlxSprite already exists in FlxScrollZone, use addZone to add a new scrolling region  to an already added FlxSprite";
		}

		var data:ScrollMember = {
			source: Source,
			scrolling: true,
			onlyScrollOnScreen: OnlyScrollOnScreen,
			zones: new Array<ScrollZone>()
		}

		members.set(Source, data);

		createZone(Source, Region, DistanceX, DistanceY, ClearRegion);
	}

	public static function createZone(Source:FlxSprite, Region:Rectangle, DistanceX:Float, DistanceY:Float, ?ClearRegion:Bool = false):Void
	{
		var texture:BitmapData = new BitmapData(Std.int(Region.width), Std.int(Region.height), true, 0x0);
		texture.copyPixels(Source.pixels, Region, zeroPoint, null, null, true);

		var data:ScrollZone = {
			texture: texture.clone(),
			region: Region,
			clearRegion: ClearRegion,
			distanceX: DistanceX,
			distanceY: DistanceY,
			scrollMatrix: new Matrix(),
			drawMatrix: new Matrix(1, 0, 0, 1, Region.x, Region.y)
		};

		var member:ScrollMember = members.get(Source);
		member.zones.push(data);
		members.set(Source, member);
	}

	public static function updateDrawMatrix(Source:FlxSprite, Matrix:Matrix, ?Zone:Int = 0):Void
	{
		var member:ScrollMember = members.get(Source);
		member.zones[Zone].drawMatrix = Matrix;
		members.set(Source, member);
	}

	public static function getDrawMatrix(Source:FlxSprite, ?Zone:Int = 0):Matrix
	{
		return members.get(Source).zones[Zone].drawMatrix;
	}

	public static function remove(Source:FlxSprite):Bool
	{
		if (members.exists(Source))
		{
			members.remove(Source);
			return true;
		}
		return false;
	}

	public static function clear():Void
	{
		members.clear();
	}

	public static function updateX(Source:FlxSprite, DistanceX:Float, ?Zone:Int = 0):Void
	{
		var member:ScrollMember = members.get(Source);
		member.zones[Zone].distanceX = DistanceX;
		members.set(Source, member);
	}

	public static function updateY(Source:FlxSprite, DistanceY:Float, ?Zone:Int = 0):Void
	{
		var member:ScrollMember = members.get(Source);
		member.zones[Zone].distanceY = DistanceY;
		members.set(Source, member);
	}

	public static function startScrolling(?Source:FlxSprite = null):Void
	{
		var member:ScrollMember = null;
		if (Source == null)
		{
			for (k in members.keys())
			{
				member = members.get(k);
				member.scrolling = true;
				members.set(k, member);
			}
		}
		else
		{
			member = members.get(Source);
			member.scrolling = true;
			members.set(Source, member);
		}
	}

	public static function stopScrolling(?Source:FlxSprite = null):Void
	{
		var member:ScrollMember = null;
		if (Source == null)
		{
			for (k in members.keys())
			{
				member = members.get(k);
				member.scrolling = false;
				members.set(k, member);
			}
		}
		else
		{
			member = members.get(Source);
			member.scrolling = false;
			members.set(Source, member);
		}
	}

	override public function draw():Void
	{
		for (k => v in members)
		{
			if ((v.onlyScrollOnScreen == false || v.source.isOnScreen()) && v.scrolling == true && v.source.exists)
				scroll(v);
		}
	}

	private function scroll(Data:ScrollMember):Void
	{
		var buffer:Sprite = new Sprite();
		for (zone in Data.zones)
		{
			zone.scrollMatrix.tx += zone.distanceX;
			while (zone.scrollMatrix.tx > zone.region.width)
				zone.scrollMatrix.tx -= zone.region.width;
			while (zone.scrollMatrix.tx < -zone.region.width)
				zone.scrollMatrix.tx += zone.region.width;

			zone.scrollMatrix.ty += zone.distanceY;
			while (zone.scrollMatrix.ty > zone.region.height)
				zone.scrollMatrix.ty -= zone.region.height;
			while (zone.scrollMatrix.ty < -zone.region.height)
				zone.scrollMatrix.ty += zone.region.height;

			buffer.graphics.clear();
			buffer.graphics.beginBitmapFill(zone.texture, zone.scrollMatrix, true, false);
			buffer.graphics.drawRect(0, 0, zone.region.width, zone.region.height);
			buffer.graphics.endFill();

			if (zone.clearRegion)
			{
				Data.source.pixels.fillRect(zone.region, 0x0);
			}

			Data.source.pixels.draw(buffer, zone.drawMatrix);
		}
		Data.source.dirty = true;

		members.set(Data.source, Data);
	}

	override public function destroy():Void
	{
		clear();
	}
}

typedef ScrollMember =
{
	source:FlxSprite,
	scrolling:Bool,
	onlyScrollOnScreen:Bool,
	zones:Array<ScrollZone>
}

typedef ScrollZone =
{
	texture:BitmapData,
	region:Rectangle,
	clearRegion:Bool,
	distanceX:Float,
	distanceY:Float,
	scrollMatrix:Matrix,
	drawMatrix:Matrix
}