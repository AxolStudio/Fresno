package axollib;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.Assets;

using StringTools;

// this class is used to help cache graphics that might be re-used throughout the game.
class GraphicsCache {
	public static function loadGraphicFromAtlas(AtlasImage:flixel.system.FlxAssets.FlxGraphicAsset, AtlasXML:String, ?Unique:Bool = false,
			?Name:String):FlxGraphic {
		// first, see if we already have this graphic in the map (by name), if so, return it

		// okay, load up this atlas file, add it to the cache, and then return it
		var t:FlxAtlasFrames = loadAtlasFrames(AtlasImage, AtlasXML, Unique, Name);
		var g:FlxGraphic = FlxGraphic.fromFrames(t);
		// if (!Unique) {
		// 	g.persist = true;
		// 	g.destroyOnNoUse = false;
		// }

		return g;
	}

	public static function addGraphic(Graphic:flixel.system.FlxAssets.FlxGraphicAsset, Unique:Bool = false, ?Name:String):FlxGraphic {
		var g:FlxGraphic = FlxG.bitmap.add(Graphic, Unique, Name);
		if (!Unique) {
			g.destroyOnNoUse = false;
			g.persist = true;
		}
		return g;
	}

	public static function loadGraphic(Image:String, Unique:Bool = false, ?Name:String):FlxGraphic {
		var g:FlxGraphic = FlxG.bitmap.add(Image, Unique, Name == null ? Image : Name);
		if (!Unique) {
			g.destroyOnNoUse = false;
			g.persist = true;
		}
		return g;
	}

	public static function loadAtlasFrames(AtlasImage:flixel.system.FlxAssets.FlxGraphicAsset, AtlasXML:String, ?Unique:Bool = false,
			?Name:String):FlxAtlasFrames {
		var f:FlxAtlasFrames = FlxAtlasFrames.fromSparrow(AtlasImage, AtlasXML);
		// if (!Unique) {
		// 	f.parent.destroyOnNoUse = false;
		// 	f.parent.persist = true;
		// } else
		// 	f.parent.unique = true;

		return f;
	}

	public static function loadFlxSpriteFromAtlas(FilePrefix:String):FlxSprite {
		var tmp:FlxSprite = new FlxSprite();
		tmp.frames = loadAtlasFrames("assets/images/" + FilePrefix + ".png", "assets/images/" + FilePrefix + ".xml", false, FilePrefix);
		return tmp;
	}

	public static function preloadGraphics():Void {
		for (f in Assets.list()) {
			if (f.startsWith("assets/") && f.endsWith(".png")) {
				loadGraphic(f, f);
			}
		}
	}
}
