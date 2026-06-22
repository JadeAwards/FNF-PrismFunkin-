// done
package;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.net.FileReference;

using StringTools;

/**
	DEBUG MODE
**/
class AnimationDebug extends MusicBeatState
{
	var _file:FileReference;

	public static var fromGame:Bool = false;

	var bf:Boyfriend;
	var dad:Character;
	var gf:Character;
	var char:Character;
	var ghost:Character;

	var textAnim:FlxText;
	var ghostAlphaText:FlxText;
	var dumbTexts:FlxTypedGroup<FlxText>;
	var animList:Array<String> = [];

	var curAnim:Int = 0;
	var daAnim:String = '';

	var ghostAlpha:Float = 0.6;

	var camFollow:FlxObject;

	private var camHUD:FlxCamera;
	private var camGame:FlxCamera;

	var debugHintText:FlxText;
	var debugHelpOverlay:FlxSprite;
	var debugHelpText:FlxText;
	var debugHelpVisible:Bool = false;

	// from fps plus
	var flippedChars:Array<String> = ["pico"];

	public function new(daAnim:String = '')
	{
		super();

		this.daAnim = daAnim;
	}

	override function create()
	{
		// var gameCam:FlxCamera = FlxG.camera;
		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD, false);
		FlxG.cameras.setDefaultDrawTarget(camGame, true);

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		var gridBG:FlxSprite = FlxGridOverlay.create(10, 10, -1, -1);
		gridBG.scrollFactor.set(0.5, 0.5);
		add(gridBG);

		if (daAnim == null || daAnim == '')
			daAnim = 'bf';

		if (daAnim == 'bf')
		{
			bf = new Boyfriend(0, 0);
			char = bf;
			bf.screenCenter(X);
			bf.flipX = false;
			bf.debugMode = true;
			bf.antialiasing = PrismPrefs.antialiasing;
		}
		else if (daAnim == 'gf' || daAnim.startsWith('gf-'))
		{
			gf = new Character(0, 0, daAnim);
			char = gf;
			gf.screenCenter(X);
			gf.flipX = false;
			gf.debugMode = true;
			gf.antialiasing = PrismPrefs.antialiasing;
		}
		else
		{
			dad = new Character(0, 0, daAnim);
			char = dad;
			dad.screenCenter(X);
			dad.flipX = false;
			dad.debugMode = true;
			dad.antialiasing = PrismPrefs.antialiasing;
		}

		ghost = new Character(char.x, char.y, daAnim);
		ghost.animOffsets = new Map<String, Array<Dynamic>>();
		ghost.flipX = char.flipX;
		ghost.debugMode = true;
		ghost.alpha = ghostAlpha;
		ghost.color = FlxColor.BLACK;
		ghost.antialiasing = PrismPrefs.antialiasing;

		if (ghost.animation.getByName('idle') != null)
			ghost.playAnim('idle');
		else if (ghost.animation.getByName('danceRight') != null)
			ghost.playAnim('danceRight');

		if (ghost.animation.curAnim != null)
		{
			ghost.animation.curAnim.curFrame = ghost.animation.curAnim.numFrames - 1;
			ghost.animation.curAnim.pause();
		}

		add(ghost);
		add(char);

		if (dad != null)
			dad.flipX = flippedChars.contains(dad.curCharacter);
		if (ghost != null)
			ghost.flipX = flippedChars.contains(ghost.curCharacter);

		dumbTexts = new FlxTypedGroup<FlxText>();
		add(dumbTexts);

		textAnim = new FlxText(300, 16);
		textAnim.scrollFactor.set();
		textAnim.size = 26;
		textAnim.color = FlxColor.BLUE;
		textAnim.cameras = [camHUD];
		add(textAnim);

		ghostAlphaText = new FlxText(FlxG.width - 275, 16, 0, 'Ghost Alpha: $ghostAlpha', 24);
		ghostAlphaText.scrollFactor.set();
		ghostAlphaText.setFormat(null, 24, FlxColor.BLUE, RIGHT);
		ghostAlphaText.cameras = [camHUD];
		add(ghostAlphaText);

