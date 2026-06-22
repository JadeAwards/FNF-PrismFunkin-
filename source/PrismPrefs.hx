// done
package;

import Controls.Control;
import PlayerSettings;
import flixel.FlxG;
import flixel.input.keyboard.FlxKey;

class PrismPrefs
{
	public static var keyPreset:String = 'WASD';
	public static var ghostTapping:Bool = true;
	public static var downscroll:Bool = false;
	public static var antialiasing:Bool = true;
	public static var flashing:Bool = true;
	public static var camNoteHit:Bool = true;
	public static var engineBrand:Bool = true;
	public static var noteClicks:Bool = false;
	public static var oldGameOver:Bool = false;

	public static function savePrefs()
	{
		FlxG.save.data.keyPreset = keyPreset;
		FlxG.save.data.ghostTapping = ghostTapping;
		FlxG.save.data.downscroll = downscroll;
		FlxG.save.data.antialiasing = antialiasing;
		FlxG.save.data.flashing = flashing;
		FlxG.save.data.camNoteHit = camNoteHit;
		FlxG.save.data.engineBrand = engineBrand;
		FlxG.save.data.noteClicks = noteClicks;
		FlxG.save.data.oldGameOver = oldGameOver;
		FlxG.save.flush();
	}

	public static function loadPrefs()
	{
		if (FlxG.save.data.keyPreset != null)
			keyPreset = FlxG.save.data.keyPreset;
		if (FlxG.save.data.ghostTapping != null)
			ghostTapping = FlxG.save.data.ghostTapping;
		if (FlxG.save.data.downscroll != null)
			downscroll = FlxG.save.data.downscroll;
		if (FlxG.save.data.antialiasing != null)
			antialiasing = FlxG.save.data.antialiasing;
		if (FlxG.save.data.flashing != null)
			flashing = FlxG.save.data.flashing;
		if (FlxG.save.data.camNoteHit != null)
			camNoteHit = FlxG.save.data.camNoteHit;
		if (FlxG.save.data.engineBrand != null)
			engineBrand = FlxG.save.data.engineBrand;
		if (FlxG.save.data.noteClicks != null)
			noteClicks = FlxG.save.data.noteClicks;
		if (FlxG.save.data.oldGameOver != null)
			oldGameOver = FlxG.save.data.oldGameOver;

		applyKeys(keyPreset);
	}

	public static function applyKeys(preset:String)
	{
		keyPreset = preset;

		var keys:Array<FlxKey> = [A, S, W, D];
		switch (preset)
		{
			case 'DFJK':
				keys = [D, F, J, K];
			case 'ASKL':
				keys = [A, S, K, L];
			case 'QWOP':
				keys = [Q, W, O, P];
			case 'ZX,.':
				keys = [Z, X, COMMA, PERIOD];
		}

		PlayerSettings.player1.controls.replaceBinding(Control.LEFT, Keys, keys[0], null);
		PlayerSettings.player1.controls.replaceBinding(Control.DOWN, Keys, keys[1], null);
		PlayerSettings.player1.controls.replaceBinding(Control.UP, Keys, keys[2], null);
		PlayerSettings.player1.controls.replaceBinding(Control.RIGHT, Keys, keys[3], null);
	}
}
