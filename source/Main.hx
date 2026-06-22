// done
package;

import flixel.FlxG;
import flixel.FlxGame;
import openfl.display.FPS;
import openfl.display.Sprite;

class Main extends Sprite
{
	public static var framerate:Int = 120;

	public static var prismVer:String = '1.0.0';
	public static var funkinVer:String = '0.2.7.1';

	public function new()
	{
		super();

		// more of a just in case thing i guess lol
		#if html5
		framerate = 60;
		#end

		addChild(new FlxGame(0, 0, TitleState));

		FlxG.updateFramerate = framerate;
		FlxG.drawFramerate = framerate;

		#if !mobile
		addChild(new FPS(0, 0, 0xFFFFFF));
		#end
	}
}
