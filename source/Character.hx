// done
package;

import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.util.FlxColor;
import openfl.utils.Assets;

using StringTools;

class Character extends FlxSprite
{
	public var animOffsets:Map<String, Array<Dynamic>>;
	public var debugMode:Bool = false;

	public var isPlayer:Bool = false;
	public var curCharacter:String = '';

	public var healthColor:FlxColor = FlxColor.WHITE;

	public var curCamOffsetX:Float = 0;
	public var curCamOffsetY:Float = 0;

	public var holdTimer:Float = 0;

	public function new(x:Float, y:Float, ?character:String = "", ?isPlayer:Bool = false)
	{
		super(x, y);

		animOffsets = new Map<String, Array<Dynamic>>();
		curCharacter = character;
		this.isPlayer = isPlayer;
		antialiasing = PrismPrefs.antialiasing;

		switch (curCharacter)
		{
			case 'bf':
				healthColor = 0xFF31B0D1;
				// BF ANIMATION LOADING CODE
				frames = FlxAtlasFrames.fromSparrow('${Directory.imagesFolder}/characters/BOYFRIEND.png', '${Directory.imagesFolder}/characters/BOYFRIEND.xml');

				animation.addByPrefix('idle', 'BF idle dance', 24, false);
				animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
				animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
				animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
				animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
				animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
				animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
				animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);
				animation.addByPrefix('hey', 'BF HEY', 24, false);
				animation.addByPrefix('scared', 'BF idle shaking', 24);

				playAnim('idle');

				flipX = true;

			case 'bf-dead':
				frames = FlxAtlasFrames.fromSparrow('${Directory.imagesFolder}/characters/BOYFRIEND_DEAD.png',
					'${Directory.imagesFolder}/characters/BOYFRIEND_DEAD.xml');

				animation.addByPrefix('firstDeath', "BF dies", 24, false);
				animation.addByPrefix('deathLoop', "BF Dead Loop", 24, true);
				animation.addByPrefix('deathConfirm', "BF Dead confirm", 24, false);

				playAnim('firstDeath');

				flipX = true;

			case 'bf-car':
				healthColor = 0xFF31B0D1;
				frames = FlxAtlasFrames.fromSparrow('${Directory.imagesFolder}/characters/bfCar.png', '${Directory.imagesFolder}/characters/bfCar.xml');

				animation.addByPrefix('idle', 'BF idle dance', 24, false);
				animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
				animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
				animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
				animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
				animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
				animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
				animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);

				playAnim('idle');

				flipX = true;

			case 'bf-christmas':
				healthColor = 0xFF31B0D1;
				frames = FlxAtlasFrames.fromSparrow('${Directory.imagesFolder}/characters/bfChristmas.png',
					'${Directory.imagesFolder}/characters/bfChristmas.xml');

