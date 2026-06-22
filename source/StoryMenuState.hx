// done
package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import lime.net.curl.CURLCode;

using StringTools;

typedef WeekCharacterTransform =
{
	var x:Float;
	var y:Float;
	var scaleX:Float;
	var scaleY:Float;
}

class StoryMenuState extends MusicBeatState
{
	var scoreText:FlxText;

	var weekData:Array<Dynamic> = [
		['Tutorial'],
		['Bopeebo', 'Fresh', 'Dadbattle'],
		['Spookeez', 'South'],
		['Pico', 'Philly', "Blammed"],
		['Satin-Panties', "High", "Milf"],
		['Cocoa', 'Eggnog', 'Winter-Horrorland'],
		['Senpai', 'Roses', 'Thorns']
	];
	var curDifficulty:Int = 1;

	var weekCharacters:Array<Dynamic> = [
		['dad', 'bf', 'gf'],
		['dad', 'bf', 'gf'],
		['spooky', 'bf', 'gf'],
		['pico', 'bf', 'gf'],
		['mom', 'bf', 'gf'],
		['parents-christmas', 'bf', 'gf'],
		['senpai', 'bf', 'gf']
	];

	var weekNames:Array<String> = [
		"",
		"Daddy Dearest",
		"Spooky Month",
		"PICO",
		"MOMMY MUST MURDER",
		"RED SNOW",
		"hating simulator ft. moawling"
	];

	var txtWeekTitle:FlxText;

	var weekColors:Array<FlxColor> = [
		0xFFA5004D, // Tutorial
		0xFFAF66CE, // Week 1
		0xFFD57E00, // Week 2
		0xFFB7D855, // Week 3
		0xFFD8558E, // Week 4
		0xFFAF66CE, // Week 5
		0xFFFFAA6F // Week 6
	];

	var curWeek:Int = 0;

	var txtTracklist:FlxText;

	var grpWeekText:FlxTypedGroup<MenuItem>;
	var grpWeekCharacters:FlxTypedGroup<MenuCharacter>;
	var lastStoryBeat:Int = 0;

	var difficultySelectors:FlxGroup;
	var sprDifficulty:FlxSprite;
	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;
	var yellowBG:FlxSprite;

	// stuff for debugging!!!
	var debugBannerText:FlxText;
	var debugHintText:FlxText;
	var debugHelpOverlay:FlxSprite;
	var debugHelpText:FlxText;
	var debugMode:Bool = false;
	var debugHelpVisible:Bool = false;
	var charDebugSelected:Int = 0;
	var weekCharacterTransforms:Array<Array<WeekCharacterTransform>>;
	// Flag to require two BACK presses to exit when in debug mode
	var pendingDebugExit:Bool = false;

	override function create()
	{
		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		if (FlxG.sound.music != null)
		{
			if (!FlxG.sound.music.playing)
				FlxG.sound.playMusic('${Directory.musicFolder}/freakyMenu.ogg');
		}

		persistentUpdate = persistentDraw = true;

		scoreText = new FlxText(10, 10, 0, "SCORE: 49324858", 36);
		scoreText.setFormat('${Directory.fontsFolder}/vcr.ttf', 32);
		scoreText.antialiasing = PrismPrefs.antialiasing;

		txtWeekTitle = new FlxText(FlxG.width * 0.7, 10, 0, "", 32);
		txtWeekTitle.setFormat('${Directory.fontsFolder}/vcr.ttf', 32, FlxColor.WHITE, RIGHT);
		txtWeekTitle.antialiasing = PrismPrefs.antialiasing;
		txtWeekTitle.alpha = 0.7;

		var ui_tex = FlxAtlasFrames.fromSparrow('${Directory.imagesFolder}/storyMode/campaign_menu_UI_assets.png',
			'${Directory.imagesFolder}/storyMode/campaign_menu_UI_assets.xml');
		yellowBG = new FlxSprite(0, 56).makeGraphic(FlxG.width, 400, FlxColor.WHITE);

		grpWeekText = new FlxTypedGroup<MenuItem>();
		add(grpWeekText);

		var blackBarThingie:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, 56, FlxColor.BLACK);
		add(blackBarThingie);

