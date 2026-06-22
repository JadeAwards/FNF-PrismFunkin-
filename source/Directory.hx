// done
package;

import flixel.FlxG;

class Directory
{
	public static var dataFolder:String = "assets/data";
	public static var fontsFolder:String = "assets/fonts";
	public static var imagesFolder:String = "assets/images";
	public static var musicFolder:String = "assets/music";
	public static var soundsFolder:String = "assets/sounds";

	public static function dumpCache()
	{
		@:privateAccess
		if (FlxG.bitmap != null && FlxG.bitmap._cache != null)
		{
			for (key in FlxG.bitmap._cache.keys())
			{
				var obj = FlxG.bitmap._cache.get(key);
				if (obj != null && key.indexOf("menu") == -1 && key.indexOf("cursor") == -1 && key.indexOf("font") == -1)
				{
					FlxG.bitmap._cache.remove(key);
					obj.destroy();
				}
			}
		}

		#if !html5
		// wipes out track data from previous sound arrays without destroying menu assets
		openfl.utils.Assets.cache.clear("songs");
		openfl.utils.Assets.cache.clear("music");
		#end

		#if cpp
		cpp.vm.Gc.enable(true);
		cpp.vm.Gc.run(true);
		#elseif hl
		hl.Gc.major();
		#end

		trace("Cache targeted successfully! Leaks plugged safely.");
	}
}