		debugHintText = new FlxText(5, FlxG.height - 22, FlxG.width, "PRESS F1 FOR INSTRUCTIONS", 16);
		debugHintText.setFormat(16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		debugHintText.antialiasing = PrismPrefs.antialiasing;
		debugHintText.cameras = [camHUD];
		add(debugHintText);

		var helpText:String = "F1 - TOGGLE THIS HELP\n\n" + "W / S - SELECT ANIMATION\n" + "SPACE - PLAY SELECTED ANIMATION\n"
			+ "UP / DOWN / LEFT / RIGHT - ADJUST OFFSETS\n" + "SHIFT - MAKE CHANGES FASTER\n" + "I / J / K / L - PAN CAMERA\n" + "Q / E - ZOOM OUT / IN\n"
			+ "[ / ] - ADJUST GHOST ALPHA\n" + ", - SAVE OFFSETS\n" + "ESCAPE - EXIT";

		debugHelpOverlay = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		debugHelpOverlay.alpha = 0.6;
		debugHelpOverlay.scrollFactor.set();
		debugHelpOverlay.visible = false;
		debugHelpOverlay.cameras = [camHUD];
		add(debugHelpOverlay);

		debugHelpText = new FlxText(0, 0, Std.int(FlxG.width * 0.8), helpText, 24);
		debugHelpText.setFormat(24, FlxColor.WHITE, CENTER);
		debugHelpText.scrollFactor.set();
		debugHelpText.screenCenter();
		debugHelpText.x = (FlxG.width - debugHelpText.width) * 0.5;
		debugHelpText.y = (FlxG.height - debugHelpText.height) * 0.5;
		debugHelpText.antialiasing = PrismPrefs.antialiasing;
		debugHelpText.visible = false;
		debugHelpText.cameras = [camHUD];
		add(debugHelpText);

		refreshDebugOverlay();

		genBoyOffsets();

		camFollow = new FlxObject(0, 0, 2, 2);
		camFollow.screenCenter();
		add(camFollow);

		FlxG.camera.follow(camFollow);

		super.create();
	}

	function refreshDebugOverlay():Void
	{
		if (debugHintText != null)
			debugHintText.visible = !debugHelpVisible;

		if (debugHelpOverlay != null)
			debugHelpOverlay.visible = debugHelpVisible;

		if (debugHelpText != null)
			debugHelpText.visible = debugHelpVisible;
	}

	function genBoyOffsets(pushList:Bool = true):Void
	{
		var daLoop:Int = 0;
		for (anim => offsets in char.animOffsets)
		{
			var text:FlxText = new FlxText(10, 20 + (18 * daLoop), 0, anim + ": " + offsets, 15);
			text.scrollFactor.set();
			text.color = FlxColor.BLUE;
			text.cameras = [camHUD];
			dumbTexts.add(text);

			if (pushList)
				animList.push(anim);

			daLoop++;
		}
	}

	function updateTexts():Void
	{
		dumbTexts.forEach(function(text:FlxText)
		{
			text.kill();
			dumbTexts.remove(text, true);
		});
	}