		grpWeekCharacters = new FlxTypedGroup<MenuCharacter>();
		weekCharacterTransforms = [];

		for (weekIndex in 0...weekCharacters.length)
		{
			var weekTransforms:Array<WeekCharacterTransform> = [];
			for (charIndex in 0...weekCharacters[weekIndex].length)
				weekTransforms.push(getDefaultWeekCharacterTransform(weekCharacters[weekIndex][charIndex], charIndex));
			weekCharacterTransforms.push(weekTransforms);
		}

		for (i in 0...weekData.length)
		{
			var weekThing:MenuItem = new MenuItem(0, yellowBG.y + yellowBG.height + 10, i);
			weekThing.screenCenter(X);
			// weekThing.updateHitbox();
			weekThing.antialiasing = PrismPrefs.antialiasing;
			weekThing.y += ((weekThing.height + 20) * i);
			weekThing.targetY = i;
			grpWeekText.add(weekThing);
		}

		for (char in 0...3)
		{
			var weekCharacterThing:MenuCharacter = new MenuCharacter(0, weekCharacters[curWeek][char]);
			weekCharacterThing.antialiasing = PrismPrefs.antialiasing;
			applyWeekCharacterTransform(weekCharacterThing, weekCharacterTransforms[curWeek][char]);
			grpWeekCharacters.add(weekCharacterThing);
		}

		difficultySelectors = new FlxGroup();
		add(difficultySelectors);

		var difficultyOffsetX:Int = 0;

		leftArrow = new FlxSprite(grpWeekText.members[0].x + grpWeekText.members[0].width + 10 + difficultyOffsetX, grpWeekText.members[0].y + 10);
		leftArrow.frames = ui_tex;
		leftArrow.animation.addByPrefix('idle', "arrow left");
		leftArrow.animation.addByPrefix('press', "arrow push left");
		leftArrow.animation.play('idle');
		leftArrow.antialiasing = PrismPrefs.antialiasing;
		difficultySelectors.add(leftArrow);

		sprDifficulty = new FlxSprite(leftArrow.x + 130, leftArrow.y);
		sprDifficulty.frames = ui_tex;
		sprDifficulty.animation.addByPrefix('easy', 'EASY');
		sprDifficulty.animation.addByPrefix('normal', 'NORMAL');
		sprDifficulty.animation.addByPrefix('hard', 'HARD');
		sprDifficulty.animation.play('easy');
		sprDifficulty.antialiasing = PrismPrefs.antialiasing;
		difficultySelectors.add(sprDifficulty);

		changeDifficulty();

		rightArrow = new FlxSprite(sprDifficulty.x + sprDifficulty.width + 50, leftArrow.y);
		rightArrow.frames = ui_tex;
		rightArrow.animation.addByPrefix('idle', 'arrow right');
		rightArrow.animation.addByPrefix('press', "arrow push right", 24, false);
		rightArrow.animation.play('idle');
		rightArrow.antialiasing = PrismPrefs.antialiasing;
		difficultySelectors.add(rightArrow);

		add(yellowBG);
		add(grpWeekCharacters);

		txtTracklist = new FlxText(FlxG.width * 0.05, yellowBG.x + yellowBG.height + 100, 0, "Tracks", 32);
		txtTracklist.alignment = CENTER;
		txtTracklist.font = '${Directory.fontsFolder}/vcr.ttf';
		txtTracklist.color = 0xFFe55777;
		txtTracklist.antialiasing = PrismPrefs.antialiasing;
		add(txtTracklist);
		add(scoreText);
		add(txtWeekTitle);

		#if debug
		debugBannerText = new FlxText(10, 60, FlxG.width - 20, "DEBUG MODE", 24);
		debugBannerText.setFormat(24, FlxColor.WHITE, LEFT);
		debugBannerText.antialiasing = PrismPrefs.antialiasing;

