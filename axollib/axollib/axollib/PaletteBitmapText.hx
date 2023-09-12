package axollib;

import flash.display.BitmapData;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxBitmapFont;
import flixel.system.debug.log.BitmapLog;
import flixel.text.FlxBitmapText;
import flixel.util.FlxColor;
import flixel.util.FlxSort;

class PaletteBitmapText extends FlxBitmapText {
	public var sourceGraphic:BitmapData;
	public var sourcePalette:Array<FlxColor>;

	public var palette:Array<FlxColor>;

	public function new(?Font:FlxBitmapFont, ?Text:String = "") {
		super(Font);

		getSourceGraphic();
		getSourcePalette();

		text = Text;
	}

	override public function graphicLoaded():Void {}

	public function getSourceGraphic():Void {
		sourceGraphic = font.parent.bitmap.clone();
	}

	public function getSourcePalette():Void {
		sourcePalette = [];
		for (x in 0...sourceGraphic.width) {
			for (y in 0...sourceGraphic.height) {
				var color:FlxColor = sourceGraphic.getPixel32(x, y);
				if (color != FlxColor.TRANSPARENT && !sourcePalette.contains(color))
					sourcePalette.push(color);
			}
		}
		sourcePalette.sort((a:FlxColor, b:FlxColor) -> {
			if (a.toHexString(false) < b.toHexString(false))
				return -1;
			else if (a.toHexString(false) > b.toHexString(false))
				return 1;
			else
				return 0;
		});
	}

	@:access(flixel.FlxSprite.calcFrame)
	public function applyPalette(Palette:Array<FlxColor>):Void {
		palette = Palette.copy();
		var newGraphic:BitmapData = new BitmapData(sourceGraphic.width, sourceGraphic.height, true, FlxColor.TRANSPARENT);
		for (x in 0...sourceGraphic.width) {
			for (y in 0...sourceGraphic.height) {
				var color:FlxColor = sourceGraphic.getPixel32(x, y);
				var paletteIndex:Int = sourcePalette.indexOf(color);
				if (paletteIndex < palette.length)
					newGraphic.setPixel32(x, y, palette[paletteIndex]);
				else
					newGraphic.setPixel32(x, y, FlxColor.TRANSPARENT);
			}
		}

		font.parent.bitmap = newGraphic.clone();

		dirty = true;
		calcFrame(true);
	}
}
