package objects;

import globals.Game;
import flixel.tile.FlxTilemap;

class Road extends FlxTilemap
{
	public var templates:Map<String, Array<String>> = [WOODS => ["A", "B", "B", "B", "B",  "B", "C"]];

	public var replacements:Map<String, Map<String, Array<Int>>> = [WOODS => ["A" => [2], "B" => [3, 4, 5, 7], "C" => [6]]];

	public var tilesets:Map<String, String> = [WOODS => "assets/images/forest_ground.png"];

	public function new():Void
	{
		super();
	}

	public function regen(LevelTheme:Theme):Void
	{
		var template:Array<String> = templates[LevelTheme];
		var replacement:Map<String, Array<Int>> = replacements[LevelTheme];

		var road:Array<Int> = [for (t in template) replacement[t][Std.random(replacement[t].length)]];

		loadMapFromArray(road, 1, 7, tilesets[LevelTheme], 16, 16);
	}
}