		debugHintText = new FlxText(5, FlxG.height - 22, FlxG.width, "PRESS F1 FOR INSTRUCTIONS", 16);
		debugHintText.setFormat(16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		debugHintText.antialiasing = PrismPrefs.antialiasing;

		debugHelpOverlay = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		debugHelpOverlay.alpha = 0.6;
		debugHelpOverlay.scrollFactor.set();
		debugHelpOverlay.visible = false;

		var helpText:String = "7 - TOGGLE DEBUG MODE\n" + "F1 - TOGGLE THIS HELP\n\n" + "1 / 2 / 3 - SELECT CHARACTER SLOT\n"
			+ "I / K - MOVE SELECTED CHARACTER UP / DOWN\n" + "J / L - MOVE SELECTED CHARACTER LEFT / RIGHT\n" + "[ / ] - SCALE SELECTED CHARACTER\n"
			+ "SHIFT - MAKE CHANGES FASTER\n" + ". - PRINT CURRENT CHARACTER VALUES";

		debugHelpText = new FlxText(0, 0, Std.int(FlxG.width * 0.8), helpText, 24);
		debugHelpText.setFormat(24, FlxColor.WHITE, CENTER);
		debugHelpText.scrollFactor.set();
		debugHelpText.x = (FlxG.width - debugHelpText.width) * 0.5;
		debugHelpText.y = (FlxG.height - debugHelpText.height) * 0.5;
		debugHelpText.screenCenter();
		debugHelpText.antialiasing = PrismPrefs.antialiasing;
		debugHelpText.visible = false;
		add(debugBannerText);
		add(debugHintText);
		add(debugHelpOverlay);
		add(debugHelpText);
		#end

		updateText();

		super.create();
	}

