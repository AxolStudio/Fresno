package globals;

import flixel.FlxObject;
import flixel.tweens.FlxTween;
import flixel.FlxG;
import flixel.math.FlxMath;
import flixel.system.FlxSound;
import lime.utils.AssetType;
import lime.utils.Assets;

using StringTools;

class Sound
{
	public static inline var MAX_SOUNDS:Int = 50;
	public static var soundCount:Int = 0;

	public static var currentMusic:String = null;

	private static var sounds:Map<String, FlxSound>;
	private static var music:Map<String, String>;

	public static var soundLevel(default, set):Float = 1;
	public static var musicLevel(default, set):Float = 1;

	public static var musics:Array<String> = [];

	private static function decreaseSoundCount():Void
	{
		soundCount--;
		if (soundCount < 0)
		{
			soundCount = 0;
		}
	}

	public static function preloadSounds():Void
	{
		sounds = new Map<String, FlxSound>();

		var s:FlxSound = null;
		var sName:String = "";

		for (a in Assets.list(AssetType.SOUND))
		{
			if (a.startsWith("assets/sounds/"))
			{
				s = new FlxSound().loadEmbedded(a, false, false);
				// s.onComplete = decreaseSoundCount;
				sName = a.substring("assets/sounds/".length, a.indexOf("."));
				s.persist = true;
				s.group = FlxG.sound.defaultSoundGroup;
				sounds.set(sName, s);
			}
		}

		music = new Map<String, String>();
		for (a in Assets.list(AssetType.SOUND))
		{
			if (a.startsWith("assets/music/"))
			{
				// s = new FlxSound().loadEmbedded(a, false, false);
				sName = a.substring("assets/music/".length, a.indexOf("."));

				music.set(sName, a);
			}
		}
	}

	public static function play(SoundName:String, Volume:Float = 0.5, ?ProximityTo:ProximityData):FlxSound
	{
		if (soundCount >= MAX_SOUNDS)
		{
			return null;
		}
		var s:FlxSound = sounds.get(SoundName);
		if (s == null)
			throw "Unknown sound: '" + SoundName + "'";

		if (ProximityTo != null)
			s = s.proximity(ProximityTo.X, ProximityTo.Y, ProximityTo.Target, FlxG.width * .66);

		s.volume = Volume;

		s.play(true);

		// soundCount++;
		return s;
	}

	public static function endMusic():Void
	{
		if (currentMusic != null)
		{
			FlxG.sound.music.stop();
			currentMusic = "";
		}
	}

	public static function fadeOutMusic(Time:Float, ?OnComplete:FlxTween->Void):Void
	{
		if (currentMusic != null)
		{
			currentMusic = null;
			FlxG.sound.music.fadeOut(Time, 0, OnComplete);
		}
	}

	public static function playMusic(MusicName:String, ?Volume:Float = 0.5, ?LoopFrom:Int = -1):Void
	{
		if (currentMusic != null)
		{
			if (currentMusic != MusicName)
			{
				endMusic();
				switchMusicTo(MusicName, Volume, LoopFrom);
			}
		}
		else
		{
			switchMusicTo(MusicName, Volume, LoopFrom);
		}
	}

	// public static function randomMusic(Volume:Float = 0.5):Void
	// {
	// 	var newMusic:String = "";
	// 	var newMusics:Array<String> = musics.copy();
	// 	if (currentMusic == null)
	// 	{
	// 		newMusics.remove(currentMusic);
	// 	}
	// 	FlxG.random.shuffle(newMusics);
	// 	playMusic(newMusics[0], Volume);
	// }

	private static function switchMusicTo(MusicName:String, Volume:Float = 0.5, LoopFrom:Int = -1):Void
	{
		var m:String = music.get(MusicName);
		if (m == null) {} // throw "Unknown music: '" + (MusicName) + "'";
		else
		{
			FlxG.sound.playMusic(m, Volume, true);
			if (LoopFrom != -1)
			{
				FlxG.sound.music.loopTime = LoopFrom;
			}
			currentMusic = MusicName;
		}
	}

	private static function set_soundLevel(Value:Float):Float
	{
		soundLevel = FlxMath.bound(Value, 0, 1);
		FlxG.sound.defaultSoundGroup.volume = soundLevel;
		return soundLevel;
	}

	private static function set_musicLevel(Value:Float):Float
	{
		musicLevel = FlxMath.bound(Value, 0, 1);
		FlxG.sound.defaultMusicGroup.volume = musicLevel;
		return musicLevel;
	}
}

typedef ProximityData =
{
	var X:Float;
	var Y:Float;
	var Target:FlxObject;
}
