// done
package;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxPoint;
import flixel.system.FlxSound;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;

using StringTools;

class Stage extends FlxTypedGroup<FlxBasic>
{
	public var curStage:String;

	// Week 2
	var halloweenBG:FlxSprite;
	var isHalloween:Bool = false;

	// Week 3
	var phillyCityLights:FlxTypedGroup<FlxSprite>;
	var phillyTrain:FlxSprite;
	var trainSound:FlxSound;

	// Week 4
	public var limo:FlxSprite;

	var grpLimoDancers:FlxTypedGroup<BackgroundDancer>;
	var fastCar:FlxSprite;

	// Week 5
	var upperBoppers:FlxSprite;
	var bottomBoppers:FlxSprite;
	var santa:FlxSprite;

	// Week 6
	var bgGirls:BackgroundGirls;

	public function new(curStage)
	{
		super();

		this.curStage = curStage;

		var stageToLoad:String = curStage;
		if (PlayState.SONG != null && PlayState.SONG.stage != null && PlayState.SONG.stage != "")
			stageToLoad = PlayState.SONG.stage;
		else
		{
			if (PlayState.SONG != null && PlayState.SONG.song != null)
			{
				switch (PlayState.SONG.song.toLowerCase())
				{
					case 'spookeez' | 'south' | 'monster':
						stageToLoad = 'spooky';
					case 'pico' | 'philly' | 'blammed':
						stageToLoad = 'philly';
					case 'satin-panties' | 'high' | 'milf':
						stageToLoad = 'limo';
					case 'cocoa' | 'eggnog':
						stageToLoad = 'mall';
					case 'winter-horrorland':
						stageToLoad = 'mallEvil';
					case 'senpai' | 'roses':
						stageToLoad = 'school';
					case 'thorns':
						stageToLoad = 'schoolEvil';
					default:
						stageToLoad = 'default';
				}
			}
		}

		PlayState.curStage = stageToLoad;

		if (stageToLoad == 'spooky')
		{
			PlayState.curStage = "spooky";
			PlayState.defaultCamZoom = 1.1;

			isHalloween = true;

			halloweenBG = new FlxSprite(-200, -100);
			halloweenBG.frames = FlxAtlasFrames.fromSparrow('${Directory.imagesFolder}/stages/spooky/halloween_bg.png',
				'${Directory.imagesFolder}/stages/spooky/halloween_bg.xml');
			halloweenBG.animation.addByPrefix('idle', 'halloweem bg0');
			halloweenBG.animation.addByPrefix('lightning', 'halloweem bg lightning strike', 24, false);
			halloweenBG.animation.play('idle');
			halloweenBG.antialiasing = PrismPrefs.antialiasing;
			add(halloweenBG);
		}
		else if (stageToLoad == 'philly')
		{
			PlayState.curStage = 'philly';
			PlayState.defaultCamZoom = 1.05;

			var bg:FlxSprite = new FlxSprite(-100).loadGraphic('${Directory.imagesFolder}/stages/philly/sky.png');
			bg.scrollFactor.set(0.1, 0.1);
			bg.antialiasing = PrismPrefs.antialiasing;
			add(bg);

			var city:FlxSprite = new FlxSprite(-10).loadGraphic('${Directory.imagesFolder}/stages/philly/city.png');
			city.scrollFactor.set(0.3, 0.3);
			city.setGraphicSize(Std.int(city.width * 0.85));
			city.updateHitbox();
			city.antialiasing = PrismPrefs.antialiasing;
			add(city);

			phillyCityLights = new FlxTypedGroup<FlxSprite>();
			add(phillyCityLights);

			for (i in 0...5)
			{
				var light:FlxSprite = new FlxSprite(city.x).loadGraphic('${Directory.imagesFolder}/stages/philly/win$i.png');
				light.scrollFactor.set(0.3, 0.3);
				light.setGraphicSize(Std.int(light.width * 0.85));
				light.updateHitbox();
				light.antialiasing = PrismPrefs.antialiasing;
				light.visible = false;
				phillyCityLights.add(light);
			}

			var streetBehind:FlxSprite = new FlxSprite(-40, 50).loadGraphic('${Directory.imagesFolder}/stages/philly/behindTrain.png');
			add(streetBehind);

			phillyTrain = new FlxSprite(2000, 360).loadGraphic('${Directory.imagesFolder}/stages/philly/train.png');
			phillyTrain.antialiasing = PrismPrefs.antialiasing;
			add(phillyTrain);

			trainSound = new FlxSound().loadEmbedded('${Directory.soundsFolder}/stages/philly/train_passes.ogg');
			FlxG.sound.list.add(trainSound);

			var street:FlxSprite = new FlxSprite(-40, streetBehind.y).loadGraphic('${Directory.imagesFolder}/stages/philly/street.png');
			street.antialiasing = PrismPrefs.antialiasing;
			add(street);
		}
		else if (stageToLoad == 'limo')
		{
			PlayState.curStage = 'limo';
			PlayState.defaultCamZoom = 0.9;

			var skyBG:FlxSprite = new FlxSprite(-120, -50).loadGraphic('${Directory.imagesFolder}/stages/limo/limoSunset.png');
			skyBG.scrollFactor.set(0.1, 0.1);
			skyBG.antialiasing = PrismPrefs.antialiasing;
			add(skyBG);

			var bgLimo:FlxSprite = new FlxSprite(-200, 480);
			bgLimo.frames = FlxAtlasFrames.fromSparrow('${Directory.imagesFolder}/stages/limo/bgLimo.png', '${Directory.imagesFolder}/stages/limo/bgLimo.xml');
			bgLimo.animation.addByPrefix('drive', "background limo pink", 24);
			bgLimo.animation.play('drive');
			bgLimo.scrollFactor.set(0.4, 0.4);
			bgLimo.antialiasing = PrismPrefs.antialiasing;
			add(bgLimo);

			grpLimoDancers = new FlxTypedGroup<BackgroundDancer>();
			add(grpLimoDancers);

			for (i in 0...5)
			{
				var dancer:BackgroundDancer = new BackgroundDancer((370 * i) + 130, bgLimo.y - 400);
				dancer.scrollFactor.set(0.4, 0.4);
				dancer.antialiasing = PrismPrefs.antialiasing;
				grpLimoDancers.add(dancer);
			}

			var overlayShit:FlxSprite = new FlxSprite(-500, -600).loadGraphic('${Directory.imagesFolder}/stages/limo/limoOverlay.png');
			overlayShit.alpha = 0.5;

			limo = new FlxSprite(-120, 550);
			limo.frames = FlxAtlasFrames.fromSparrow('${Directory.imagesFolder}/stages/limo/limoDrive.png',
				'${Directory.imagesFolder}/stages/limo/limoDrive.xml');
			limo.animation.addByPrefix('drive', "Limo stage", 24);
			limo.animation.play('drive');
			limo.antialiasing = PrismPrefs.antialiasing;

			fastCar = new FlxSprite(-300, 160).loadGraphic('${Directory.imagesFolder}/stages/limo/fastCarLol.png');
			fastCar.antialiasing = PrismPrefs.antialiasing;
		}
		else if (stageToLoad == 'mall')
		{
			PlayState.curStage = 'mall';
			PlayState.defaultCamZoom = 0.8;

			var bg:FlxSprite = new FlxSprite(-1000, -500).loadGraphic('${Directory.imagesFolder}/stages/christmas/bgWalls.png');
			bg.scrollFactor.set(0.2, 0.2);
			bg.setGraphicSize(Std.int(bg.width * 0.8));
			bg.updateHitbox();
			bg.antialiasing = PrismPrefs.antialiasing;
			add(bg);

			upperBoppers = new FlxSprite(-240, -90);
			upperBoppers.frames = FlxAtlasFrames.fromSparrow('${Directory.imagesFolder}/stages/christmas/upperBop.png',
				'${Directory.imagesFolder}/stages/christmas/upperBop.xml');
			upperBoppers.animation.addByPrefix('bop', "Upper Crowd Bob", 24, false);
			upperBoppers.scrollFactor.set(0.33, 0.33);
			upperBoppers.setGraphicSize(Std.int(upperBoppers.width * 0.85));
			upperBoppers.updateHitbox();
			upperBoppers.antialiasing = PrismPrefs.antialiasing;
			add(upperBoppers);

			var bgEscalator:FlxSprite = new FlxSprite(-1100, -600).loadGraphic('${Directory.imagesFolder}/stages/christmas/bgEscalator.png');
			bgEscalator.scrollFactor.set(0.3, 0.3);
			bgEscalator.setGraphicSize(Std.int(bgEscalator.width * 0.9));
			bgEscalator.updateHitbox();
			bgEscalator.antialiasing = PrismPrefs.antialiasing;
			add(bgEscalator);

			var tree:FlxSprite = new FlxSprite(370, -250).loadGraphic('${Directory.imagesFolder}/stages/christmas/christmasTree.png');
			tree.scrollFactor.set(0.40, 0.40);
			tree.antialiasing = PrismPrefs.antialiasing;
			add(tree);

			bottomBoppers = new FlxSprite(-300, 140);
			bottomBoppers.frames = FlxAtlasFrames.fromSparrow('${Directory.imagesFolder}/stages/christmas/bottomBop.png',
				'${Directory.imagesFolder}/stages/christmas/bottomBop.xml');
			bottomBoppers.animation.addByPrefix('bop', 'Bottom Level Boppers', 24, false);
			bottomBoppers.scrollFactor.set(0.9, 0.9);
			bottomBoppers.setGraphicSize(Std.int(bottomBoppers.width * 1));
			bottomBoppers.updateHitbox();
			bottomBoppers.antialiasing = PrismPrefs.antialiasing;
			add(bottomBoppers);

			var fgSnow:FlxSprite = new FlxSprite(-600, 700).loadGraphic('${Directory.imagesFolder}/stages/christmas/fgSnow.png');
			fgSnow.antialiasing = PrismPrefs.antialiasing;
			add(fgSnow);

			santa = new FlxSprite(-840, 150);
			santa.frames = FlxAtlasFrames.fromSparrow('${Directory.imagesFolder}/stages/christmas/santa.png',
				'${Directory.imagesFolder}/stages/christmas/santa.xml');
			santa.animation.addByPrefix('idle', 'santa idle in fear', 24, false);
			santa.antialiasing = PrismPrefs.antialiasing;
			add(santa);
		}
		else if (stageToLoad == 'mallEvil')
		{
			PlayState.curStage = 'mallEvil';
			PlayState.defaultCamZoom = 1.05;

			var bg:FlxSprite = new FlxSprite(-400, -500).loadGraphic('${Directory.imagesFolder}/stages/christmas/evilBG.png');
			bg.scrollFactor.set(0.2, 0.2);
			bg.setGraphicSize(Std.int(bg.width * 0.8));
			bg.updateHitbox();
			bg.antialiasing = PrismPrefs.antialiasing;
			add(bg);

			var evilTree:FlxSprite = new FlxSprite(300, -300).loadGraphic('${Directory.imagesFolder}/stages/christmas/evilTree.png');
			evilTree.scrollFactor.set(0.2, 0.2);
			evilTree.antialiasing = PrismPrefs.antialiasing;
			add(evilTree);

			var evilSnow:FlxSprite = new FlxSprite(-200, 700).loadGraphic('${Directory.imagesFolder}/stages/christmas/evilSnow.png');
			evilSnow.antialiasing = PrismPrefs.antialiasing;
			add(evilSnow);
		}
		else if (stageToLoad == 'school')
		{
			PlayState.curStage = 'school';
			PlayState.defaultCamZoom = 1.06;

			var bgSky = new FlxSprite().loadGraphic('${Directory.imagesFolder}/stages/weeb/weebSky.png');
			var widShit = Std.int(bgSky.width * 6);
			bgSky.scrollFactor.set(0.1, 0.1);
			bgSky.setGraphicSize(widShit);
			bgSky.updateHitbox();
			add(bgSky);

			var bgSchool:FlxSprite = new FlxSprite(-200, 0).loadGraphic('${Directory.imagesFolder}/stages/weeb/weebSchool.png');
			bgSchool.scrollFactor.set(0.6, 0.9);
			bgSchool.setGraphicSize(widShit);
			bgSchool.updateHitbox();
			add(bgSchool);

			var bgStreet:FlxSprite = new FlxSprite(-200, 0).loadGraphic('${Directory.imagesFolder}/stages/weeb/weebStreet.png');
			bgStreet.scrollFactor.set(0.95, 0.95);
			bgStreet.setGraphicSize(widShit);
			bgStreet.updateHitbox();
			add(bgStreet);

			var fgTrees:FlxSprite = new FlxSprite(-200 + 170, 130).loadGraphic('${Directory.imagesFolder}/stages/weeb/weebTreesBack.png');
			fgTrees.scrollFactor.set(0.9, 0.9);
			fgTrees.setGraphicSize(Std.int(widShit * 0.8));
			fgTrees.updateHitbox();
			add(fgTrees);

			var bgTrees:FlxSprite = new FlxSprite(-200 - 380, -800);
			bgTrees.frames = FlxAtlasFrames.fromSpriteSheetPacker('${Directory.imagesFolder}/stages/weeb/weebTrees.png',
				'${Directory.imagesFolder}/stages/weeb/weebTrees.txt');
			bgTrees.animation.add('treeLoop', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18], 12);
			bgTrees.animation.play('treeLoop');
			bgTrees.scrollFactor.set(0.85, 0.85);
			bgTrees.setGraphicSize(Std.int(widShit * 1.4));
			bgTrees.updateHitbox();
			add(bgTrees);

			var treeLeaves:FlxSprite = new FlxSprite(-200, -40);
			treeLeaves.frames = FlxAtlasFrames.fromSparrow('${Directory.imagesFolder}/stages/weeb/petals.png',
				'${Directory.imagesFolder}/stages/weeb/petals.xml');
			treeLeaves.animation.addByPrefix('leaves', 'PETALS ALL', 24, true);
			treeLeaves.animation.play('leaves');
			treeLeaves.scrollFactor.set(0.85, 0.85);
			treeLeaves.setGraphicSize(widShit);
			treeLeaves.updateHitbox();
			add(treeLeaves);

			bgGirls = new BackgroundGirls(-100, 190);
			bgGirls.scrollFactor.set(0.9, 0.9);
			bgGirls.setGraphicSize(Std.int(bgGirls.width * PlayState.daPixelZoom));
			bgGirls.updateHitbox();
			if (PlayState.SONG.song.toLowerCase() == 'roses')
				bgGirls.getScared();
			add(bgGirls);
		}
		else if (stageToLoad == 'schoolEvil')
		{
			PlayState.curStage = 'schoolEvil';
			PlayState.defaultCamZoom = 1.2;

			var bg:FlxSprite = new FlxSprite(400, 200);
			bg.frames = FlxAtlasFrames.fromSparrow('${Directory.imagesFolder}/stages/weeb/animatedEvilSchool.png',
				'${Directory.imagesFolder}/stages/weeb/animatedEvilSchool.xml');
			bg.animation.addByPrefix('idle', 'background 2', 24);
			bg.animation.play('idle');
			bg.scrollFactor.set(0.8, 0.9);
			bg.scale.set(6, 6);
			add(bg);
		}
		else
		{
			PlayState.curStage = 'default';
			PlayState.defaultCamZoom = 0.9;

			var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic('${Directory.imagesFolder}/stages/default/stageback.png');
			bg.scrollFactor.set(0.9, 0.9);
			bg.antialiasing = PrismPrefs.antialiasing;
			add(bg);

			var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic('${Directory.imagesFolder}/stages/default/stagefront.png');
			stageFront.scrollFactor.set(0.9, 0.9);
			stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
			stageFront.updateHitbox();
			stageFront.antialiasing = PrismPrefs.antialiasing;
			add(stageFront);

			var stageLight:FlxSprite = new FlxSprite(-125, -100).loadGraphic('${Directory.imagesFolder}/stages/default/stage_light.png');
			stageLight.scrollFactor.set(0.9, 0.9);
			stageLight.setGraphicSize(Std.int(stageLight.width * 1.1));
			stageLight.updateHitbox();
			stageLight.antialiasing = PrismPrefs.antialiasing;
			add(stageLight);

			var stageLight:FlxSprite = new FlxSprite(1225, -100).loadGraphic('${Directory.imagesFolder}/stages/default/stage_light.png');
			stageLight.setGraphicSize(Std.int(stageLight.width * 1.1));
			stageLight.updateHitbox();
			stageLight.antialiasing = PrismPrefs.antialiasing;
			stageLight.flipX = true;
			add(stageLight);

			var stageCurtains:FlxSprite = new FlxSprite(-500, -300).loadGraphic('${Directory.imagesFolder}/stages/default/stagecurtains.png');
			stageCurtains.scrollFactor.set(1.3, 1.3);
			stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
			stageCurtains.updateHitbox();
			stageCurtains.antialiasing = PrismPrefs.antialiasing;
			add(stageCurtains);
		}
	}

	public function gfVersion(curStage)
	{
		var gfVersion:String = 'gf';
		return gfVersion;
	}

	public function dadPos(curStage, dad:Character, gf:Character, camPos:FlxPoint, songPlayer2):Void
	{
		switch (songPlayer2)
		{
			case 'gf':
				dad.setPosition(gf.x, gf.y);
				gf.visible = false;
			case 'dad':
				camPos.x += 400;
			case "spooky":
				dad.y += 200;
			case "monster":
				dad.y += 100;
			case 'pico':
				camPos.x += 600;
				dad.y += 300;
			case 'parents-christmas':
				dad.x -= 500;
			case 'monster-christmas':
				dad.y += 130;
			case 'senpai':
				dad.x += 150;
				dad.y += 360;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'senpai-angry':
				dad.x += 150;
				dad.y += 360;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'spirit':
				dad.x -= 150;
				dad.y += 100;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
		}
	}

	public function playerPos(curStage, dad:Character, boyfriend:Character, gf:Character):Void
	{
		// REPOSITIONING PER STAGE
		switch (curStage)
		{
			case 'limo':
				boyfriend.y -= 220;
				boyfriend.x += 260;

				resetFastCar();
				add(fastCar);
			case 'mall':
				boyfriend.x += 200;
			case 'mallEvil':
				boyfriend.x += 320;

				dad.y -= 80;
			case 'school' | 'schoolEvil':
				boyfriend.x += 200;
				boyfriend.y += 220;

				gf.x += 180;
				gf.y += 300;
		}
	}

	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;

	var trainMoving:Bool = false;
	var trainFrameTiming:Float = 0;
	var trainCars:Int = 8;
	var trainFinishing:Bool = false;
	var trainCooldown:Int = 0;
	var startedMoving:Bool = false;
	var curLight:Int = 0;

	var fastCarCanDrive:Bool = true;

	public function stageUpdate(curBeat:Int, boyfriend:Boyfriend, gf:Character, dadOpponent:Character)
	{
		switch (PlayState.curStage)
		{
			case 'spooky':
				if (isHalloween && FlxG.random.bool(10) && curBeat > lightningStrikeBeat + lightningOffset)
					lightningStrikeShit(curBeat, boyfriend, gf);
			case 'philly':
				if (!trainMoving)
					trainCooldown += 1;

				if (curBeat % 4 == 0)
				{
					var lastLight:FlxSprite = phillyCityLights.members[0];

					phillyCityLights.forEach(function(light:FlxSprite)
					{
						// Take note of the previous light
						if (light.visible == true)
							lastLight = light;

						light.visible = false;
					});

					while (lastLight == phillyCityLights.members[curLight])
						curLight = FlxG.random.int(0, phillyCityLights.length - 1);

					phillyCityLights.members[curLight].visible = true;
					phillyCityLights.members[curLight].alpha = 1;

					FlxTween.tween(phillyCityLights.members[curLight], {alpha: 0}, Conductor.stepCrochet * .016);
				}

				if (curBeat % 8 == 4 && FlxG.random.bool(30) && !trainMoving && trainCooldown > 8)
				{
					trainCooldown = FlxG.random.int(-4, 0);
					trainStart();
				}
			case 'limo':
				grpLimoDancers.forEach(function(dancer:BackgroundDancer)
				{
					dancer.dance();
				});

				if (FlxG.random.bool(10) && fastCarCanDrive)
					fastCarDrive();
			case 'mall':
				upperBoppers.animation.play('bop', true);
				bottomBoppers.animation.play('bop', true);
				santa.animation.play('idle', true);
			case 'school':
				bgGirls.dance();
		}
	}

	public function stageUpdateConstant(elapsed:Float, boyfriend:Boyfriend, gf:Character, dadOpponent:Character)
	{
		switch (PlayState.curStage)
		{
			case 'philly':
				if (trainMoving)
				{
					trainFrameTiming += elapsed;

					if (trainFrameTiming >= 1 / 24)
					{
						updateTrainPos(gf);
						trainFrameTiming = 0;
					}
				}
		}
	}

	function lightningStrikeShit(curBeat:Int, boyfriend:Character, gf:Character):Void
	{
		FlxG.sound.play('${Directory.soundsFolder}/stages/spooky/thunder_${FlxG.random.int(1, 2)}.ogg');
		halloweenBG.animation.play('lightning');

		lightningStrikeBeat = curBeat;
		lightningOffset = FlxG.random.int(8, 24);

		boyfriend.playAnim('scared', true);
		gf.playAnim('scared', true);
	}

	// PHILLY STUFFS!
	public function trainStart():Void
	{
		trainMoving = true;
		if (!trainSound.playing)
			trainSound.play(true);
	}

	public function updateTrainPos(gf:Character):Void
	{
		if (trainSound.time >= 4700)
		{
			startedMoving = true;
			gf.playAnim('hairBlow');
		}

		if (startedMoving)
		{
			phillyTrain.x -= 400;

			if (phillyTrain.x < -2000 && !trainFinishing)
			{
				phillyTrain.x = -1150;
				trainCars -= 1;

				if (trainCars <= 0)
					trainFinishing = true;
			}

			if (phillyTrain.x < -4000 && trainFinishing)
				trainReset(gf);
		}
	}

	public function trainReset(gf:Character):Void
	{
		gf.playAnim('hairFall');
		phillyTrain.x = FlxG.width + 200;
		trainMoving = false;
		// trainSound.stop();
		// trainSound.time = 0;
		trainCars = 8;
		trainFinishing = false;
		startedMoving = false;
	}

	public function resetFastCar():Void
	{
		fastCar.x = -12600;
		fastCar.y = FlxG.random.int(140, 250);
		fastCar.velocity.x = 0;
		fastCarCanDrive = true;
	}

	public function fastCarDrive()
	{
		FlxG.sound.play('${Directory.soundsFolder}/stages/limo/carPass${FlxG.random.int(0, 1)}.ogg', 0.7);

		fastCar.velocity.x = (FlxG.random.int(170, 220) / FlxG.elapsed) * 3;
		fastCarCanDrive = false;
		new FlxTimer().start(2, function(tmr:FlxTimer)
		{
			resetFastCar();
		});
	}
}

