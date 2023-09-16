package objects;

import globals.Game;
import flixel.tile.FlxTilemap;

class Road extends FlxTilemap
{
	public var templates:Map<RoadStyle, Array<String>> = [
		GROUND => ["A", "B", "B", "B", "B", "B", "C"],
		STREET => ["E", "A", "B", "B", "C", "B", "D"]
	];

	public var replacements:Map<RoadStyle, Map<String, Array<Int>>> = [
		GROUND => ["A" => [2], "B" => [3, 4, 5, 7], "C" => [6]],
		STREET => [
			"A" => [6, 1, 2],
			"B" => [12, 4, 5, 7, 8, 10, 11, 13, 14],
			"C" => [9],
			"D" => [15],
			"E" => [3]
		]
	];

	public var tilesets:Map<RoadStyle, String> = [
		GROUND => "assets/images/forest_ground.png",
		STREET => "assets/images/street_ground.png"
	];

	public function new():Void
	{
		super();
	}

	public function regen(Style:RoadStyle):Void
	{
		var template:Array<String> = templates[Style];
		var replacement:Map<String, Array<Int>> = replacements[Style];

		var road:Array<Int> = [for (t in template) replacement[t][Std.random(replacement[t].length)]];

		loadMapFromArray(road, 1, 7, tilesets[Style], 16, 16);
	}
}
