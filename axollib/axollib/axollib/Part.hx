package axollib;
import flixel.FlxG;

class Part
{

	public var x:Float;
	public var y:Float;
	public var destX:Float;
	public var destY:Float;
	
	public var alpha:Float;
	
	public var speed:Float;
	public var alphaSpeed:Float;
	
	public var modeIn:Bool = true;
	
	public var done:Bool = false;
	public var delay:Float = 0;
	public var hue:Float = 0;
	public var hueSpeed:Float;
	
	public function new(DestX:Float, DestY:Float) 
	{
		x = destX = DestX;
		destY = DestY;
		alpha = 0;
		y = FlxG.random.int(0, Std.int(destY / 4));
		speed = FlxG.random.float(.33, 3);
		alphaSpeed = FlxG.random.float(1, 10);
		hue = FlxG.random.float(0, 360);
		hueSpeed = FlxG.random.float(10, 30);
	}
	
	public function update():Void
	{
		if (modeIn)
		{
			if (!done)
			{
				
				hue += hueSpeed;
				while (hue > 360)
				{
					hue -= 360;
				}
				
				
				if (y < destY)
				{
					y += speed;
					speed += .025;
					if (y >= destY)
						y = destY;
				}
				
				if (alpha < 255)
				{
					alpha += alphaSpeed;
					alphaSpeed += .1;
					if (alpha > 255)
						alpha = 255;
				}
				
				if (y == destY && alpha == 255)
				{
					done = true;
				}
			}
		}
		else
		{
			if (delay > 0)
			{
				delay -= FlxG.elapsed;
				
			}
			else
			{
				if (!done)
				{
					y -= speed;
					speed += .025;
					
					alpha -= alphaSpeed;
					alphaSpeed += 4;
					if (alpha <= 256 / 2)
					{
						alphaSpeed = 256 * .25;
						done = true;
					}
				}
				else
				{
					alpha += alphaSpeed;
					alphaSpeed *= 2;
					if (alpha >= 255)
					{
						alpha = 0;
					}
				}
			}
			
			
		}
	}
	
	public function switchMode():Void
	{
		modeIn = false;
		done = false;
		speed = FlxG.random.float(.05, .5);
		alphaSpeed = FlxG.random.float(2, 20);
		delay = FlxG.random.float(.2, 1);
	}
	
}