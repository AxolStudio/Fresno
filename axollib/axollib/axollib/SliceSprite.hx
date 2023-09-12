package axollib;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.addons.ui.*;
import flixel.graphics.FlxGraphic;
import flixel.system.FlxAssets.FlxGraphicAsset;
import openfl.geom.Rectangle;
import openfl.display.BitmapData;

/**
 * Handy 9-slice defs to pass into Quick9Slicer. Always pass a literal value in.
 * @author George
 */
enum SliceInfo
{
	Border(value:Int);
	Margins2(x:Int, y:Int);
	Margins4(left:Int, top:Int, right:Int, bottom:Int);
	Rect(x:Int, y:Int, width:Int, height:Int);
}

/**
 * Handy 9-slice defs to pass into Quick9Slicer. Always pass a literal value in.
 * @author George
 */
enum abstract TileMode(Int) from Int
{
	var TILE_NONE = FlxUI9SliceSprite.TILE_NONE;
	var TILE_BOTH = FlxUI9SliceSprite.TILE_BOTH;
	var TILE_H = FlxUI9SliceSprite.TILE_H;
	var TILE_V = FlxUI9SliceSprite.TILE_V;
}

/**
 * Easy 9slice creator
 * @author George
 */
@:forward
abstract SliceSprite(FlxUI9SliceSprite) to FlxUI9SliceSprite
{
	public var width(get, set):Float;
	public var height(get, set):Float;

	/**
	 * @param X            X position of final sprite
	 * @param Y            Y position of final sprite
	 * @param Graphic      Asset
	 * @param Width        Width of the final scaled sprite, -1 to use frameWidth
	 * @param Height       Height of the final scaled sprite, -1 to use frameHeight
	 * @param slice        A literal value representing the way to slice up the source. inlines to a literal array of [x1,y1,x2,y2].
	 * @param tile         Whether to tile the middle pieces or stretch them (default is false --> stretch)
	 * @param smooth       When stretching, whether to smooth middle pieces (default false)
	 * @param id           If Graphic is a BitmapData, manually specify its original source id, if any
	 * @param ratio        Resize ratio to force, if desired (W/H)
	 * @param Resize_point Point for anchoring resizes
	 * @param Resize_axis  Whether resizing is based around the X or Y axis
	 * @param Color        Color to tint this graphic to. (White has no effect.)
	 */
	inline public function new(X = 0.0, Y = 0.0, Graphic:FlxGraphicAsset, Width = -1.0, Height = -1.0, Slice:SliceInfo = null,
			Tile:TileMode = FlxUI9SliceSprite.TILE_NONE, Smooth = false, ID = "", Ratio = -1.0, ?ResizePoint:FlxPoint,
			ResizeAxis = FlxUISprite.RESIZE_RATIO_Y, DeferResize = false, Color = FlxColor.WHITE)
	{
		var graphic:FlxGraphic = FlxG.bitmap.add(Graphic);
		if (graphic == null)
			throw 'Invalid asset:$Graphic';

		if (Width < 0)
			Width = graphic.width;

		if (Height < 0)
			Height = graphic.height;

		this = new FlxUI9SliceSprite(X, Y, graphic, new Rectangle(0, 0, Width, Height), createSliceData(Slice, graphic.bitmap), cast Tile, Smooth, ID, Ratio,
			ResizePoint, ResizeAxis, DeferResize, Color);
	}

	/**
	 * Swaps out the source bitmap while retaining the same size and margins.
	 * If the old and new graphic are the same, nothing happens.
	 * 
	 * @param Graphic Asset
	 * @param Id      If Graphic is a BitmapData, manually specify its original source id, if any
	 */
	public function swapGraphic(Graphic:FlxGraphicAsset, Id:String = "")
	{
		if (Std.isOfType(Graphic, String))
		{
			if (assetId == Graphic)
				return this;

			var graphic:FlxGraphic = FlxG.bitmap.add(Graphic);
			if (graphic == null)
				throw 'Invalid asset:$Graphic';

			assetId = Graphic;
			// Always set rawpixels because we need it for util helpers
			rawPixels = graphic.bitmap;
		}
		else if (Std.isOfType(Graphic, BitmapData))
		{
			if (rawPixels == Graphic)
				return this;

			if (Id == "" || Id == null)
				throw "Non-null, non-empty Id is required when Graphic is a BitmapData";

			assetId = Id;
			rawPixels = cast Graphic;
		}
		else if (Std.isOfType(Graphic, FlxGraphic))
		{
			var g:FlxGraphic = cast Graphic;
			if (rawPixels == g.bitmap)
				return this;

			assetId = g.key;
			rawPixels = g.bitmap;
		}

		this.resize(width, height);

		return this;
	}

	inline function createSliceData(info:SliceInfo, bitmap:BitmapData)
	{
		return switch (info)
		{
			case null:
				[0, 0, bitmap.width, bitmap.height];
			case Border(value):
				[value, value, bitmap.width - value, bitmap.height - value];
			case Margins2(x, y):
				[x, y, bitmap.width - x, bitmap.height - y];
			case Margins4(left, top, right, bottom):
				[left, top, bitmap.width - right, bitmap.height - bottom];
			case Rect(x, y, width, height):
				[x, y, width, height];
		}
	}

	inline public function setOriginalSize()
	{
		this.resize(originalWidth, originalHeight);
	}

	inline function get_width()
		return this.width;

	inline function set_width(value:Float)
	{
		value = Math.max(0, value);
		this.resize(value, height);
		return this.width = value;
	}

	inline function get_height()
		return this.height;

	inline function set_height(value:Float)
	{
		value = Math.max(0, value);
		this.resize(width, value);
		return this.height = value;
	}

	/** Size of the left slice */
	public var sizeLeft(get, never):Int;

	inline function get_sizeLeft():Int
	{
		return slice9[0];
	}

	/** Size of the top slice */
	public var sizeTop(get, never):Int;

	inline function get_sizeTop():Int
	{
		return slice9[1];
	}

	/** Size of the right slice */
	public var sizeRight(get, never):Int;

	inline function get_sizeRight():Int
	{
		return rawPixels.width - slice9[2];
	}

	/** Size of the bottom slice */
	public var sizeBottom(get, never):Int;

	inline function get_sizeBottom():Int
	{
		return rawPixels.height - slice9[3];
	}

	/** The stretched width of middle section */
	public var sizeMiddleX(get, never):Int;

	inline function get_sizeMiddleX():Int
	{
		return this.graphic.width - sizeLeft - sizeRight;
	}

	/** The stretched height of middle section */
	public var sizeMiddleY(get, never):Int;

	inline function get_sizeMiddleY():Int
	{
		return this.graphic.height - sizeTop - sizeBottom;
	}

	/** Width of the graphic before it was stretched via 9slice **/
	public var originalWidth(get, never):Int;

	inline function get_originalWidth():Int
	{
		return rawPixels.width;
	}

	/** Height of the graphic before it was stretched via 9slice **/
	public var originalHeight(get, never):Int;

	inline function get_originalHeight():Int
	{
		return rawPixels.height;
	}

	// === === === === === === === === === === === === === === === === ===
	// private getter/setters to easily access "inherited" private fields.
	var rawPixels(get, set):BitmapData;
	var assetId(get, set):String;
	var slice9(get, never):Array<Int>;

	@:noCompletion inline function get_rawPixels():BitmapData
	{
		@:privateAccess return this._raw_pixels;
	}

	@:noCompletion inline function get_assetId():String
	{
		@:privateAccess return this._asset_id;
	}

	@:noCompletion inline function get_slice9():Array<Int>
	{
		@:privateAccess return this._slice9;
	}

	@:noCompletion inline function set_rawPixels(value:BitmapData):BitmapData
	{
		@:privateAccess return this._raw_pixels = value;
	}

	@:noCompletion inline function set_assetId(value:String):String
	{
		@:privateAccess return this._asset_id = value;
	}
}
