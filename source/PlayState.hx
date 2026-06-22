// done
package;

import Section.SwagSection;
import Song.SwagSong;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;

using StringTools;

class PlayState extends MusicBeatState
{
	public static var instance:PlayState;

	public static var curStage:String = '';
	public static var SONG:SwagSong;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;

	private var vocals:FlxSound;

	private var dad:Character;
	private var gf:Character;
	private var boyfriend:Boyfriend;

	public var notes:FlxTypedGroup<Note>;

	private var unspawnNotes:Array<Note> = [];

	public var strumLine:FlxSprite;

	private var curSection:Int = 0;

	private var camFollow:FlxObject;
	private var camFollowIsPlayer:Bool = false;

	private static var prevCamFollow:FlxObject;

	public var strumLineNotes:FlxTypedGroup<FlxSprite>;
	public var playerStrums:FlxTypedGroup<FlxSprite>;
	public var opponentStrums:FlxTypedGroup<FlxSprite>;

	private var camZooming:Bool = false;

	private var curSong:String = "";

	private var gfSpeed:Int = 1;

	private var health:Float = 1;

	private var combo:Int = 0;

	private var generatedMusic:Bool = false;
	private var startingSong:Bool = false;

	public var hud:HUD;

	var stage:Stage;

	private var camHUD:FlxCamera;
	private var camGame:FlxCamera;

	var dialogue:Array<String> = ['blah blah blah', 'coolswag'];
	var talking:Bool = true;

	var songScore:Int = 0;
	var songMisses:Int = 0;

	var grpNoteSplashes:FlxTypedGroup<NoteSplash>;

	public static var campaignScore:Int = 0;

	public static var defaultCamZoom:Float = 1.05;

	// how big to stretch the pixel art assets
	public static var daPixelZoom:Float = 6;

	// applies the intense camera zoom effect
	public static var intenseBumping:Bool = false;

	var inCutscene:Bool = false;

	override public function create()
	{
		instance = this;

		curStage = 'default'; // Reset static variable to prevent leakage

		// var gameCam:FlxCamera = FlxG.camera;
		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD, false);
		FlxG.cameras.setDefaultDrawTarget(camGame, true);

		persistentUpdate = persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial');

		if (SONG != null && SONG.stage != null && SONG.stage != "")
			curStage = SONG.stage;

		intenseBumping = SONG.intenseBumping;

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		stage = new Stage(curStage);
		add(stage);

		switch (SONG.song.toLowerCase())
		{
			case 'senpai':
				dialogue = CoolUtil.coolTextFile('${Directory.dataFolder}/senpai/senpaiDialogue.txt');
			case 'roses':
				dialogue = CoolUtil.coolTextFile('${Directory.dataFolder}/roses/rosesDialogue.txt');
			case 'thorns':
				dialogue = CoolUtil.coolTextFile('${Directory.dataFolder}/thorns/thornsDialogue.txt');
		}

		var gfVersion:String = stage.gfVersion(curStage);
		if (SONG != null && SONG.gf != null && SONG.gf != "")
			gfVersion = SONG.gf;
		gf = new Character(400, 130, gfVersion);
		gf.scrollFactor.set(0.95, 0.95);
		add(gf);

		if (curStage == 'limo')
			add(stage.limo);

		dad = new Character(100, 100, SONG.player2);
		var camPos:FlxPoint = new FlxPoint(dad.getGraphicMidpoint().x, dad.getGraphicMidpoint().y);
		stage.dadPos(curStage, dad, gf, camPos, SONG.player2);
		add(dad);

		boyfriend = new Boyfriend(770, 450, SONG.player1);
		add(boyfriend);

		stage.playerPos(curStage, dad, boyfriend, gf);

		hud = new HUD();
		add(hud);

		hud.health = health;
		hud.healthBar.createFilledBar(dad.healthColor, boyfriend.healthColor);

		var doof:DialogueBox = new DialogueBox(false, dialogue);
		// doof.x += 70;
		// doof.y = FlxG.height * 0.5;
		doof.scrollFactor.set();
		doof.finishThing = startCountdown;

		Conductor.songPosition = -5000;

		strumLine = new FlxSprite(0, 50).makeGraphic(FlxG.width, 10);
		strumLine.scrollFactor.set();
		if (PrismPrefs.downscroll)
			strumLine.y = FlxG.height - 150;

		strumLineNotes = new FlxTypedGroup<FlxSprite>();
		add(strumLineNotes);

		// fake notesplash cache type deal so that it loads in the graphic?
		grpNoteSplashes = new FlxTypedGroup<NoteSplash>();
		var noteSplash:NoteSplash = new NoteSplash(100, 100, 0);
		grpNoteSplashes.add(noteSplash);
		noteSplash.alpha = 0.1;
		add(grpNoteSplashes);

		playerStrums = new FlxTypedGroup<FlxSprite>();
		opponentStrums = new FlxTypedGroup<FlxSprite>();

		// startCountdown();

		generateSong(SONG.song);