				animation.addByPrefix('idle', 'BF idle dance', 24, false);
				animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
				animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
				animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
				animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
				animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
				animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
				animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);
				animation.addByPrefix('hey', 'BF HEY', 24, false);

				playAnim('idle');

				flipX = true;

			case 'bf-pixel':
				healthColor = 0xFF7BD6F6;
				frames = FlxAtlasFrames.fromSparrow('${Directory.imagesFolder}/characters/bfPixel.png', '${Directory.imagesFolder}/characters/bfPixel.xml');

				animation.addByPrefix('idle', 'BF IDLE', 24, false);
				animation.addByPrefix('singUP', 'BF UP NOTE', 24, false);
				animation.addByPrefix('singLEFT', 'BF LEFT NOTE', 24, false);
				animation.addByPrefix('singRIGHT', 'BF RIGHT NOTE', 24, false);
				animation.addByPrefix('singDOWN', 'BF DOWN NOTE', 24, false);
				animation.addByPrefix('singUPmiss', 'BF UP MISS', 24, false);
				animation.addByPrefix('singLEFTmiss', 'BF LEFT MISS', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'BF RIGHT MISS', 24, false);
				animation.addByPrefix('singDOWNmiss', 'BF DOWN MISS', 24, false);

				playAnim('idle');

				setGraphicSize(Std.int(width * 6));
				updateHitbox();
				width -= 100;
				height -= 100;
				antialiasing = false;
				flipX = true;

			case 'bf-pixel-dead':
				frames = FlxAtlasFrames.fromSparrow('${Directory.imagesFolder}/characters/bfPixelsDEAD.png',
					'${Directory.imagesFolder}/characters/bfPixelsDEAD.xml');

				animation.addByPrefix('singUP', "BF Dies pixel", 24, false);
				animation.addByPrefix('firstDeath', "BF Dies pixel", 24, false);
				animation.addByPrefix('deathLoop', "Retry Loop", 24, true);
				animation.addByPrefix('deathConfirm', "RETRY CONFIRM", 24, false);
				animation.play('firstDeath');

				playAnim('firstDeath');

				// pixel bullshit
				setGraphicSize(Std.int(width * 6));
				updateHitbox();
				antialiasing = false;
				flipX = true;

			case 'dad':
				healthColor = 0xFFAF66CE;
				// DAD ANIMATION LOADING CODE
				frames = FlxAtlasFrames.fromSparrow('${Directory.imagesFolder}/characters/DADDY_DEAREST.png',
					'${Directory.imagesFolder}/characters/DADDY_DEAREST.xml');
				animation.addByPrefix('idle', 'Dad idle dance', 24);
				animation.addByPrefix('singUP', 'Dad Sing note UP', 24);
				animation.addByPrefix('singLEFT', 'dad sing note right', 24);
				animation.addByPrefix('singDOWN', 'Dad Sing Note DOWN', 24);
				animation.addByPrefix('singRIGHT', 'Dad Sing Note LEFT', 24);

				playAnim('idle');

			case 'spooky':
				healthColor = 0xFFD57E00;
				frames = FlxAtlasFrames.fromSparrow('${Directory.imagesFolder}/characters/spooky_kids_assets.png',
					'${Directory.imagesFolder}/characters/spooky_kids_assets.xml');

				animation.addByPrefix('singUP', 'spooky UP NOTE', 24, false);
				animation.addByPrefix('singDOWN', 'spooky DOWN note', 24, false);
				animation.addByPrefix('singLEFT', 'note sing left', 24, false);
				animation.addByPrefix('singRIGHT', 'spooky sing right', 24, false);
				animation.addByIndices('danceLeft', 'spooky dance idle', [0, 2, 6], "", 12, false);
				animation.addByIndices('danceRight', 'spooky dance idle', [8, 10, 12, 14], "", 12, false);

				playAnim('danceRight');

			case 'pico':
				healthColor = 0xFFB7D855;
				frames = FlxAtlasFrames.fromSparrow('${Directory.imagesFolder}/characters/Pico_FNF_assetss.png',
					'${Directory.imagesFolder}/characters/Pico_FNF_assetss.xml');

				animation.addByPrefix('idle', "Pico Idle Dance", 24);
				animation.addByPrefix('singUP', 'pico Up note0', 24, false);
				animation.addByPrefix('singDOWN', 'Pico Down Note0', 24, false);
				if (isPlayer)
				{
					animation.addByPrefix('singLEFT', 'Pico NOTE LEFT0', 24, false);
					animation.addByPrefix('singRIGHT', 'Pico Note Right0', 24, false);
					animation.addByPrefix('singRIGHTmiss', 'Pico Note Right Miss', 24, false);
					animation.addByPrefix('singLEFTmiss', 'Pico NOTE LEFT miss', 24, false);
				}
				else
				{
					// Need to be flipped! REDO THIS LATER!
					animation.addByPrefix('singLEFT', 'Pico Note Right0', 24, false);
					animation.addByPrefix('singRIGHT', 'Pico NOTE LEFT0', 24, false);
					animation.addByPrefix('singRIGHTmiss', 'Pico NOTE LEFT miss', 24, false);
					animation.addByPrefix('singLEFTmiss', 'Pico Note Right Miss', 24, false);
				}
				animation.addByPrefix('singUPmiss', 'pico Up note miss', 24);
				animation.addByPrefix('singDOWNmiss', 'Pico Down Note MISS', 24);

				playAnim('idle');

				flipX = true;

			case 'mom':
				healthColor = 0xFFD8558E;
				frames = FlxAtlasFrames.fromSparrow('${Directory.imagesFolder}/characters/Mom_Assets.png',
					'${Directory.imagesFolder}/characters/Mom_Assets.xml');

				animation.addByPrefix('idle', "Mom Idle", 24, false);
				animation.addByPrefix('singUP', "Mom Up Pose", 24, false);
				animation.addByPrefix('singDOWN', "MOM DOWN POSE", 24, false);
				animation.addByPrefix('singLEFT', 'Mom Left Pose', 24, false);
				// ANIMATION IS CALLED MOM LEFT POSE BUT ITS FOR THE RIGHT
				// CUZ DAVE IS DUMB!
				animation.addByPrefix('singRIGHT', 'Mom Pose Left', 24, false);

				playAnim('idle');

			case 'mom-car':
				healthColor = 0xFFD8558E;
				frames = FlxAtlasFrames.fromSparrow('${Directory.imagesFolder}/characters/momCar.png', '${Directory.imagesFolder}/characters/momCar.xml');

				animation.addByPrefix('idle', "Mom Idle", 24, false);
				animation.addByPrefix('singUP', "Mom Up Pose", 24, false);
				animation.addByPrefix('singDOWN', "MOM DOWN POSE", 24, false);
				animation.addByPrefix('singLEFT', 'Mom Left Pose', 24, false);
				// ANIMATION IS CALLED MOM LEFT POSE BUT ITS FOR THE RIGHT
				// CUZ DAVE IS DUMB!
				animation.addByPrefix('singRIGHT', 'Mom Pose Left', 24, false);

				playAnim('idle');

			case 'monster':
				healthColor = 0xFFF3FF6E;
				frames = FlxAtlasFrames.fromSparrow('${Directory.imagesFolder}/characters/Monster_Assets.png',
					'${Directory.imagesFolder}/characters/Monster_Assets.xml');

				animation.addByPrefix('idle', 'monster idle', 24, false);
				animation.addByPrefix('singUP', 'monster up note', 24, false);
				animation.addByPrefix('singDOWN', 'monster down', 24, false);
				animation.addByPrefix('singLEFT', 'Monster left note', 24, false);
				animation.addByPrefix('singRIGHT', 'Monster Right note', 24, false);

				playAnim('idle');

			case 'parents-christmas':
				healthColor = 0xFFAF66CE;
				frames = FlxAtlasFrames.fromSparrow('${Directory.imagesFolder}/characters/mom_dad_christmas_assets.png',
					'${Directory.imagesFolder}/characters/mom_dad_christmas_assets.xml');

				animation.addByPrefix('idle', 'Parent Christmas Idle', 24, false);
				animation.addByPrefix('singUP', 'Parent Up Note Dad', 24, false);
				animation.addByPrefix('singDOWN', 'Parent Down Note Dad', 24, false);
				animation.addByPrefix('singLEFT', 'Parent Left Note Dad', 24, false);
				animation.addByPrefix('singRIGHT', 'Parent Right Note Dad', 24, false);
				animation.addByPrefix('singUP-alt', 'Parent Up Note Mom', 24, false);
				animation.addByPrefix('singDOWN-alt', 'Parent Down Note Mom', 24, false);
				animation.addByPrefix('singLEFT-alt', 'Parent Left Note Mom', 24, false);
				animation.addByPrefix('singRIGHT-alt', 'Parent Right Note Mom', 24, false);

				playAnim('idle');

			case 'monster-christmas':
				healthColor = 0xFFF3FF6E;
				frames = FlxAtlasFrames.fromSparrow('${Directory.imagesFolder}/characters/monsterChristmas.png',
					'${Directory.imagesFolder}/characters/monsterChristmas.xml');

				animation.addByPrefix('idle', 'monster idle', 24, false);
				animation.addByPrefix('singUP', 'monster up note', 24, false);
				animation.addByPrefix('singDOWN', 'monster down', 24, false);
				animation.addByPrefix('singLEFT', 'Monster left note', 24, false);
				animation.addByPrefix('singRIGHT', 'Monster Right note', 24, false);

				playAnim('idle');

			case 'senpai':
				healthColor = 0xFFFFAA6F;
				frames = FlxAtlasFrames.fromSparrow('${Directory.imagesFolder}/characters/senpai.png', '${Directory.imagesFolder}/characters/senpai.xml');

				animation.addByPrefix('idle', 'Senpai Idle', 24, false);
				animation.addByPrefix('singUP', 'SENPAI UP NOTE', 24, false);
				animation.addByPrefix('singLEFT', 'SENPAI LEFT NOTE', 24, false);
				animation.addByPrefix('singRIGHT', 'SENPAI RIGHT NOTE', 24, false);
				animation.addByPrefix('singDOWN', 'SENPAI DOWN NOTE', 24, false);

				playAnim('idle');

				setGraphicSize(Std.int(width * 6));
				updateHitbox();
				antialiasing = false;

			case 'senpai-angry':
				healthColor = 0xFFFFAA6F;
				frames = FlxAtlasFrames.fromSparrow('${Directory.imagesFolder}/characters/senpai.png', '${Directory.imagesFolder}/characters/senpai.xml');

				animation.addByPrefix('idle', 'Angry Senpai Idle', 24, false);
				animation.addByPrefix('singUP', 'Angry Senpai UP NOTE', 24, false);
				animation.addByPrefix('singLEFT', 'Angry Senpai LEFT NOTE', 24, false);
				animation.addByPrefix('singRIGHT', 'Angry Senpai RIGHT NOTE', 24, false);
				animation.addByPrefix('singDOWN', 'Angry Senpai DOWN NOTE', 24, false);

				playAnim('idle');

				setGraphicSize(Std.int(width * 6));
				updateHitbox();
				antialiasing = false;

			case 'spirit':
				healthColor = 0xFFFF3C6E;
				frames = FlxAtlasFrames.fromSpriteSheetPacker('${Directory.imagesFolder}/characters/spirit.png',
					'${Directory.imagesFolder}/characters/spirit.txt');

				animation.addByPrefix('idle', "idle spirit_", 24, false);
				animation.addByPrefix('singUP', "up_", 24, false);
				animation.addByPrefix('singRIGHT', "right_", 24, false);
				animation.addByPrefix('singLEFT', "left_", 24, false);
				animation.addByPrefix('singDOWN', "spirit down_", 24, false);

				playAnim('idle');

				setGraphicSize(Std.int(width * 6));
				updateHitbox();
				antialiasing = false;

			case 'gf':
				healthColor = 0xFFA5004D;
				// GIRLFRIEND CODE
				frames = FlxAtlasFrames.fromSparrow('${Directory.imagesFolder}/characters/GF_assets.png', '${Directory.imagesFolder}/characters/GF_assets.xml');

				animation.addByPrefix('cheer', 'GF Cheer', 24, false);
				animation.addByPrefix('singLEFT', 'GF left note', 24, false);
				animation.addByPrefix('singRIGHT', 'GF Right Note', 24, false);
				animation.addByPrefix('singUP', 'GF Up Note', 24, false);
				animation.addByPrefix('singDOWN', 'GF Down Note', 24, false);
				animation.addByIndices('sad', 'gf sad', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "", 24, false);
				animation.addByIndices('danceLeft', 'GF Dancing Beat', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'GF Dancing Beat', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
				animation.addByIndices('hairBlow', "GF Dancing Beat Hair blowing", [0, 1, 2, 3], "", 24);
				animation.addByIndices('hairFall', "GF Dancing Beat Hair Landing", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11], "", 24, false);
				animation.addByPrefix('scared', 'GF FEAR', 24);

				playAnim('danceRight');

			case 'gf-car':
				frames = FlxAtlasFrames.fromSparrow('${Directory.imagesFolder}/characters/gfCar.png', '${Directory.imagesFolder}/characters/gfCar.xml');

				animation.addByIndices('singUP', 'GF Dancing Beat Hair blowing CAR', [0], "", 24, false);
				animation.addByIndices('danceLeft', 'GF Dancing Beat Hair blowing CAR', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'GF Dancing Beat Hair blowing CAR', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24,
					false);

				playAnim('danceRight');

			case 'gf-christmas':
				frames = FlxAtlasFrames.fromSparrow('${Directory.imagesFolder}/characters/gfChristmas.png',
					'${Directory.imagesFolder}/characters/gfChristmas.xml');

				animation.addByPrefix('cheer', 'GF Cheer', 24, false);
				animation.addByPrefix('singLEFT', 'GF left note', 24, false);
				animation.addByPrefix('singRIGHT', 'GF Right Note', 24, false);
				animation.addByPrefix('singUP', 'GF Up Note', 24, false);
				animation.addByPrefix('singDOWN', 'GF Down Note', 24, false);
				animation.addByIndices('sad', 'gf sad', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "", 24, false);
				animation.addByIndices('danceLeft', 'GF Dancing Beat', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'GF Dancing Beat', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
				animation.addByIndices('hairBlow', "GF Dancing Beat Hair blowing", [0, 1, 2, 3], "", 24);
				animation.addByIndices('hairFall', "GF Dancing Beat Hair Landing", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11], "", 24, false);
				animation.addByPrefix('scared', 'GF FEAR', 24);

				playAnim('danceRight');

			case 'gf-pixel':
				frames = FlxAtlasFrames.fromSparrow('${Directory.imagesFolder}/characters/gfPixel.png', '${Directory.imagesFolder}/characters/gfPixel.xml');

				animation.addByIndices('singUP', 'GF IDLE', [2], "", 24, false);
				animation.addByIndices('danceLeft', 'GF IDLE', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'GF IDLE', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);

				playAnim('danceRight');

				setGraphicSize(Std.int(width * PlayState.daPixelZoom));
				updateHitbox();
				antialiasing = false;
		}

		dance();

		var jsonPath:String = '${Directory.imagesFolder}/characters/offsets/${curCharacter}.json';

		if (openfl.utils.Assets.exists(jsonPath))
		{
			try
			{
				var rawJson:String = openfl.utils.Assets.getText(jsonPath);
				var parsedData:Dynamic = haxe.Json.parse(rawJson);
				if (parsedData != null && parsedData.offsets != null)
				{
					var offsetList:Array<Dynamic> = cast parsedData.offsets;
					for (animOffset in offsetList)
					{
						var animName:String = Std.string(animOffset.anim);
						var xVal:Float = Std.parseFloat(Std.string(animOffset.x));
						var yVal:Float = Std.parseFloat(Std.string(animOffset.y));

						animOffsets.set(animName, [xVal, yVal]);
					}
					trace('Successfully loaded JSON offsets for character: $curCharacter');
				}
			}
			catch (e:Dynamic)
			{
				trace('ERROR parsing JSON offset file for ${curCharacter}: ${Std.string(e)}');
			}
		}
		else
			trace('Warning: No JSON offset file found for ${curCharacter} at $jsonPath');

		if (isPlayer)
		{
			flipX = !flipX;

			// Doesn't flip for BF, since his are already in the right place???
			if (!curCharacter.startsWith('bf'))
			{
				// var animArray
				var oldRight = animation.getByName('singRIGHT').frames;
				animation.getByName('singRIGHT').frames = animation.getByName('singLEFT').frames;
				animation.getByName('singLEFT').frames = oldRight;

				// IF THEY HAVE MISS ANIMATIONS??
				if (animation.getByName('singRIGHTmiss') != null)
				{
					var oldMiss = animation.getByName('singRIGHTmiss').frames;
					animation.getByName('singRIGHTmiss').frames = animation.getByName('singLEFTmiss').frames;
					animation.getByName('singLEFTmiss').frames = oldMiss;
				}
			}
		}
	}

	override function update(elapsed:Float)
	{
		if (!curCharacter.startsWith('bf'))
		{
			if (animation.curAnim.name.startsWith('sing'))
				holdTimer += elapsed;

			var dadVar:Float = 4;
			if (curCharacter == 'dad')
				dadVar = 6.1;
			if (holdTimer >= Conductor.stepCrochet * dadVar * 0.001)
			{
				dance();
				holdTimer = 0;
			}
		}

		switch (curCharacter)
		{
			case 'gf':
				if (animation.curAnim.name == 'hairFall' && animation.curAnim.finished)
					playAnim('danceRight');
		}

		super.update(elapsed);
	}

	private var danced:Bool = false;

	/**
	 * FOR GF DANCING SHIT
	 */
	public function dance()
	{
		if (!debugMode)
		{
			switch (curCharacter)
			{
				case 'gf' | 'gf-car' | 'gf-christmas' | 'gf-pixel':
					if (!animation.curAnim.name.startsWith('hair'))
					{
						danced = !danced;

						if (danced)
							playAnim('danceRight');
						else
							playAnim('danceLeft');
					}

				case 'spooky':
					danced = !danced;

					if (danced)
						playAnim('danceRight');
					else
						playAnim('danceLeft');
				default:
					playAnim('idle');
			}
		}
	}

	public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{
		animation.play(AnimName, Force, Reversed, Frame);

		var swapCamLeftRight:Bool = isPlayer && !curCharacter.startsWith('bf');
		if (PrismPrefs.camNoteHit)
		{
			switch (AnimName)
			{
				case 'singRIGHT' | 'singRIGHT-alt':
					curCamOffsetX = swapCamLeftRight ? -25 : 25;
					curCamOffsetY = 0;
				case 'singLEFT' | 'singLEFT-alt':
					curCamOffsetX = swapCamLeftRight ? 25 : -25;
					curCamOffsetY = 0;
				case 'singUP' | 'singUP-alt':
					curCamOffsetY = -25;
					curCamOffsetX = 0;
				case 'singDOWN' | 'singDOWN-alt':
					curCamOffsetY = 25;
					curCamOffsetX = 0;
				default:
					curCamOffsetX = 0;
					curCamOffsetY = 0;
			}
		}
		else
		{
			curCamOffsetX = 0;
			curCamOffsetY = 0;
		}

		if (animation.curAnim != null)
		{
			if (animOffsets.exists(animation.curAnim.name))
			{
				var daOffset = animOffsets.get(animation.curAnim.name);
				offset.set(daOffset[0], daOffset[1]);
			}
			else
				offset.set(0, 0);
		}
		else
			offset.set(0, 0);

		if (curCharacter == 'gf')
		{
			if (AnimName == 'singLEFT')
				danced = true;
			else if (AnimName == 'singRIGHT')
				danced = false;

			if (AnimName == 'singUP' || AnimName == 'singDOWN')
				danced = !danced;
		}
	}

	public function addOffset(name:String, x:Float = 0, y:Float = 0)
	{
		animOffsets[name] = [x, y];
	}
}
