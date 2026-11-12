"""Tiny interpreter test only. No OpenFL/native build or game execution."""
from pathlib import Path
import tempfile,subprocess,shutil
with tempfile.TemporaryDirectory() as d:
 p=Path(d)
 files={
 'axollib/GraphicsCache.hx':'package axollib; class GraphicsCache {}',
 'flixel/graphics/FlxGraphic.hx':'package flixel.graphics; class FlxGraphic {}',
 'flixel/graphics/frames/FlxBitmapFont.hx':'package flixel.graphics.frames; class FlxBitmapFont { public function new(){} public static function fromAngelCode(a:Dynamic,b:Dynamic):FlxBitmapFont{return new FlxBitmapFont();}}',
 'AssetPaths.hx':'class AssetPaths {public static var egg_font__png="";public static var egg_font__xml="";}',
 'flixel/text/FlxBitmapText.hx':'package flixel.text;\nclass FlxBitmapText {\n public var measured=false;\n public var textWidth(get,never):Int;\n function get_textWidth():Int {measured=true;return 10;}\n public var text:String; public function new(x:Int,y:Int,t:String,f:Dynamic){}\n public function computeTextSize():Void {if(!measured)throw "fixed width layout used stale line widths";}\n}',
 'Test.hx':'class Test {static function main(){var t=new ui.NormalText("1");t.computeTextSize();trace("NormalText fixed-width sizing passes");}}'
 }
 files['globals/Game.hx']='package globals; class Game {public static var NormalFont:Dynamic=null;}'
 files['ui/NormalText.hx']=Path('source/ui/NormalText.hx').read_text(encoding='utf-8')
 for name,content in files.items():
  f=p/name;f.parent.mkdir(parents=True,exist_ok=True);f.write_text(content,encoding='utf-8')
 subprocess.run(['haxe','-cp',str(p),'-main','Test','-D','desktop','--interp'],check=True)
