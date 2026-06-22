// done
package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.system.FlxSound;
import flixel.util.FlxColor;

class PauseSubState extends MusicBeatSubstate
{
	var grpMenuShit:FlxTypedGroup<Alphabet>;

	var menuItems:Array<String> = ['Resume', 'Restart Song', 'Options', 'Exit to Menu'];
	var curSelected:Int = 0;

	var pauseMusic:FlxSound;

	var fromFreeplay:Bool = false;
	var fromStoryMode:Bool = false;

	public function new(x:Float, y:Float)
	{
		super();

		fromFreeplay = true;
		fromStoryMode = PlayState.isStoryMode;

		pauseMusic = new FlxSound().loadEmbedded('${Directory.musicFolder}/breakfast.ogg', true, true);
		pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));
		pauseMusic.volume = 0;
		FlxG.sound.list.add(pauseMusic);

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.scrollFactor.set();
		bg.alpha = 0.6;
		add(bg);

		grpMenuShit = new FlxTypedGroup<Alphabet>();
		add(grpMenuShit);

		for (i in 0...menuItems.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, menuItems[i], true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpMenuShit.add(songText);
		}

		changeSelection();

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}

	override function update(elapsed:Float)
	{
		if (pauseMusic.volume < 0.5)
			pauseMusic.volume += 0.01 * elapsed;

		super.update(elapsed);

		if (FlxG.mouse.wheel != 0)
			changeSelection(FlxG.mouse.wheel > 0 ? -1 : 1);

		var upP = controls.UP_P;
		var downP = controls.DOWN_P;
		var accepted = controls.ACCEPT;

		if (upP)
			changeSelection(-1);
		if (downP)
			changeSelection(1);

		if (accepted)
		{
			var daSelected:String = menuItems[curSelected];
			switch (daSelected)
			{
				case "Resume":
					close();
				case "Restart Song":
					FlxG.resetState();
				case "Options":
					OptionsMenuState.fromGame = true;
					FlxG.switchState(new OptionsMenuState());
				case "Exit to Menu":
					if (fromStoryMode)
						FlxG.switchState(new StoryMenuState());
					else if (fromFreeplay)
						FlxG.switchState(new FreeplayState());
					else
						FlxG.switchState(new MainMenuState());
			}
		}
	}

	override function destroy()
	{
		pauseMusic.destroy();

		fromFreeplay = false;
		fromStoryMode = false;

		super.destroy();
	}

	function changeSelection(change:Int = 0):Void
	{
		FlxG.sound.play('${Directory.soundsFolder}/scrollMenu.ogg');

		curSelected += change;

		if (curSelected < 0)
			curSelected = menuItems.length - 1;
		if (curSelected >= menuItems.length)
			curSelected = 0;

		var bullShit:Int = 0;
		for (item in grpMenuShit.members)
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
