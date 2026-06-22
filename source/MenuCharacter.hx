// done
package;

import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;

class MenuCharacter extends FlxSprite
{
	public var character:String;

	public function new(x:Float, character:String = '')
	{
		super(x);

		this.character = character;

		frames = FlxAtlasFrames.fromSparrow('${Directory.imagesFolder}/storyMode/campaign_menu_UI_characters.png',
			'${Directory.imagesFolder}/storyMode/campaign_menu_UI_characters.xml');
		animation.addByPrefix('bf', "BF idle dance white", 24);
		animation.addByPrefix('bfConfirm', 'BF HEY!!', 24, false);
		animation.addByPrefix('dad', "Dad idle dance BLACK LINE", 24);
		animation.addByPrefix('spooky', "spooky dance idle BLACK LINES", 24);
		animation.addByPrefix('pico', "Pico Idle Dance", 24);
		animation.addByPrefix('mom', "Mom Idle BLACK LINES", 24);
		animation.addByPrefix('parents-christmas', "Parent Christmas Idle", 24);
		animation.addByPrefix('senpai', "SENPAI idle Black Lines", 24);
		animation.addByPrefix('gf', "GF Dancing Beat WHITE", 24);
		updateHitbox();
		antialiasing = PrismPrefs.antialiasing;
		animation.play(character);
	}
}
