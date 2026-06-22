// done
package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;

class OptionsMenuState extends MusicBeatState
{
	public static var fromGame:Bool = false;

	var curSelected:Int = 0;
	var options:Array<String> = [
		'Keybind Preset',
		'Ghost Tapping',
		'Downscroll',
		'Antialiasing',
		'Flashing Lights',
		'Cam Movement On Note Hit',
		'Engine Branding',
		'Note Clicks',
		'Old Game Over'
	];

	private var grpControls:FlxTypedGroup<Alphabet>;
	private var descText:FlxText;

	override function create()
	{
		if (fromGame && (FlxG.sound.music == null || !FlxG.sound.music.playing))
			FlxG.sound.playMusic('${Directory.musicFolder}/freakyMenu.ogg');

		var menuBG:FlxSprite = new FlxSprite().loadGraphic('${Directory.imagesFolder}/mainMenu/menuBGMagenta.png');
		menuBG.updateHitbox();
		menuBG.screenCenter();
		menuBG.antialiasing = PrismPrefs.antialiasing;
		add(menuBG);

		grpControls = new FlxTypedGroup<Alphabet>();
		add(grpControls);

		for (i in 0...options.length)
		{
			var controlLabel:Alphabet = new Alphabet(0, (70 * i) + 30, options[i], true, false);
			controlLabel.isMenuItem = true;
			controlLabel.targetY = i;
			grpControls.add(controlLabel);
		}

		descText = new FlxText(5, FlxG.height - 18, 0, "", 16);
		descText.setFormat('${Directory.fontsFolder}/vcr.ttf', 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		descText.scrollFactor.set();
		descText.antialiasing = PrismPrefs.antialiasing;
		add(descText);

		changeSelection();

		super.create();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.mouse.wheel != 0)
			changeSelection(FlxG.mouse.wheel > 0 ? -1 : 1);

		if (controls.BACK)
		{
			FlxG.sound.play('${Directory.soundsFolder}/cancelMenu.ogg');

			if (fromGame)
			{
				fromGame = false;
				if (FlxG.sound.music != null)
					FlxG.sound.music.stop();
				FlxG.switchState(new PlayState());
			}
			else
				FlxG.switchState(new MainMenuState());
		}

		if (controls.UP_P)
			changeSelection(-1);
		if (controls.DOWN_P)
			changeSelection(1);

		if (controls.ACCEPT)
			updateValue();
	}

	function updateValue()
	{
		var option:String = options[curSelected];

		switch (option)
		{
			case 'Keybind Preset':
				var presets:Array<String> = ['WASD', 'DFJK', 'ASKL', 'QWOP', 'ZX,.'];
				var curIdx:Int = presets.indexOf(PrismPrefs.keyPreset);
				curIdx = (curIdx + 1) % presets.length;
				PrismPrefs.applyKeys(presets[curIdx]);
			case 'Ghost Tapping':
				PrismPrefs.ghostTapping = !PrismPrefs.ghostTapping;
			case 'Downscroll':
				PrismPrefs.downscroll = !PrismPrefs.downscroll;
			case 'Antialiasing':
				PrismPrefs.antialiasing = !PrismPrefs.antialiasing;
			case 'Flashing Lights':
				PrismPrefs.flashing = !PrismPrefs.flashing;
			case 'Cam Movement On Note Hit':
				PrismPrefs.camNoteHit = !PrismPrefs.camNoteHit;
			case 'Engine Branding':
				PrismPrefs.engineBrand = !PrismPrefs.engineBrand;
			case 'Note Clicks':
				PrismPrefs.noteClicks = !PrismPrefs.noteClicks;
			case 'Old Game Over':
				PrismPrefs.oldGameOver = !PrismPrefs.oldGameOver;
		}
		PrismPrefs.savePrefs();

		changeSelection(); // refresh display
	}

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play('${Directory.soundsFolder}/scrollMenu.ogg');

		curSelected += change;

		if (curSelected < 0)
			curSelected = grpControls.length - 1;
		if (curSelected >= grpControls.length)
			curSelected = 0;

		var option:String = options[curSelected];
		var val:String = "";
		switch (option)
		{
			case 'Keybind Preset':
				val = PrismPrefs.keyPreset;
			case 'Ghost Tapping':
				val = PrismPrefs.ghostTapping ? "ON" : "OFF";
			case 'Downscroll':
				val = PrismPrefs.downscroll ? "ON" : "OFF";
			case 'Antialiasing':
				val = PrismPrefs.antialiasing ? "ON" : "OFF";
			case 'Flashing Lights':
				val = PrismPrefs.flashing ? "ON" : "OFF";
			case 'Cam Movement On Note Hit':
				val = PrismPrefs.camNoteHit ? "ON" : "OFF";
			case 'Engine Branding':
				val = PrismPrefs.engineBrand ? "ON" : "OFF";
			case 'Note Clicks':
				val = PrismPrefs.noteClicks ? "ON" : "OFF";
			case 'Old Game Over':
				val = PrismPrefs.oldGameOver ? "ON" : "OFF";
		}

		descText.text = 'Current Value: $val';

		var bullShit:Int = 0;

		for (item in grpControls.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
	}
}
