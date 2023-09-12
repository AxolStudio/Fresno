package axollib;

import flash.Lib;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.GradientType;
import flash.display.GraphicsPathWinding;
import flash.display.Shape;
import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.ProgressEvent;
import flash.geom.Matrix;
import flash.geom.Rectangle;
import flash.net.URLRequest;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import flixel.system.FlxBasePreloader;
import flixel.util.FlxColor;
import flixel.util.FlxStringUtil;
import openfl.Vector;
import openfl.text.TextFieldAutoSize;
import openfl.text.TextFieldType;

class Preloader extends FlxBasePreloader {
	public function new():Void {
		super(0, ["https://axolstudio.itch.io/bring-it-on"]);
	}

	override function createSiteLockFailureText(margin:Float):Sprite {
		var sprite = new Sprite();
		var bounds = new Rectangle(0, 0, stage.stageWidth, stage.stageHeight);
		bounds.inflate(-margin, -margin);

		var titleText = new TextField();
		var titleTextFormat = new TextFormat("_sans", 60, 0x333333, true);
		titleTextFormat.align = TextFormatAlign.CENTER;
		titleText.defaultTextFormat = titleTextFormat;
		titleText.selectable = false;
		titleText.width = bounds.width;
		titleText.text = "!! WARNING !!";

		var bodyText = new TextField();
		var bodyTextFormat = new TextFormat("_sans", 24, 0x333333);
		bodyText.type = TextFieldType.DYNAMIC;

		bodyTextFormat.align = TextFormatAlign.CENTER;

		bodyText.defaultTextFormat = bodyTextFormat;
		// bodyText.multiline = true;
		// bodyText.wordWrap = true;
		// bodyText.autoSize = TextFieldAutoSize.CENTER;
		// bodyText.selectable = false;
		bodyText.width = bounds.width;
		bodyText.text = "This game is being hosted ILLEGALLY by an unauthorized third party.\n\nPlease contact help@axolstudio.com or visit our official website for more information:";

		var hyperlinkText = new TextField();
		var hyperlinkTextFormat = new TextFormat("_sans", 24, 0x6e97cc, true, false, true);
		hyperlinkTextFormat.align = TextFormatAlign.CENTER;
		hyperlinkTextFormat.url = "https://axolstudio.com/";
		hyperlinkText.defaultTextFormat = hyperlinkTextFormat;
		hyperlinkText.selectable = true;
		hyperlinkText.width = bounds.width;
		hyperlinkText.text = "https://axolstudio.com/";

		// Do customization before final layout.
		adjustSiteLockTextFields(titleText, bodyText, hyperlinkText);

		var gutterSize = 4;
		titleText.height = titleText.textHeight + gutterSize;
		// bodyText.height = (bodyText.textHeight + gutterSize * 2);
		hyperlinkText.height = hyperlinkText.textHeight + gutterSize;
		titleText.x = bodyText.x = hyperlinkText.x = bounds.left;
		titleText.y = bounds.top;
		bodyText.y = titleText.y + 2.0 * titleText.height;
		hyperlinkText.y = bodyText.y + bodyText.height + hyperlinkText.height;

		sprite.addChild(titleText);
		sprite.addChild(bodyText);
		sprite.addChild(hyperlinkText);
		return sprite;
	}
}