	override function update(elapsed:Float)
	{
		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, 0.5));

		scoreText.text = 'WEEK SCORE: ${FlxStringUtil.formatMoney(lerpScore, false)}';

		txtWeekTitle.text = weekNames[curWeek].toUpperCase();
		txtWeekTitle.x = FlxG.width - (txtWeekTitle.width + 10);

		// FlxG.watch.addQuick('font', scoreText.font);

		#if debug
		if (FlxG.keys.justPressed.SEVEN)
		{
			if (PrismPrefs.flashing)
				FlxG.camera.flash(FlxColor.WHITE, 0.5);
			FlxG.sound.play('${Directory.soundsFolder}/confirmMenu.ogg');
			debugMode = !debugMode;
			debugHelpVisible = false;
			refreshDebugOverlay();
		}

		if (debugMode)
		{
			if (FlxG.keys.justPressed.F1)
			{
				FlxG.sound.play('${Directory.soundsFolder}/scrollMenu.ogg');
				debugHelpVisible = !debugHelpVisible;
				refreshDebugOverlay();
			}

			debugHintText.visible = !debugHelpVisible;

			if (!debugHelpVisible)
			{
				if (FlxG.keys.justPressed.ONE)
					charDebugSelected = 0;
				if (FlxG.keys.justPressed.TWO)
					charDebugSelected = 1;
				if (FlxG.keys.justPressed.THREE)
					charDebugSelected = 2;

				var spr = grpWeekCharacters.members[charDebugSelected];
				var transform = weekCharacterTransforms[curWeek][charDebugSelected];
				var multiplier:Float = FlxG.keys.pressed.SHIFT ? 10 : 1;
				if (FlxG.keys.pressed.I)
					transform.y -= 1 * multiplier;
				if (FlxG.keys.pressed.K)
					transform.y += 1 * multiplier;
				if (FlxG.keys.pressed.J)
					transform.x -= 1 * multiplier;
				if (FlxG.keys.pressed.L)
					transform.x += 1 * multiplier;

				if (FlxG.keys.pressed.LBRACKET)
				{
					transform.scaleX -= 0.01 * multiplier;
					transform.scaleY -= 0.01 * multiplier;
				}
				if (FlxG.keys.pressed.RBRACKET)
				{
					transform.scaleX += 0.01 * multiplier;
					transform.scaleY += 0.01 * multiplier;
				}

				applyWeekCharacterTransform(spr, transform);

				if (FlxG.keys.justPressed.COMMA)
				{
					trace('Character: ${spr.character}');
					trace('Position: ${transform.x}, ${transform.y}');
					trace('Scale: ${transform.scaleX}');
				}
			}

			debugBannerText.text = 'DEBUG MODE - SLOT ${charDebugSelected + 1}/3';
		}
		else
		{
			debugHelpVisible = false;
			refreshDebugOverlay();
		}
		#end

		if (!movedBack)
		{
			if (!selectedWeek && (!debugMode || !debugHelpVisible))
			{
				if (controls.UP_P)
					changeWeek(-1);
				if (controls.DOWN_P)
					changeWeek(1);

				if (controls.RIGHT)
					rightArrow.animation.play('press')
				else
					rightArrow.animation.play('idle');

				if (controls.LEFT)
					leftArrow.animation.play('press');
				else
					leftArrow.animation.play('idle');

				if (controls.RIGHT_P)
					changeDifficulty(1);
				if (controls.LEFT_P)
					changeDifficulty(-1);
			}

			if (controls.ACCEPT && (!debugMode || !debugHelpVisible))
				selectWeek();
		}

		if (controls.BACK && !movedBack && !selectedWeek && (!debugMode || !debugHelpVisible))
		{
			if (debugMode)
			{
				if (pendingDebugExit)
				{
					FlxG.sound.play('${Directory.soundsFolder}/cancelMenu.ogg');
					movedBack = true;
					FlxG.switchState(new MainMenuState());
				}
				else
				{
					FlxG.sound.play('${Directory.soundsFolder}/cancelMenu.ogg');
					pendingDebugExit = true;
					// Flash the screen to indicate exit from debug UI
					if (PrismPrefs.flashing)
						FlxG.camera.flash(FlxColor.WHITE, 0.5);
					// Disable debug mode and hide UI
					debugMode = false;
					debugHelpVisible = false;
					refreshDebugOverlay();
				}
			}
			else
			{
				FlxG.sound.play('${Directory.soundsFolder}/cancelMenu.ogg');
				movedBack = true;
				FlxG.switchState(new MainMenuState());
			}
		}

		super.update(elapsed);
	}

	override function beatHit()
	{
		super.beatHit();

		for (beat in lastStoryBeat...curBeat + 1)
		{
			if (beat % 2 == 0)
			{
				grpWeekCharacters.forEach(function(char:MenuCharacter)
				{
					if (char.animation.curAnim != null)
						char.animation.play(char.animation.curAnim.name, true);
				});
			}
		}

		lastStoryBeat = curBeat;
	}

	var movedBack:Bool = false;
	var selectedWeek:Bool = false;
	var stopspamming:Bool = false;

	function selectWeek()
	{
		if (stopspamming == false)
		{
			FlxG.sound.play('${Directory.soundsFolder}/confirmMenu.ogg');

			grpWeekText.members[curWeek].week.animation.resume();
			grpWeekCharacters.members[1].animation.play('bfConfirm');
			stopspamming = true;
		}

		PlayState.storyPlaylist = weekData[curWeek];
		PlayState.isStoryMode = true;
		selectedWeek = true;

		var diffic = "";
		switch (curDifficulty)
		{
			case 0:
				diffic = '-easy';
			case 2:
				diffic = '-hard';
		}

		PlayState.storyDifficulty = curDifficulty;
		PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + diffic, PlayState.storyPlaylist[0].toLowerCase());
		PlayState.storyWeek = curWeek;
		PlayState.campaignScore = 0;
		new FlxTimer().start(1, function(tmr:FlxTimer)
		{
			if (FlxG.sound.music != null)
				FlxG.sound.music.stop();
			FlxG.switchState(new PlayState());
		});
	}

	function changeDifficulty(change:Int = 0):Void
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = 2;
		if (curDifficulty > 2)
			curDifficulty = 0;

		sprDifficulty.offset.x = 0;

		switch (curDifficulty)
		{
			case 0:
				sprDifficulty.animation.play('easy');
				sprDifficulty.offset.x = 20;
			case 1:
				sprDifficulty.animation.play('normal');
				sprDifficulty.offset.x = 70;
			case 2:
				sprDifficulty.animation.play('hard');
				sprDifficulty.offset.x = 20;
		}

		sprDifficulty.alpha = 0;

		// USING THESE WEIRD VALUES SO THAT IT DOESNT FLOAT UP
		sprDifficulty.y = leftArrow.y - 15;
		intendedScore = Highscore.getWeekScore(curWeek, curDifficulty);

		#if !switch
		intendedScore = Highscore.getWeekScore(curWeek, curDifficulty);
		#end

		FlxTween.tween(sprDifficulty, {y: leftArrow.y + 15, alpha: 1}, 0.07);
	}

	var lerpScore:Int = 0;
	var intendedScore:Int = 0;

	function changeWeek(change:Int = 0):Void
	{
		curWeek += change;

		if (curWeek >= weekData.length)
			curWeek = 0;
		if (curWeek < 0)
			curWeek = weekData.length - 1;

		var bullShit:Int = 0;
		for (item in grpWeekText.members)
		{
			item.targetY = bullShit - curWeek;
			if (item.targetY == Std.int(0))
				item.alpha = 1;
			else
				item.alpha = 0.6;
			bullShit++;
		}

		FlxG.sound.play('${Directory.soundsFolder}/scrollMenu.ogg');

		updateText();
		yellowBG.color = weekColors[curWeek];
	}

	function updateText()
	{
		for (char in 0...3)
		{
			var weekCharacterThing = grpWeekCharacters.members[char];
			weekCharacterThing.animation.play(weekCharacters[curWeek][char]);
			applyWeekCharacterTransform(weekCharacterThing, weekCharacterTransforms[curWeek][char]);
		}
		txtTracklist.text = "Tracks:\n";

		var stringThing:Array<String> = weekData[curWeek];
		for (i in stringThing)
			txtTracklist.text += '\n- $i';
		txtTracklist.text = txtTracklist.text.toUpperCase();
		txtTracklist.screenCenter(X);
		txtTracklist.x -= FlxG.width * 0.35;

		#if !switch
		intendedScore = Highscore.getWeekScore(curWeek, curDifficulty);
		#end
	}

	function applyWeekCharacterTransform(character:MenuCharacter, transform:WeekCharacterTransform):Void
	{
		character.setPosition(transform.x, transform.y);
		character.scale.set(transform.scaleX, transform.scaleY);
		character.updateHitbox();
	}

	function getDefaultWeekCharacterTransform(character:String, charIndex:Int):WeekCharacterTransform
	{
		var transform:WeekCharacterTransform = {
			x: (FlxG.width * 0.25) * (1 + charIndex) - 150,
			y: 70,
			scaleX: 1,
			scaleY: 1
		};

		switch (character)
		{
			case 'bf':
				transform.scaleX = 0.9;
				transform.scaleY = 0.9;
				transform.x -= 80;
			case 'dad':
				transform.scaleX = 0.47;
				transform.scaleY = 0.47;
				transform.x = 117;
				transform.y = 80;
			case 'spooky':
				transform.scaleX = 0.55;
				transform.scaleY = 0.55;
				transform.x = 35;
				transform.y = 143;
			case 'pico':
				transform.scaleX = 0.6;
				transform.scaleY = 0.6;
				transform.x = 78;
				transform.y = 160;
			case 'mom':
				transform.scaleX = 0.46;
				transform.scaleY = 0.46;
				transform.x = 117;
				transform.y = 63;
			case 'parents-christmas':
				transform.scaleX = 0.4;
				transform.scaleY = 0.4;
				transform.x = 7;
				transform.y = 129;
			case 'senpai':
				transform.scaleX = 0.98;
				transform.scaleY = 0.98;
				transform.x = 36;
				transform.y = 161;
			case 'gf':
				transform.scaleX = 0.53;
				transform.scaleY = 0.53;
				transform.x = 869;
				transform.y = 96;
		}
		return transform;
	}

	function refreshDebugOverlay():Void
	{
		if (debugBannerText != null)
			debugBannerText.visible = debugMode;

		if (debugHintText != null)
			debugHintText.visible = debugMode && !debugHelpVisible;

		if (debugHelpOverlay != null)
			debugHelpOverlay.visible = debugMode && debugHelpVisible;

		if (debugHelpText != null)
			debugHelpText.visible = debugMode && debugHelpVisible;
	}
}
