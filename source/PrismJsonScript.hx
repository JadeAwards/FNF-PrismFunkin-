// done
package;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import haxe.Json;
import openfl.utils.Assets;

typedef PrismEvent =
{
	var step:Int; // The exact curStep to fire this event
	var action:String; // "hudvisible", "strumpos", "strumtween", "noteangle", "setslipped", "setsway"
	var val1:String; // 1st variable (e.g. "scoreTxt", "100", "0")
	var val2:String; // 2nd variable (e.g. "false", "50", "15")
	var val3:Null<Float>; // Optional: Duration for tweens
	var val4:Null<String>; // Optional: Ease type ("quadOut", "elasticOut")
}

typedef PrismModchart =
{
	var events:Array<PrismEvent>;
}

class PrismJsonScript
{
	public static var activeModchart:PrismModchart = null;
	private static var firedSteps:Map<String, Bool> = new Map();

	// Global note offsets
	public static var strumXOffsets:Array<Float> = [0, 0, 0, 0, 0, 0, 0, 0];
	public static var strumYOffsets:Array<Float> = [0, 0, 0, 0, 0, 0, 0, 0];
	public static var noteAngles:Array<Float> = [0, 0, 0, 0, 0, 0, 0, 0];

	// Global sway/wavy stuff
	public static var swayIntensity:Float = 0;
	public static var swaySpeed:Float = 2.0;

	// Reset tracking states perfectly when a song starts up
	public static function loadModchart(songName:String):Void
	{
		activeModchart = null;
		firedSteps.clear();
		swayIntensity = 0;
		swaySpeed = 2.0;

		for (i in 0...8)
		{
			strumXOffsets[i] = 0;
			strumYOffsets[i] = 0;
			noteAngles[i] = 0;
		}

		var path:String = 'assets/data/${songName.toLowerCase()}/modchart.json';
		if (Assets.exists(path))
		{
			try
			{
				var rawJson:String = Assets.getText(path);
				activeModchart = Json.parse(rawJson);
				trace('Modchart script parsed smoothly for: ' + songName);
			}
			catch (e:Dynamic)
			{
				trace('Error parsing modchart JSON: ' + Std.string(e));
			}
		}
	}

	public static function checkEvents(curStep:Int):Void
	{
		if (activeModchart == null || activeModchart.events == null)
			return;

		for (event in activeModchart.events)
		{
			if (event.step == curStep)
			{
				var eventKey:String = event.step + "_" + event.action + "_" + event.val1;
				if (firedSteps.exists(eventKey))
					continue;

				firedSteps.set(eventKey, true);
				executeEvent(event);
			}
		}
	}

	private static function executeEvent(event:PrismEvent):Void
	{
		switch (event.action.toLowerCase())
		{
			case "hudvisible":
				if (PlayState.instance != null && PlayState.instance.hud != null)
				{
					var targetVisible:Bool = (event.val2.toLowerCase() == "true");
					switch (event.val1.toLowerCase())
					{
						case "hud": PlayState.instance.hud.visible = targetVisible;
						case "scoretxt": PlayState.instance.hud.scoreTxt.visible = targetVisible;
						case "healthbar": PlayState.instance.hud.healthBar.visible = targetVisible;
						case "healthbarbg": PlayState.instance.hud.healthBarBG.visible = targetVisible;
						case "iconp1": PlayState.instance.hud.iconP1.visible = targetVisible;
						case "iconp2": PlayState.instance.hud.iconP2.visible = targetVisible;
					}
				}

			case "strumpos":
				var changeX = Std.parseFloat(event.val1);
				var changeY = Std.parseFloat(event.val2);

				for (i in 0...8)
				{
					strumXOffsets[i] += changeX;
					strumYOffsets[i] += changeY;
				}

				if (PlayState.instance != null && PlayState.instance.strumLineNotes != null)
				{
					PlayState.instance.strumLineNotes.forEach(function(spr)
					{
						if (spr != null)
						{
							spr.x += changeX;
							spr.y += changeY;
						}
					});
				}

			case "strumtween":
				var changeX = Std.parseFloat(event.val1);
				var changeY = Std.parseFloat(event.val2);
				var dur:Float = (event.val3 != null) ? event.val3 : 1.0;

				var easeFunc = FlxEase.linear;
				if (event.val4 != null)
				{
					switch (event.val4.toLowerCase())
					{
						case "quadout": easeFunc = FlxEase.quadOut;
						case "quadin": easeFunc = FlxEase.quadIn;
						case "quadinout": easeFunc = FlxEase.quadInOut;
						case "elasticout": easeFunc = FlxEase.elasticOut;
					}
				}

				if (PlayState.instance != null && PlayState.instance.strumLineNotes != null)
				{
					PlayState.instance.strumLineNotes.forEach(function(spr)
					{
						if (spr != null)
						{
							var originalXOffset = strumXOffsets[spr.ID];
							var originalYOffset = strumYOffsets[spr.ID];

							FlxTween.num(0, 1, dur, {
								ease: easeFunc,
								onUpdate: function(twn:FlxTween)
								{
									var v:Float = twn.scale;
									var curXShift = changeX * v;
									var curYShift = changeY * v;
									strumXOffsets[spr.ID] = originalXOffset + curXShift;
									strumYOffsets[spr.ID] = originalYOffset + curYShift;
								}
							});

							FlxTween.tween(spr, {x: spr.x + changeX, y: spr.y + changeY}, dur, {ease: easeFunc});
						}
					});
				}

			case "noteangle":
				var lane:Int = Std.parseInt(event.val1);
				var targetAngle:Float = Std.parseFloat(event.val2);

				if (lane >= 0 && lane < 4)
				{
					noteAngles[lane] = targetAngle; // opp
					noteAngles[lane + 4] = targetAngle; // player
				}

			case "setsway":
				// dynamically toggle or update note wavy features
				swayIntensity = Std.parseFloat(event.val1);
				swaySpeed = (event.val3 != null) ? event.val3 : 2.0;
		}
	}

	// calculates wavy motion based on the current song position
	public static function getSwayX(lane:Int, songPos:Float):Float
	{
		if (swayIntensity == 0)
			return 0;
		return Math.sin((songPos * 0.001 * swaySpeed) + (lane * 0.75)) * swayIntensity;
	}
}