	override function update(elapsed:Float)
	{
		if (char.animation.curAnim != null)
			textAnim.text = char.animation.curAnim.name;
		else
			textAnim.text = "";
		ghostAlphaText.text = 'Ghost Alpha: ${FlxMath.roundDecimal(ghostAlpha, 2)}';

		if (FlxG.keys.justPressed.F1)
		{
			FlxG.sound.play('${Directory.soundsFolder}/scrollMenu.ogg');
			debugHelpVisible = !debugHelpVisible;
			refreshDebugOverlay();
		}

		if (!debugHelpVisible)
		{
			if (FlxG.keys.pressed.LBRACKET)
			{
				ghostAlpha -= 0.6 * elapsed;
				if (ghostAlpha < 0)
					ghostAlpha = 0;
				ghost.alpha = ghostAlpha;
			}
			if (FlxG.keys.pressed.RBRACKET)
			{
				ghostAlpha += 0.6 * elapsed;
				if (ghostAlpha > 1)
					ghostAlpha = 1;
				ghost.alpha = ghostAlpha;
			}

			var holdShift = FlxG.keys.pressed.SHIFT;
			var multiplier = 1;
			if (holdShift)
				multiplier = 10;

			if (FlxG.keys.pressed.E)
				FlxG.camera.zoom += elapsed * multiplier;
			if (FlxG.keys.pressed.Q)
				FlxG.camera.zoom -= elapsed * multiplier;

			if (FlxG.camera.zoom < 0.1)
				FlxG.camera.zoom = 0.1;

			if (FlxG.keys.pressed.I || FlxG.keys.pressed.J || FlxG.keys.pressed.K || FlxG.keys.pressed.L)
			{
				if (FlxG.keys.pressed.I)
					camFollow.velocity.y = -90 * multiplier;
				else if (FlxG.keys.pressed.K)
					camFollow.velocity.y = 90 * multiplier;
				else
					camFollow.velocity.y = 0;

				if (FlxG.keys.pressed.J)
					camFollow.velocity.x = -90 * multiplier;
				else if (FlxG.keys.pressed.L)
					camFollow.velocity.x = 90 * multiplier;
				else
					camFollow.velocity.x = 0;
			}
			else
				camFollow.velocity.set();

			if (FlxG.keys.justPressed.W)
				curAnim -= 1;
			if (FlxG.keys.justPressed.S)
				curAnim += 1;

			if (FlxG.keys.justPressed.ESCAPE)
			{
				FlxG.sound.play('${Directory.soundsFolder}/cancelMenu.ogg');

				if (fromGame)
				{
					fromGame = false;
					FlxG.switchState(new PlayState());
				}
				else
					FlxG.switchState(new MainMenuState());
			}

			if (FlxG.keys.justPressed.COMMA)
				saveOffsets();

			if (curAnim < 0)
				curAnim = animList.length - 1;
			if (curAnim >= animList.length)
				curAnim = 0;

			if (FlxG.keys.justPressed.S || FlxG.keys.justPressed.W || FlxG.keys.justPressed.SPACE)
			{
				char.playAnim(animList[curAnim]);
				updateTexts();
				genBoyOffsets(false);
			}

			var upP = FlxG.keys.anyJustPressed([UP]);
			var rightP = FlxG.keys.anyJustPressed([RIGHT]);
			var downP = FlxG.keys.anyJustPressed([DOWN]);
			var leftP = FlxG.keys.anyJustPressed([LEFT]);

			if (upP || rightP || downP || leftP)
			{
				var offsets = char.animOffsets.get(animList[curAnim]);
				if (offsets != null)
				{
					if (upP)
						offsets[1] += 1 * multiplier;
					if (downP)
						offsets[1] -= 1 * multiplier;
					if (leftP)
						offsets[0] += 1 * multiplier;
					if (rightP)
						offsets[0] -= 1 * multiplier;
					updateTexts();
					genBoyOffsets(false);
					char.playAnim(animList[curAnim]);
				}
			}
		}
		else
		{
			camFollow.velocity.set();
		}

		super.update(elapsed);
	}

	function saveOffsets():Void
	{
		var resultData = {
			character: char.curCharacter,
			offsets: []
		};

		for (anim => offsets in char.animOffsets)
		{
			resultData.offsets.push({
				anim: anim,
				x: offsets[0],
				y: offsets[1]
			});
		}

		var jsonString:String = haxe.Json.stringify(resultData, null, "\t");
		if (jsonString != null && jsonString.length > 0)
		{
			_file = new FileReference();
			_file.addEventListener(Event.COMPLETE, onSaveComplete);
			_file.addEventListener(Event.CANCEL, onSaveCancel);
			_file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
			_file.save(jsonString.trim(), char.curCharacter + ".json");
		}
	}

	function onSaveComplete(event:Event):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		trace("Character JSON offset file saved successfully!");
	}

	function onSaveCancel(event:Event):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		trace("Save cancelled by user.");
	}

	function onSaveError(event:IOErrorEvent):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		trace('ERROR saving character offset JSON: ${event.text}');
	}
}
