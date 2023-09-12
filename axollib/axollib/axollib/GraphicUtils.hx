package axollib;

import flixel.util.FlxColor;
import openfl.display.BitmapData;
import openfl.display.BitmapDataChannel;
import openfl.filters.BitmapFilter;
import openfl.filters.ColorMatrixFilter;
import openfl.geom.Point;

class GraphicUtils {
	private static inline var RWGT:Float = .3086;
	private static inline var GWGT:Float = .6094;
	private static inline var BWGT:Float = .0820;

	/**
	 * Returns a ColorMatrixFilter which sets the luminance (desaturation) based on a given ratio (range [0-1])
	 * @param	ratio		The amount of luminance (0 -> [1], 0=normal, 1=B and W)
	 */
	public static function getLuminanceFilter(ratio:Float = 1):ColorMatrixFilter {
		var r1:Float = 1 + (RWGT - 1) * ratio;
		var r2:Float = RWGT * ratio;
		var g1:Float = 1 + (GWGT - 1) * ratio;
		var g2:Float = GWGT * ratio;
		var b1:Float = 1 + (BWGT - 1) * ratio;
		var b2:Float = BWGT * ratio;

		return new ColorMatrixFilter([
			r1, g2, b2, 0, 0,
			r2, g1, b2, 0, 0,
			r2, g2, b1, 0, 0,
			 0,  0,  0, 1, 0
		]);
	}

	/**
	 * Returns a ColorMatrixFilter which sets the bright offset based on a given ratio (range -225 -> [0] -> 255])
	 * @param	ratio		The amount of bright offset (-1 -> [0] -> 1)
	 */
	public static function getBrightOffsetFilter(ratio:Float = 0):ColorMatrixFilter {
		ratio = Math.max(-255, Math.min(255, 255 * ratio));

		return new ColorMatrixFilter([
			1, 0, 0, 0, ratio,
			0, 1, 0, 0, ratio,
			0, 0, 1, 0, ratio,
			0, 0, 0, 1,     0
		]);
	}

	/**
	 * Returns a ColorMatrixFilter which sets the bright multiplication
	 * @param	ratio		The amount of bright multiplication (0 -> [1] -> 2)
	 */
	public static function getBrightMultiplyFilter(ratio:Float = 0):ColorMatrixFilter {
		return new ColorMatrixFilter([
			ratio,     0,     0,     0, 0,
			    0, ratio,     0,     0, 0,
			    0,     0, ratio,     0, 0,
			    0,     0,     0, ratio, 0
		]);
	}

	/**
	 * Returns a ColorMatrixFilter which sets the saturation based on a given ratio (range 0 -> [1] -> 2])
	 * @param	ratio		The amount of saturation (0 -> [1] -> 2)
	 */
	public static function getSaturationFilter(ratio:Float = 1):ColorMatrixFilter {
		var r1:Float = RWGT * (1 - ratio);
		var g1:Float = GWGT * (1 - ratio);
		var b1:Float = BWGT * (1 - ratio);

		return new ColorMatrixFilter([
			r1 + ratio,         g1,         b1, 0, 0,
			        r1, g1 + ratio,         b1, 0, 0,
			        r1,         g1, b1 + ratio, 0, 0,
			         0,          0,          0, 1, 0
		]);
	}

	public static inline function applyFilter(Target:BitmapData, Filter:BitmapFilter):Void {
		Target.applyFilter(Target, Target.rect, new Point(), Filter);
	}

	public static inline function gradientMap(Target:BitmapData, Color:FlxColor):Void {
		var r:Array<Int> = [];
		var g:Array<Int> = [];
		var b:Array<Int> = [];

		var rVal:Int = Color.red;
		var gVal:Int = Color.green;
		var bVal:Int = Color.blue;

		for (i in 0...128) {
			r.push(Std.int(rVal / 128 * i) << 16);
			g.push(Std.int(gVal / 128 * i) << 8);
			b.push(Std.int(bVal / 128 * i));
		}

		for (i in 0...128) {
			r.push(Std.int(rVal + (255 - rVal) / 128 * i) << 16);
			g.push(Std.int(gVal + (255 - gVal) / 128 * i) << 8);
			b.push(Std.int(bVal + (255 - bVal) / 128 * i));
		}

		Target.paletteMap(Target, Target.rect, new Point(), r, g, b);
	}
}
