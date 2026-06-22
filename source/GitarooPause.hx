// done
package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;

class GitarooPause extends MusicBeatState
{
	var replayButton:FlxSprite;
	var cancelButton:FlxSprite;

	var replaySelect:Bool = false;

	override function create()
	{
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		var bg:FlxSprite = new FlxSprite().loadGraphic('${Directory.imagesFolder}/ui/pauseAlt/pauseBG.png');
		add(bg);

		var bf:FlxSprite = new FlxSprite(0, 30);
		bf.frames = FlxAtlasFrames.fromSparrow('${Directory.imagesFolder}/ui/pauseAlt/bfLol.png', '${Directory.imagesFolder}/ui/pauseAlt/bfLol.xml');
		bf.animation.addByPrefix('lol', "funnyThing", 13);
		bf.animation.play('lol');
		bf.screenCenter(X);
		bf.antialiasing = PrismPrefs.antialiasing;
		add(bf);

		replayButton = new FlxSprite(FlxG.width * 0.28, FlxG.height * 0.7);
		replayButton.frames = FlxAtlasFrames.fromSparrow('${Directory.imagesFolder}/ui/pauseAlt/pauseUI.png',
			'${Directory.imagesFolder}/ui/pauseAlt/pauseUI.xml');
		replayButton.animation.addByPrefix('selected', 'bluereplay', 0, false);
		replayButton.animation.appendByPrefix('selected', 'yellowreplay');
		replayButton.animation.play('selected');
		replayButton.antialiasing = PrismPrefs.antialiasing;
		add(replayButton);

		cancelButton = new FlxSprite(FlxG.width * 0.58, replayButton.y);
		cancelButton.frames = FlxAtlasFrames.fromSparrow('${Directory.imagesFolder}/ui/pauseAlt/pauseUI.png',
			'${Directory.imagesFolder}/ui/pauseAlt/pauseUI.xml');
		cancelButton.animation.addByPrefix('selected', 'bluecancel', 0, false);
		cancelButton.animation.appendByPrefix('selected', 'cancelyellow');
		cancelButton.animation.play('selected');
		cancelButton.antialiasing = PrismPrefs.antialiasing;
		add(cancelButton);

		changeThing();

		super.create();
	}

	override function update(elapsed:Float)
	{
		if (controls.LEFT_P || controls.RIGHT_P)
			changeThing();

		if (controls.ACCEPT)
		{
			if (replaySelect)
				FlxG.switchState(new PlayState());
			else
				FlxG.switchState(new MainMenuState());
		}

		super.update(elapsed);
	}

	function changeThing():Void
	{
		replaySelect = !replaySelect;

		if (replaySelect)
		{
			cancelButton.animation.curAnim.curFrame = 0;
			replayButton.animation.curAnim.curFrame = 1;
		}
		else
		{
			cancelButton.animation.curAnim.curFrame = 1;
			replayButton.animation.curAnim.curFrame = 0;
		}
	}
}
