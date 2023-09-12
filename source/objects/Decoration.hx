package objects;

import flixel.FlxG;
import axollib.GraphicsCache;
import globals.Game;
import flixel.FlxSprite;

class Decoration extends FlxSprite
{
	public var levelTheme:Theme;

	public function new(LevelTheme:Theme):Void
	{
		super();
		levelTheme = LevelTheme;
		regen();
	}

	public function regen()
	{
		switch (levelTheme)
		{
			case WOODS:
				frames = GraphicsCache.loadAtlasFrames("assets/images/camp_deco.png", "assets/images/camp_deco.xml", false, "camp_deco");

				animation.frameName = Game.Decorations.get(levelTheme)[FlxG.random.weightedPick(Game.DecorationsRarity.get(levelTheme))];

			case CITY:

			case SUBURBS:
		}

		updateHitbox();
	}
}
