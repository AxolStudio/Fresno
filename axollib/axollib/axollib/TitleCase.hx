package axollib;

class TitleCase
{
	public static var exempt:Array<String> = [
		"a", "an", "the", "at", "by", "for", "in", "of", "on", "to", "up", "and", "as", "but", "or", "nor"
	];

	public static var roman = ~/^(?=[MDCLXVI])M*(C[MD]|D?C*)(X[CL]|L?X*)(I[XV]|V?I*)$/i;

	public static function toTitleCase(str:String):String
	{
		var words:Array<String> = str.toLowerCase().split(" ");

		for (i in 0...words.length)
		{
			if (exempt.indexOf(words[i]) == -1)
			{
				if (roman.match(words[i]))
					words[i] = words[i].toUpperCase();
				else
					words[i] = words[i].charAt(0).toUpperCase() + words[i].substr(1);
			}
		}

		return words.join(" ");
	}
}

class Slugify
{
	public static function toSlug(str:String):String
	{
		var regex = ~/[^a-z0-9]+/g;
		return regex.replace(str.toLowerCase(), '_');
	}
}

class Roman
{
	public static function arabic2Roman(Numeral:Int):String {
		var roman:String = "";
		var romanNumList:Array<String> = ["M", "CM", "D", "CD", "C", "XC", "L", "XL", "X", "IX", "V", "IV", "I"];
		var correspondingNumbers:Array<Int> = [1000, 900, 500, 400, 100, 90, 50, 40, 10, 9, 5, 4, 1];

		for (i in 0...romanNumList.length)
		{
			while (Numeral >= correspondingNumbers[i])
			{
				roman += romanNumList[i];
				Numeral -= correspondingNumbers[i];
			}
		}

		return roman;
	}
}
