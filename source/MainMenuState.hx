// done
package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;

using StringTools;

class MainMenuState extends MusicBeatState
{
	static var initialized:Bool = false;

	var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;

	var optionShit:Array<String> = ['story mode', 'freeplay', 'options'];

	var magenta:FlxSprite;

	override function create()
	{
		if (!initialized)
		{
			PrismPrefs.loadPrefs();
			initialized = true;
		}

		FlxG.mouse.visible = true;

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		if (!FlxG.sound.music.playing)
			FlxG.sound.playMusic('${Directory.musicFolder}/freakyMenu.ogg');

		persistentUpdate = persistentDraw = true;

		var bg:FlxSprite = new FlxSprite(-80).loadGraphic('${Directory.imagesFolder}/mainMenu/menuBG.png');
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = PrismPrefs.antialiasing;
		add(bg);

		magenta = new FlxSprite(-80).loadGraphic('${Directory.imagesFolder}/mainMenu/menuBGMagenta.png');
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.antialiasing = PrismPrefs.antialiasing;
		magenta.visible = false;
		if (PrismPrefs.flashing)
			add(magenta);
		// magenta.scrollFactor.set();

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		for (i in 0...optionShit.length)
		{
			var menuItem:FlxSprite = new FlxSprite(0, 60 + (i * 160));
			menuItem.frames = FlxAtlasFrames.fromSparrow('${Directory.imagesFolder}/mainMenu/FNF_main_menu_assets.png',
				'${Directory.imagesFolder}/mainMenu/FNF_main_menu_assets.xml');
			menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
			menuItem.animation.play('idle');
			menuItem.scrollFactor.set();
			menuItem.screenCenter(X);
			menuItem.antialiasing = PrismPrefs.antialiasing;
			menuItem.ID = i;
			menuItems.add(menuItem);
		}

		var versionShit:FlxText = new FlxText(5, FlxG.height - 33, 0, "Prism Funkin' v" + Main.prismVer + "\n" + "Friday Night Funkin' v" + Main.funkinVer, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat('${Directory.fontsFolder}/vcr.ttf', 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		versionShit.antialiasing = PrismPrefs.antialiasing;
		add(versionShit);

		changeItem();

		Directory.dumpCache();

		super.create();
	}

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;

		if (!selectedSomethin)
		{
			if (controls.UP_P)
			{
				FlxG.sound.play('${Directory.soundsFolder}/scrollMenu.ogg');
				changeItem(-1);
			}

			if (controls.DOWN_P)
			{
				FlxG.sound.play('${Directory.soundsFolder}/scrollMenu.ogg');
				changeItem(1);
			}

			if (controls.BACK)
			{
				FlxG.sound.play('${Directory.soundsFolder}/cancelMenu.ogg');
				FlxG.switchState(new TitleState());
			}

			if (controls.ACCEPT)
				selectItem();

			menuItems.forEach(function(spr:FlxSprite)
			{
				if (FlxG.mouse.overlaps(spr))
				{
					if (curSelected != spr.ID)
					{
						curSelected = spr.ID;
						changeItem();
						FlxG.sound.play('${Directory.soundsFolder}/scrollMenu.ogg');
					}

					if (FlxG.mouse.justPressed)
						selectItem();
				}
			});
		}

		super.update(elapsed);

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.screenCenter(X);
		});
	}

	function selectItem()
	{
		selectedSomethin = true;
		FlxG.mouse.visible = false;

		FlxG.sound.play('${Directory.soundsFolder}/confirmMenu.ogg');

		if (PrismPrefs.flashing)
			FlxFlicker.flicker(magenta, 1.1, 0.15, false);

		menuItems.forEach(function(spr:FlxSprite)
		{
			if (curSelected != spr.ID)
			{
				FlxTween.tween(spr, {alpha: 0}, 0.4, {
					ease: FlxEase.quadOut,
					onComplete: function(twn:FlxTween)
					{
						spr.kill();
					}
				});
			}
			else
			{
				new flixel.util.FlxTimer().start(1.1, function(tmr:flixel.util.FlxTimer)
				{
					var daChoice:String = optionShit[curSelected];
					switch (daChoice)
					{
						case 'story mode':
							FlxG.switchState(new StoryMenuState());
						case 'freeplay':
							FlxG.switchState(new FreeplayState());
						case 'options':
							FlxG.switchState(new OptionsMenuState());
					}
				});
			}
		});
	}

	function changeItem(huh:Int = 0)
	{
		curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');
			if (spr.ID == curSelected)
				spr.animation.play('selected');
			spr.updateHitbox();
		});
	}
}