		// add(strumLine);

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollow.setPosition(camPos.x, camPos.y);
		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}
		add(camFollow);

		FlxG.camera.follow(camFollow, LOCKON, 0.04);
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow.getPosition());
		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = true;

		for (e in [
			grpNoteSplashes,
			strumLineNotes,
			notes,
			hud.healthBar,
			hud.healthBarBG,
			hud.iconP1,
			hud.iconP2,
			hud.scoreTxt,
			hud.debugTxt,
			hud.cornerMark,
			doof
		])
			e.cameras = [camHUD];

		// cameras = [FlxG.cameras.list[1]];
		startingSong = true;

		if (isStoryMode)
		{
			switch (curSong.toLowerCase())
			{
				case "winter-horrorland":
					var blackScreen:FlxSprite = new FlxSprite(0, 0).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
					blackScreen.scrollFactor.set();
					add(blackScreen);

					camHUD.visible = false;

					new FlxTimer().start(0.1, function(tmr:FlxTimer)
					{
						remove(blackScreen);
						FlxG.sound.play('${Directory.soundsFolder}/stages/christmas/Lights_Turn_On.ogg');
						FlxG.camera.focusOn(camFollow.getPosition());
						FlxG.camera.zoom = 1.5;
						camFollow.x += 200;
						camFollow.y = -2050;

						new FlxTimer().start(0.8, function(tmr:FlxTimer)
						{
							camHUD.visible = true;
							remove(blackScreen);
							FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 2.5, {
								ease: FlxEase.quadInOut,
								onComplete: function(twn:FlxTween)
								{
									startCountdown();
								}
							});
						});
					});
				case 'senpai' | 'roses' | 'thorns':
					if (curSong == 'roses')
						FlxG.sound.play('${Directory.soundsFolder}/stages/weeb/ANGRY.ogg');
					schoolIntro(doof);
				default:
					startCountdown();
			}
		}
		else
			startCountdown();

		super.create();

		PrismJsonScript.loadModchart(SONG.song);
	}

	function schoolIntro(?dialogueBox:DialogueBox):Void
	{
		var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		black.scrollFactor.set();
		add(black);

		var red:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFFff1b31);
		red.scrollFactor.set();

		var senpaiEvil:FlxSprite = new FlxSprite();
		senpaiEvil.frames = FlxAtlasFrames.fromSparrow('${Directory.imagesFolder}/stages/weeb/senpaiCrazy.png',
			'${Directory.imagesFolder}/stages/weeb/senpaiCrazy.xml');
		senpaiEvil.animation.addByPrefix('idle', 'Senpai Pre Explosion', 24, false);
		senpaiEvil.scrollFactor.set();
		senpaiEvil.setGraphicSize(Std.int(senpaiEvil.width * 6));
		senpaiEvil.screenCenter();
		senpaiEvil.updateHitbox();

		if (SONG.song.toLowerCase() == 'roses' || SONG.song.toLowerCase() == 'thorns')
		{
			remove(black);

			if (SONG.song.toLowerCase() == 'thorns')
				add(red);
		}

		new FlxTimer().start(0.3, function(tmr:FlxTimer)
		{
			black.alpha -= 0.15;

			if (black.alpha > 0)
				tmr.reset(0.3);
			else
			{
				if (dialogueBox != null)
				{
					inCutscene = true;

					if (SONG.song.toLowerCase() == 'thorns')
					{
						add(senpaiEvil);
						senpaiEvil.alpha = 0;
						new FlxTimer().start(0.3, function(swagTimer:FlxTimer)
						{
							senpaiEvil.alpha += 0.15;
							if (senpaiEvil.alpha < 1)
								swagTimer.reset();
							else
							{
								senpaiEvil.animation.play('idle');
								FlxG.sound.play('${Directory.soundsFolder}/stages/weeb/Senpai_Dies.ogg', 1, false, null, true, function()
								{
									remove(senpaiEvil);
									remove(red);
									FlxG.camera.fade(FlxColor.WHITE, 0.01, true, function()
									{
										add(dialogueBox);
									}, true);
								});
								new FlxTimer().start(3.2, function(deadTime:FlxTimer)
								{
									FlxG.camera.fade(FlxColor.WHITE, 1.6, false);
								});
							}
						});
					}
					else
						add(dialogueBox);
				}
				else
					startCountdown();

				remove(black);
			}
		});
	}

	var startTimer:FlxTimer;

	function startCountdown():Void
	{
		inCutscene = false;

		generateStaticArrows(0);
		generateStaticArrows(1);

		talking = false;
		startedCountdown = true;
		Conductor.songPosition = 0;
		Conductor.songPosition -= Conductor.crochet * 5;

		var swagCounter:Int = 0;
		startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{
			if (swagCounter % gfSpeed == 0)
				gf.dance();
			if (swagCounter % 2 == 0)
			{
				if (!boyfriend.animation.curAnim.name.startsWith("sing"))
					boyfriend.playAnim('idle');
				if (!dad.animation.curAnim.name.startsWith("sing"))
					dad.dance();
			}
			else if (dad.curCharacter == 'spooky' && !dad.animation.curAnim.name.startsWith("sing"))
				dad.dance();

			var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
			introAssets.set('default', ['ready.png', "set.png", "go.png"]);
			introAssets.set('school', ['pixelUI/ready-pixel.png', 'pixelUI/set-pixel.png', 'pixelUI/date-pixel.png']);
			introAssets.set('schoolEvil', ['pixelUI/ready-pixel.png', 'pixelUI/set-pixel.png', 'pixelUI/date-pixel.png']);

			var introAlts:Array<String> = introAssets.get('default');
			var altSuffix:String = "";

			for (value in introAssets.keys())
			{
				if (value == curStage)
				{
					introAlts = introAssets.get(value);
					if (curStage.startsWith('school'))
						altSuffix = '-pixel';
				}
			}

			switch (swagCounter)
			{
				case 0:
					FlxG.sound.play('${Directory.soundsFolder}/intro3$altSuffix.ogg', 0.6);
				case 1:
					var ready:FlxSprite = new FlxSprite().loadGraphic('${Directory.imagesFolder}/ui/${introAlts[0]}');
					ready.scrollFactor.set();
					ready.screenCenter();
					ready.antialiasing = PrismPrefs.antialiasing;
					add(ready);

					if (curStage.startsWith('school'))
					{
						ready.setGraphicSize(Std.int(ready.width * daPixelZoom));
						ready.updateHitbox();
						ready.screenCenter();
						ready.antialiasing = false;
					}

					FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							ready.destroy();
						}
					});

					FlxG.sound.play('${Directory.soundsFolder}/intro2$altSuffix.ogg', 0.6);
				case 2:
					var set:FlxSprite = new FlxSprite().loadGraphic('${Directory.imagesFolder}/ui/${introAlts[1]}');
					set.scrollFactor.set();
					set.screenCenter();
					set.antialiasing = PrismPrefs.antialiasing;
					add(set);

					if (curStage.startsWith('school'))
					{
						set.setGraphicSize(Std.int(set.width * daPixelZoom));
						set.updateHitbox();
						set.screenCenter();
						set.antialiasing = false;
					}

					FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							set.destroy();
						}
					});

					FlxG.sound.play('${Directory.soundsFolder}/intro1$altSuffix.ogg', 0.6);
				case 3:
					var go:FlxSprite = new FlxSprite().loadGraphic('${Directory.imagesFolder}/ui/${introAlts[2]}');
					go.scrollFactor.set();
					go.screenCenter();
					go.antialiasing = PrismPrefs.antialiasing;
					add(go);

					if (curStage.startsWith('school'))
					{
						go.setGraphicSize(Std.int(go.width * daPixelZoom));
						go.updateHitbox();
						go.screenCenter();
						go.antialiasing = false;
					}

					FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							go.destroy();
						}
					});

					FlxG.sound.play('${Directory.soundsFolder}/introGo$altSuffix.ogg', 0.6);
				case 4:
			}

			swagCounter += 1;
			// generateSong('fresh');
		}, 5);
	}

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;

	function startSong():Void
	{
		startingSong = false;
		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		if (!paused)
			FlxG.sound.playMusic('${Directory.musicFolder}/songs/${SONG.song}_Inst.ogg', 1, false);
		FlxG.sound.music.onComplete = endSong;
		vocals.play();
	}

	var debugNum:Int = 0;

	private function generateSong(dataPath:String):Void
	{
		// FlxG.log.add(ChartParser.parse());

		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		curSong = songData.song;

		if (SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded('${Directory.musicFolder}/songs/${curSong}_Voices.ogg');
		else
			vocals = new FlxSound();
		FlxG.sound.list.add(vocals);

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteData:Array<SwagSection>;
		noteData = songData.notes;

		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped
		for (section in noteData)
		{
			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0];
				var daNoteData:Int = Std.int(songNotes[1] % 4);

				var gottaHitNote:Bool = section.mustHitSection;
				if (songNotes[1] > 3)
					gottaHitNote = !section.mustHitSection;

				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;

				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote);
				swagNote.sustainLength = songNotes[2];
				swagNote.scrollFactor.set(0, 0);

				var susLength:Float = swagNote.sustainLength;
				susLength = susLength / Conductor.stepCrochet;
				unspawnNotes.push(swagNote);

				for (susNote in 0...Math.floor(susLength))
				{
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

					var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, oldNote, true);
					sustainNote.scrollFactor.set();
					sustainNote.mustPress = gottaHitNote;
					sustainNote.flipY = PrismPrefs.downscroll;
					unspawnNotes.push(sustainNote);

					if (sustainNote.mustPress)
						sustainNote.x += FlxG.width / 2; // general offset
				}

				swagNote.mustPress = gottaHitNote;

				if (swagNote.mustPress)
					swagNote.x += FlxG.width / 2; // general offset
			}
			daBeats += 1;
		}

		// trace(unspawnNotes.length);
		// playerCounter += 1;

		unspawnNotes.sort(sortByShit);

		generatedMusic = true;
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	private function generateStaticArrows(player:Int):Void
	{
		for (i in 0...4)
		{
			// FlxG.log.add(i);
			var babyArrow:FlxSprite = new FlxSprite(0, strumLine.y);

			switch (curStage)
			{
				case 'school' | 'schoolEvil':
					babyArrow.loadGraphic('${Directory.imagesFolder}/ui/pixelUI/arrows-pixels.png', true, 17, 17);
					babyArrow.animation.add('purple', [4]);
					babyArrow.animation.add('blue', [5]);
					babyArrow.animation.add('green', [6]);
					babyArrow.animation.add('red', [7]);

					switch (Math.abs(i))
					{
						case 0:
							babyArrow.x += Note.swagWidth * 0;
							babyArrow.animation.add('static', [0]);
							babyArrow.animation.add('pressed', [4, 8], 12, false);
							babyArrow.animation.add('confirm', [12, 16], 24, false);
						case 1:
							babyArrow.x += Note.swagWidth * 1;
							babyArrow.animation.add('static', [1]);
							babyArrow.animation.add('pressed', [5, 9], 12, false);
							babyArrow.animation.add('confirm', [13, 17], 24, false);
						case 2:
							babyArrow.x += Note.swagWidth * 2;
							babyArrow.animation.add('static', [2]);
							babyArrow.animation.add('pressed', [6, 10], 12, false);
							babyArrow.animation.add('confirm', [14, 18], 12, false);
						case 3:
							babyArrow.x += Note.swagWidth * 3;
							babyArrow.animation.add('static', [3]);
							babyArrow.animation.add('pressed', [7, 11], 12, false);
							babyArrow.animation.add('confirm', [15, 19], 24, false);
					}

					babyArrow.setGraphicSize(Std.int(babyArrow.width * daPixelZoom));
					babyArrow.updateHitbox();
					babyArrow.antialiasing = false;

				default:
					babyArrow.frames = FlxAtlasFrames.fromSparrow('${Directory.imagesFolder}/ui/NOTE_assets.png',
						'${Directory.imagesFolder}/ui/NOTE_assets.xml');
					babyArrow.animation.addByPrefix('purple', 'arrowLEFT');
					babyArrow.animation.addByPrefix('blue', 'arrowDOWN');
					babyArrow.animation.addByPrefix('green', 'arrowUP');
					babyArrow.animation.addByPrefix('red', 'arrowRIGHT');

					switch (Math.abs(i))
					{
						case 0:
							babyArrow.x += Note.swagWidth * 0;
							babyArrow.animation.addByPrefix('static', 'arrowLEFT');
							babyArrow.animation.addByPrefix('pressed', 'left press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'left confirm', 24, false);
						case 1:
							babyArrow.x += Note.swagWidth * 1;
							babyArrow.animation.addByPrefix('static', 'arrowDOWN');
							babyArrow.animation.addByPrefix('pressed', 'down press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'down confirm', 24, false);
						case 2:
							babyArrow.x += Note.swagWidth * 2;
							babyArrow.animation.addByPrefix('static', 'arrowUP');
							babyArrow.animation.addByPrefix('pressed', 'up press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'up confirm', 24, false);
						case 3:
							babyArrow.x += Note.swagWidth * 3;
							babyArrow.animation.addByPrefix('static', 'arrowRIGHT');
							babyArrow.animation.addByPrefix('pressed', 'right press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'right confirm', 24, false);
					}

					babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));
					babyArrow.antialiasing = PrismPrefs.antialiasing;
			}

			babyArrow.updateHitbox();
			babyArrow.scrollFactor.set();

			if (!isStoryMode)
			{
				babyArrow.y -= 10;
				babyArrow.alpha = 0;
				FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			}

			if (player == 1)
				playerStrums.add(babyArrow);
			else
				opponentStrums.add(babyArrow);

			babyArrow.animation.play('static');
			babyArrow.centerOffsets();
			babyArrow.x += 78 + 78 / 4;
			babyArrow.x += ((FlxG.width / 2) * player);
			babyArrow.ID = i;
			strumLineNotes.add(babyArrow);
		}
	}

	function tweenCamIn():Void
	{
		FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				vocals.pause();
			}

			if (!startTimer.finished)
				startTimer.active = false;
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		if (paused)
		{
			if (FlxG.sound.music != null && !startingSong)
				resyncVocals();

			if (!startTimer.finished)
				startTimer.active = true;

			paused = false;
		}

		super.closeSubState();
	}

	function resyncVocals():Void
	{
		vocals.pause();
		FlxG.sound.music.play();
		Conductor.songPosition = FlxG.sound.music.time;
		vocals.time = Conductor.songPosition;
		vocals.play();
	}

	private var paused:Bool = false;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (stage != null)
			stage.stageUpdateConstant(elapsed, boyfriend, gf, dad);

		// Reset opponent strums confirm animation
		opponentStrums.forEach(function(spr:FlxSprite)
		{
			if (spr.animation.curAnim != null && spr.animation.curAnim.name == 'confirm' && spr.animation.curAnim.finished)
			{
				spr.animation.play('static');
				spr.centerOffsets();
			}
		});

		#if debug
		hud.debugTxt.text = 'Song: ${SONG.song.toLowerCase()}'
			+ '\nStage: $curStage'
			+ '\nDad: ${Math.floor(dad.x)}, ${Math.floor(dad.y)}'
			+ '\nBF: ${Math.floor(boyfriend.x)}, ${Math.floor(boyfriend.y)}'
			+ '\nGF: ${Math.floor(gf.x)}, ${Math.floor(gf.y)}';
		#end

		FlxG.camera.followLerp = elapsed * 2;

		hud.scoreTxt.text = '<Score: ${FlxStringUtil.formatMoney(songScore, false)}> <Misses: ${FlxStringUtil.formatMoney(songMisses, false)}>';
		hud.scoreTxt.screenCenter(X);

		var canUseDebugOrPause:Bool = startedCountdown && !startingSong && canPause;

		if (FlxG.keys.justPressed.ENTER && canUseDebugOrPause)
		{
			persistentUpdate = false;
			persistentDraw = true;
			paused = true;

			openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
		}

		
		if (canUseDebugOrPause && FlxG.keys.justPressed.SEVEN)
			FlxG.switchState(new ChartingState());
		

		// FlxG.watch.addQuick('VOL', vocals.amplitudeLeft);
		// FlxG.watch.addQuick('VOLRight', vocals.amplitudeRight);

		updateIconsScale(elapsed);
		updateIconsPosition();

		if (health > 2)
			health = 2;

		// 0: Normal, 1: Losing
		// dumb proofed this by adding null stuff i think lol
		if (hud.iconP1.animation.curAnim != null)
			hud.iconP1.animation.curAnim.curFrame = (hud.healthBar.percent < 20) ? 1 : 0;
		if (hud.iconP2.animation.curAnim != null)
			hud.iconP2.animation.curAnim.curFrame = (hud.healthBar.percent > 80) ? 1 : 0;

		#if debug
		if (canUseDebugOrPause)
		{
			if (FlxG.keys.justPressed.ONE)
			{
				AnimationDebug.fromGame = true;
				FlxG.switchState(new AnimationDebug(SONG.player2));
			}
			if (FlxG.keys.justPressed.TWO)
			{
				AnimationDebug.fromGame = true;
				FlxG.switchState(new AnimationDebug(SONG.player1));
			}
			if (FlxG.keys.justPressed.THREE)
			{
				AnimationDebug.fromGame = true;
				FlxG.switchState(new AnimationDebug(SONG.gf));
			}
		}
		#end

		if (startingSong)
		{
			if (startedCountdown)
			{
				Conductor.songPosition += FlxG.elapsed * 1000;
				if (Conductor.songPosition >= 0)
					startSong();
			}
		}
		else
		{
			// Conductor.songPosition = FlxG.sound.music.time;
			Conductor.songPosition += FlxG.elapsed * 1000;

			if (!paused)
			{
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				// Interpolation type beat
				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
					// Conductor.songPosition += FlxG.elapsed * 1000;
					// trace('MISSED FRAME');
				}
			}

			// Conductor.lastSongPos = FlxG.sound.music.time;
		}

		if (generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null)
			updateCameraFollow(PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection);

		if (camZooming)
		{
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
		}

		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);

		// RESET = Quick Game Over Screen
		if (controls.RESET)
		{
			health = 0;
			trace("RESET = True");
		}

		if (health <= 0)
		{
			boyfriend.stunned = true;
			persistentUpdate = false;
			persistentDraw = false;
			paused = true;

			vocals.stop();
			FlxG.sound.music.stop();

			// 1 / 1000 chance for Gitaroo Man easter egg
			if (FlxG.random.bool(0.1))
			{
				// gitaroo man easter egg
				FlxG.switchState(new GitarooPause());
			}
			else if (PrismPrefs.oldGameOver)
				FlxG.switchState(new GameOverState());
			else
				openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
			//
		}

		if (unspawnNotes[0] != null)
		{
			if (unspawnNotes[0].strumTime - Conductor.songPosition < 1500)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.add(dunceNote);

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}

		if (generatedMusic)
		{
			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.y > FlxG.height)
				{
					daNote.active = false;
					daNote.visible = false;
				}
				else
				{
					daNote.visible = true;
					daNote.active = true;
				}

				var speed:Float = 0.45 * FlxMath.roundDecimal(SONG.speed, 2);
				if (PrismPrefs.downscroll)
					daNote.y = (strumLine.y + (Conductor.songPosition - daNote.strumTime) * speed);
				else
					daNote.y = (strumLine.y - (Conductor.songPosition - daNote.strumTime) * speed);

				// i am so fucking sorry for this if condition
				if (daNote.isSustainNote && (!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
				{
					if (PrismPrefs.downscroll)
					{
						if (daNote.y - daNote.offset.y + daNote.height >= strumLine.y + Note.swagWidth / 2)
						{
							// reuse static rect to avoid allocations each frame
							var r = new FlxRect(0, 0, daNote.width * 2, daNote.height * 2);
							r.height = (strumLine.y + Note.swagWidth / 2 - daNote.y) / daNote.scale.y;
							daNote.clipRect = r;
						}
					}
					else if (daNote.y + daNote.offset.y <= strumLine.y + Note.swagWidth / 2)
					{
						var r = new FlxRect(0, strumLine.y + Note.swagWidth / 2 - daNote.y, daNote.width * 2, daNote.height * 2);
						r.y /= daNote.scale.y;
						r.height -= r.y;
						daNote.clipRect = r;
					}
				}

				if (!daNote.mustPress && daNote.wasGoodHit)
				{
					if (SONG.song != 'Tutorial')
						camZooming = true;

					var altAnim:String = "";
					if (SONG.notes[Math.floor(curStep / 16)] != null)
					{
						if (SONG.notes[Math.floor(curStep / 16)].dadAltAnim)
							altAnim = '-alt';
					}

					switch (Math.abs(daNote.noteData))
					{
						case 0:
							dad.playAnim('singLEFT$altAnim', true);
						case 1:
							dad.playAnim('singDOWN$altAnim', true);
						case 2:
							dad.playAnim('singUP$altAnim', true);
						case 3:
							dad.playAnim('singRIGHT$altAnim', true);
					}
					dad.holdTimer = 0;

					opponentStrums.forEach(function(spr:FlxSprite)
					{
						if (Math.abs(daNote.noteData) == spr.ID)
						{ // When opponent strum plays confirm
							spr.animation.play('confirm', true);
							spr.centerOffsets();
							if (!curStage.startsWith('school'))
							{
								spr.offset.x -= 13;
								spr.offset.y -= 13;
							}
						}
					});

					if (SONG.needsVoices)
						vocals.volume = 1;

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}

				// WIP interpolation shit? Need to fix the pause issue
				// daNote.y = (strumLine.y - (songTime - daNote.strumTime) * (0.45 * PlayState.SONG.speed));

				if ((!PrismPrefs.downscroll && daNote.y < -daNote.height) || (PrismPrefs.downscroll && daNote.y > FlxG.height))
				{
					if (daNote.isSustainNote && daNote.wasGoodHit)
					{
						daNote.kill();
						notes.remove(daNote, true);
						daNote.destroy();
					}
					else
					{
						if (daNote.tooLate || !daNote.wasGoodHit)
						{
							health -= 0.0475;
							vocals.volume = 0;
							if (PrismPrefs.ghostTapping)
								noteMiss(daNote.noteData);
						}

						daNote.active = false;
						daNote.visible = false;
						daNote.kill();
						notes.remove(daNote, true);
						daNote.destroy();
					}
				}
			});
		}

		if (!inCutscene)
			keyShit();
	}

	// health icon updaters
	public dynamic function updateIconsScale(elapsed:Float)
	{
		hud.iconP1.setGraphicSize(Std.int(FlxMath.lerp(150, hud.iconP1.width, 0.85)));
		hud.iconP1.updateHitbox();

		hud.iconP2.setGraphicSize(Std.int(FlxMath.lerp(150, hud.iconP2.width, 0.85)));
		hud.iconP2.updateHitbox();
	}

	public dynamic function updateIconsPosition()
	{
		if (hud != null)
		{
			hud.health = health;

			var iconOffset:Float = 26;
			hud.iconP1.x = hud.healthBar.x + (hud.healthBar.width * (FlxMath.remapToRange(health, 0, 2, 100, 0) * 0.01)) - iconOffset;
			hud.iconP2.x = hud.healthBar.x + (hud.healthBar.width * (FlxMath.remapToRange(health, 0, 2, 100, 0) * 0.01)) - (hud.iconP2.width - iconOffset);
		}
	}

	function updateCameraFollow(mustHitSection:Bool):Void
	{
		var focusX:Float;
		var focusY:Float;

		if (mustHitSection)
		{
			focusX = boyfriend.getMidpoint().x - 100;
			focusY = boyfriend.getMidpoint().y - 100;

			switch (curStage)
			{
				case 'limo':
					focusX = boyfriend.getMidpoint().x - 300;
				case 'mall':
					focusY = boyfriend.getMidpoint().y - 200;
				case 'school' | 'schoolEvil':
					focusX = boyfriend.getMidpoint().x - 200;
					focusY = boyfriend.getMidpoint().y - 200;
			}

			if (SONG.song.toLowerCase() == 'tutorial' && !camFollowIsPlayer)
				FlxTween.tween(FlxG.camera, {zoom: 1}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});

			focusX += boyfriend.curCamOffsetX;
			focusY += boyfriend.curCamOffsetY;
		}
		else
		{
			focusX = dad.getMidpoint().x + 150;
			focusY = dad.getMidpoint().y - 100;

			switch (dad.curCharacter)
			{
				case 'mom':
					focusY = dad.getMidpoint().y;
				case 'senpai' | 'senpai-angry':
					focusY = dad.getMidpoint().y - 430;
					focusX = dad.getMidpoint().x - 100;
			}

			if (SONG.song.toLowerCase() == 'tutorial' && SONG.song.toLowerCase() == 'test' && camFollowIsPlayer)
				tweenCamIn();

			focusX += dad.curCamOffsetX;
			focusY += dad.curCamOffsetY;
		}

		camFollow.setPosition(focusX, focusY);
		camFollowIsPlayer = mustHitSection;
	}

	function endSong():Void
	{
		canPause = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;

		if (SONG.validScore)
		{
			#if !switch
			Highscore.saveScore(SONG.song, songScore, storyDifficulty);
			#end
		}

		if (isStoryMode)
		{
			campaignScore += songScore;

			storyPlaylist.remove(storyPlaylist[0]);

			if (storyPlaylist.length <= 0)
			{
				FlxG.sound.playMusic('${Directory.musicFolder}/freakyMenu.ogg');

				transIn = FlxTransitionableState.defaultTransIn;
				transOut = FlxTransitionableState.defaultTransOut;

				FlxG.switchState(new StoryMenuState());
				if (SONG.validScore)
					Highscore.saveWeekScore(storyWeek, campaignScore, storyDifficulty);

				FlxG.save.flush();
			}
			else
			{
				var difficulty:String = "";

				if (storyDifficulty == 0)
					difficulty = '-easy';

				if (storyDifficulty == 2)
					difficulty = '-hard';

				trace('LOADING NEXT SONG');
				trace(PlayState.storyPlaylist[0].toLowerCase() + difficulty);

				if (SONG.song.toLowerCase() == 'eggnog')
				{
					var blackShit:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
						-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
					blackShit.scrollFactor.set();
					add(blackShit);

					camHUD.visible = false;
					FlxG.sound.play('${Directory.soundsFolder}/stages/christmas/Lights_Shut_off.ogg');
				}

				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;
				prevCamFollow = camFollow;

				PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + difficulty, PlayState.storyPlaylist[0]);
				FlxG.sound.music.stop();
				Directory.dumpCache();
				FlxG.switchState(new PlayState());
			}
		}
		else
		{
			trace('WENT BACK TO FREEPLAY??');
			FlxG.switchState(new FreeplayState());
		}

		// Clean up notes to free memory
		if (notes != null)
			notes.clear();

		unspawnNotes = [];
	}

	private function popUpScore(strumtime:Float, daNote:Note):Void
	{
		var noteDiff:Float = Math.abs(strumtime - Conductor.songPosition);
		// boyfriend.playAnim('hey');
		vocals.volume = 1;

		var placement:String = Std.string(combo);

		var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
		coolText.screenCenter();
		coolText.x = FlxG.width * 0.55;
		//

		var rating:FlxSprite = new FlxSprite();
		var score:Int = 350;
		var daRating:String = "sick";
		var isSick:Bool = true;

		if (noteDiff > Conductor.safeZoneOffset * 0.9)
		{
			daRating = 'shit';
			score = 50;
			isSick = false; // shitty copypaste on this literally just because im lazy and tired lol!
		}
		else if (noteDiff > Conductor.safeZoneOffset * 0.75)
		{
			daRating = 'bad';
			score = 100;
			isSick = false;
		}
		else if (noteDiff > Conductor.safeZoneOffset * 0.2)
		{
			daRating = 'good';
			score = 200;
			isSick = false;
		}

		if (isSick)
		{
			var noteSplash:NoteSplash = grpNoteSplashes.recycle(NoteSplash);
			noteSplash.setupNoteSplash(daNote.x, daNote.y, daNote.noteData);
			// new NoteSplash(daNote.x, daNote.y, daNote.noteData);
			grpNoteSplashes.add(noteSplash);
		}
		songScore += score;

		/* if (combo > 60)
				daRating = 'sick';
			else if (combo > 12)
				daRating = 'good'
			else if (combo > 4)
				daRating = 'bad';
		 */

		var pixelShitPart1:String = "";
		var pixelShitPart2:String = '';

		if (curStage.startsWith('school'))
		{
			pixelShitPart1 = 'pixelUI/';
			pixelShitPart2 = '-pixel';
		}

		rating.loadGraphic('${Directory.imagesFolder}/ui/' + pixelShitPart1 + daRating + pixelShitPart2 + '.png');
		rating.screenCenter();
		rating.updateHitbox();
		rating.x = coolText.x - 40;
		rating.y -= 60;
		rating.velocity.x -= FlxG.random.int(0, 10);
		rating.velocity.y -= FlxG.random.int(140, 175);
		rating.acceleration.y = 550;

		var comboSpr:FlxSprite = new FlxSprite().loadGraphic('${Directory.imagesFolder}/ui/' + pixelShitPart1 + 'combo' + pixelShitPart2 + '.png');
		comboSpr.screenCenter();
		comboSpr.updateHitbox();
		comboSpr.x = coolText.x;
		comboSpr.velocity.x += FlxG.random.int(1, 10);
		comboSpr.velocity.y -= 150;
		comboSpr.acceleration.y = 600;
		if (combo > 10)
			add(comboSpr);
		add(rating);

		if (curStage.startsWith('school'))
		{
			rating.setGraphicSize(Std.int(rating.width * daPixelZoom * 0.7));
			comboSpr.setGraphicSize(Std.int(comboSpr.width * daPixelZoom * 0.7));
		}
		else
		{
			rating.setGraphicSize(Std.int(rating.width * 0.7));
			rating.antialiasing = PrismPrefs.antialiasing;
			comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
			comboSpr.antialiasing = PrismPrefs.antialiasing;
		}

		var seperatedScore:Array<Int> = [];
		seperatedScore.push(Math.floor(combo / 100));
		seperatedScore.push(Math.floor((combo - (seperatedScore[0] * 100)) / 10));
		seperatedScore.push(combo % 10);

		var daLoop:Int = 0;
		for (i in seperatedScore)
		{
			var numScore:FlxSprite = new FlxSprite().loadGraphic('${Directory.imagesFolder}/ui/' + pixelShitPart1 + 'num${Std.int(i)}' + pixelShitPart2
				+ '.png');
			if (curStage.startsWith('school'))
				numScore.setGraphicSize(Std.int(numScore.width * daPixelZoom));
			else
			{
				numScore.setGraphicSize(Std.int(numScore.width * daPixelZoom));
				numScore.antialiasing = PrismPrefs.antialiasing;
				numScore.setGraphicSize(Std.int(numScore.width * 0.5));
			}
			numScore.screenCenter();
			numScore.updateHitbox();
			numScore.x = coolText.x + (43 * daLoop) - 90;
			numScore.y += 80;
			numScore.velocity.x = FlxG.random.float(-5, 5);
			numScore.velocity.y -= FlxG.random.int(140, 160);
			numScore.acceleration.y = FlxG.random.int(200, 300);
			add(numScore);

			FlxTween.tween(numScore, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween)
				{
					numScore.destroy();
				},
				startDelay: Conductor.crochet * 0.002
			});

			daLoop++;
		}
		/* 
			trace(combo);
			trace(seperatedScore);
		 */

		coolText.text = Std.string(seperatedScore);
		// add(coolText);

		FlxTween.tween(rating, {alpha: 0}, 0.2, {
			startDelay: Conductor.crochet * 0.001
		});

		FlxTween.tween(comboSpr, {alpha: 0}, 0.2, {
			onComplete: function(tween:FlxTween)
			{
				coolText.destroy();
				comboSpr.destroy();
				rating.destroy();
			},
			startDelay: Conductor.crochet * 0.001
		});

		curSection += 1;
	}

	private function keyShit():Void
	{
		// control arrays, order L D R U
		var holdArray:Array<Bool> = [controls.LEFT, controls.DOWN, controls.UP, controls.RIGHT];
		var pressArray:Array<Bool> = [controls.LEFT_P, controls.DOWN_P, controls.UP_P, controls.RIGHT_P];

		// HOLDS, check for sustain notes
		if (holdArray.contains(true) && /*!boyfriend.stunned && */ generatedMusic)
		{
			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.isSustainNote && daNote.canBeHit && daNote.mustPress && holdArray[daNote.noteData])
					goodNoteHit(daNote);
			});
		}

		// PRESSES, check for note hits
		if (pressArray.contains(true) && /*!boyfriend.stunned && */ generatedMusic)
		{
			boyfriend.holdTimer = 0;

			var possibleNotes:Array<Note> = []; // notes that can be hit
			var directionList:Array<Int> = []; // directions that can be hit
			var dumbNotes:Array<Note> = []; // notes to kill later

			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit)
				{
					if (directionList.contains(daNote.noteData))
					{
						for (coolNote in possibleNotes)
						{
							if (coolNote.noteData == daNote.noteData && Math.abs(daNote.strumTime - coolNote.strumTime) < 10)
							{ // if it's the same note twice at < 10ms distance, just delete it
								// EXCEPT u cant delete it in this loop cuz it fucks with the collection lol
								dumbNotes.push(daNote);
								break;
							}
							else if (coolNote.noteData == daNote.noteData && daNote.strumTime < coolNote.strumTime)
							{ // if daNote is earlier than existing note (coolNote), replace
								possibleNotes.remove(coolNote);
								possibleNotes.push(daNote);
								break;
							}
						}
					}
					else
					{
						possibleNotes.push(daNote);
						directionList.push(daNote.noteData);
					}
				}
			});

			for (note in dumbNotes)
			{
				FlxG.log.add("killing dumb ass note at " + note.strumTime);
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}

			possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

			if (possibleNotes.length > 0)
			{
				for (shit in 0...pressArray.length)
				{ // if a direction is hit that shouldn't be
					if (pressArray[shit] && !directionList.contains(shit))
						noteMiss(shit);
				}
				for (coolNote in possibleNotes)
				{
					if (pressArray[coolNote.noteData])
						goodNoteHit(coolNote);
				}
			}
			else
			{
				if (!PrismPrefs.ghostTapping)
				{
					for (shit in 0...pressArray.length)
						if (pressArray[shit])
							noteMiss(shit);
				}
			}
		}

		if (boyfriend.holdTimer > Conductor.stepCrochet * 4 * 0.001 && !holdArray.contains(true))
		{
			if (boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss'))
				boyfriend.playAnim('idle');
		}

		playerStrums.forEach(function(spr:FlxSprite)
		{
			if (pressArray[spr.ID] && spr.animation.curAnim.name != 'confirm')
				spr.animation.play('pressed');
			if (!holdArray[spr.ID])
				spr.animation.play('static');

			if (spr.animation.curAnim.name == 'confirm' && !curStage.startsWith('school'))
			{
				spr.centerOffsets();
				spr.offset.x -= 13;
				spr.offset.y -= 13;
			}
			else
				spr.centerOffsets();
		});
	}

	function noteMiss(direction:Int = 1):Void
	{
		if (!boyfriend.stunned)
		{
			health -= 0.0475;
			if (health < 0)
				health = 0;
			if (combo > 5)
				gf.playAnim('sad');
			combo = 0;
			songScore -= 10;
			songMisses++;

			FlxG.sound.play('${Directory.soundsFolder}/missnote${FlxG.random.int(1, 3)}.ogg', FlxG.random.float(0.1, 0.2));
			// FlxG.log.add('played imss note');

			boyfriend.stunned = true;

			// get stunned for 5 seconds
			new FlxTimer().start(5 / 60, function(tmr:FlxTimer)
			{
				boyfriend.stunned = false;
			});

			switch (direction)
			{
				case 0:
					boyfriend.playAnim('singLEFTmiss', true);
				case 1:
					boyfriend.playAnim('singDOWNmiss', true);
				case 2:
					boyfriend.playAnim('singUPmiss', true);
				case 3:
					boyfriend.playAnim('singRIGHTmiss', true);
			}
		}
	}

	function goodNoteHit(note:Note):Void
	{
		if (!note.wasGoodHit)
		{
			if (!note.isSustainNote)
			{
				popUpScore(note.strumTime, note);
				combo += 1;
				if (PrismPrefs.noteClicks)
					FlxG.sound.play('${Directory.soundsFolder}/noteClick.ogg', 0.75); // turned it down cuz it was way too fucking loud lol
			}

			var sectionIndex:Int = Std.int(curStep / 16);
			var altAnim:String = "";
			if (SONG.notes[sectionIndex] != null && SONG.notes[sectionIndex].bfAltAnim)
				altAnim = '-alt';

			if (note.noteData >= 0)
				health += 0.023;
			else
				health += 0.004;

			switch (note.noteData)
			{
				case 0:
					boyfriend.playAnim('singLEFT$altAnim', true);
				case 1:
					boyfriend.playAnim('singDOWN$altAnim', true);
				case 2:
					boyfriend.playAnim('singUP$altAnim', true);
				case 3:
					boyfriend.playAnim('singRIGHT$altAnim', true);
			}

			playerStrums.forEach(function(spr:FlxSprite)
			{
				if (Math.abs(note.noteData) == spr.ID)
				{
					spr.animation.play('confirm', true);
					spr.centerOffsets();
					if (!curStage.startsWith('school'))
					{
						spr.offset.x -= 13;
						spr.offset.y -= 13;
					}
				}
			});

			note.wasGoodHit = true;
			vocals.volume = 1;

			if (!note.isSustainNote)
			{
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
		}
	}

	override function stepHit():Void
	{
		super.stepHit();

		PrismJsonScript.checkEvents(curStep);

		if (SONG.needsVoices)
		{
			if (vocals.time > Conductor.songPosition + 20 || vocals.time < Conductor.songPosition - 20)
				resyncVocals();
		}
	}

	override function beatHit():Void
	{
		super.beatHit();

		if (stage != null)
			stage.stageUpdate(curBeat, boyfriend, gf, dad);

		if (generatedMusic)
			notes.sort(FlxSort.byY, FlxSort.DESCENDING);

		if (SONG.notes[Math.floor(curStep / 16)] != null)
		{
			if (SONG.notes[Math.floor(curStep / 16)].changeBPM)
			{
				Conductor.changeBPM(SONG.notes[Math.floor(curStep / 16)].bpm);
				FlxG.log.add('CHANGED BPM!');
			}
			// else
			// Conductor.changeBPM(SONG.bpm);
		}

		// SOFTCODING FOR INTENSE ZOOMS!
		if (SONG.notes[Math.floor(curStep / 16)].intenseBumping && camZooming && FlxG.camera.zoom < 1.35)
		{
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;
		}

		if (!SONG.notes[Math.floor(curStep / 16)].intenseBumping && camZooming && FlxG.camera.zoom < 1.35 && curBeat % 4 == 0)
		{
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;
		}

		hud.iconP1.setGraphicSize(Std.int(hud.iconP1.width + 30));
		hud.iconP1.updateHitbox();

		hud.iconP2.setGraphicSize(Std.int(hud.iconP2.width + 30));
		hud.iconP2.updateHitbox();

		if (curBeat % gfSpeed == 0)
			gf.dance();

		if (curBeat % 2 == 0)
		{
			if (!boyfriend.animation.curAnim.name.startsWith("sing"))
				boyfriend.playAnim('idle');
			if (!dad.animation.curAnim.name.startsWith("sing"))
				dad.dance();
		}
		else if (dad.curCharacter == 'spooky')
		{
			if (!dad.animation.curAnim.name.startsWith("sing"))
				dad.dance();
		}

		if (curBeat % 8 == 7 && SONG.song == 'Tutorial' && SONG.song == 'Bopeebo' && dad.curCharacter == 'gf')
		{
			dad.playAnim('cheer', true);
			boyfriend.playAnim('hey', true);
		}
	}
}