class BackgroundDancer extends FlxSprite
{
	public function new(x:Float, y:Float)
	{
		super(x, y);

		frames = FlxAtlasFrames.fromSparrow('${Directory.imagesFolder}/stages/limo/limoDancer.png', '${Directory.imagesFolder}/stages/limo/limoDancer.xml');
		animation.addByIndices('danceLeft', 'bg dancer sketch PINK', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
		animation.addByIndices('danceRight', 'bg dancer sketch PINK', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
		animation.play('danceLeft');
		antialiasing = PrismPrefs.antialiasing;
	}

	var danceDir:Bool = false;

	public function dance():Void
	{
		danceDir = !danceDir;

		if (danceDir)
			animation.play('danceRight', true);
		else
			animation.play('danceLeft', true);
	}
}

class BackgroundGirls extends FlxSprite
{
	public function new(x:Float, y:Float)
	{
		super(x, y);

		// BG fangirls dissuaded
		frames = FlxAtlasFrames.fromSparrow('${Directory.imagesFolder}/stages/weeb/bgFreaks.png', '${Directory.imagesFolder}/stages/weeb/bgFreaks.xml');
		animation.addByIndices('danceLeft', 'BG girls group', CoolUtil.numberArray(14), "", 24, false);
		animation.addByIndices('danceRight', 'BG girls group', CoolUtil.numberArray(30, 15), "", 24, false);
		animation.play('danceLeft');
	}

	var danceDir:Bool = false;

	public function getScared():Void
	{
		animation.addByIndices('danceLeft', 'BG fangirls dissuaded', CoolUtil.numberArray(14), "", 24, false);
		animation.addByIndices('danceRight', 'BG fangirls dissuaded', CoolUtil.numberArray(30, 15), "", 24, false);
		dance();
	}

	public function dance():Void
	{
		danceDir = !danceDir;

		if (danceDir)
			animation.play('danceRight', true);
		else
			animation.play('danceLeft', true);
	}
}
