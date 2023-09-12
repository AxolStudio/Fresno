package axollib;

import flixel.addons.util.FlxSimplex;
import flixel.math.FlxPoint;

using axollib.AxolUtil;

/**
 * A set of useful functions
 */
class AxolUtil {
	/**
	 * sums the values in the array
	 * @param   array                   The Array.
	 * @return  Float    The sum of all elements in the array.
	 */
	@:generic
	public static inline function sum<T:Float>(array:Array<T>):Float {
		var sum:Float = 0;
		for (i in 0...array.length)
			sum += cast array[i];
		return sum;
	}

	/**
	 * averages the values in an array
	 * @param array     The Array.
	 * @return Float    The average of all elements in the array.
	 */
	@:generic
	public static inline function average<T:Float>(array:Array<T>):Float {
		var sum:Float = array.sum();
		return sum / array.length;
	}

	public static inline function fbm(Pos:FlxPoint, ?H:Float = 1, ?NumOctaves:Int = 4):Float {
		var G:Float = Math.pow(2, -H);
		var f:Float = 1.0;
		var a:Float = 1.0;
		var t:Float = 0.0;
		for (i in 0...NumOctaves) {
			t += a * FlxSimplex.simplex(f * Pos.x, f * Pos.y); // FlxMath.remapToRange(, -1, 1, 0, 1);
			f *= 2;
			a *= G;
		}
		return t;
	}

	public static inline function pattern(Pos:FlxPoint):Float {
		var q:FlxPoint = FlxPoint.get(fbm(FlxPoint.weak(Pos.x, Pos.y), fbm(FlxPoint.weak(Pos.x + 5.2, Pos.y + 1.3))));
		return fbm(FlxPoint.weak(Pos.x + 4 * q.x, Pos.y + 4 * q.y));
	}
}
