// done
package;

import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;

using StringTools;

class Note extends FlxSprite
{
	public var strumTime:Float = 0;

	public var mustPress:Bool = false;
	public var noteData:Int = 0;
	public var canBeHit:Bool = false;
	public var tooLate:Bool = false;
	public var wasGoodHit:Bool = false;
	public var prevNote:Note;

	public var sustainLength:Float = 0;
	public var isSustainNote:Bool = false;

	public static var swagWidth:Float = 160 * 0.7;
	public static var PURP_NOTE:Int = 0;
	public static var GREEN_NOTE:Int = 2;
	public static var BLUE_NOTE:Int = 1;
	public static var RED_NOTE:Int = 3;

	public function new(strumTime:Float, noteData:Int, ?prevNote:Note, ?sustainNote:Bool = false)
	{
		super();

		if (prevNote == null)
			prevNote = this;

		this.prevNote = prevNote;
		isSustainNote = sustainNote;

		x += 78 + 78 / 4;
		// MAKE SURE ITS DEFINITELY OFF SCREEN?
		y -= 2000;
		this.strumTime = strumTime;
		this.noteData = noteData;

		var daStage:String = PlayState.curStage;

		switch (daStage)
		{
			case 'school' | 'schoolEvil':
				loadGraphic('${Directory.imagesFolder}/ui/pixelUI/arrows-pixels.png', true, 17, 17);

				animation.add('purpleScroll', [4]);
				animation.add('blueScroll', [5]);
				animation.add('greenScroll', [6]);
				animation.add('redScroll', [7]);

				if (isSustainNote)
				{
					loadGraphic('${Directory.imagesFolder}/ui/pixelUI/arrowEnds.png', true, 7, 6);

					animation.add('purpleholdend', [4]);
					animation.add('blueholdend', [5]);
					animation.add('greenholdend', [6]);
					animation.add('redholdend', [7]);

					animation.add('purplehold', [0]);
					animation.add('bluehold', [1]);
					animation.add('greenhold', [2]);
					animation.add('redhold', [3]);
				}

				setGraphicSize(Std.int(width * PlayState.daPixelZoom));
				updateHitbox();

			default:
				frames = FlxAtlasFrames.fromSparrow('${Directory.imagesFolder}/ui/NOTE_assets.png', '${Directory.imagesFolder}/ui/NOTE_assets.xml');

				animation.addByPrefix('purpleScroll', 'purple0');
				animation.addByPrefix('blueScroll', 'blue0');
				animation.addByPrefix('greenScroll', 'green0');
				animation.addByPrefix('redScroll', 'red0');

				animation.addByPrefix('purpleholdend', 'pruple end hold');
				animation.addByPrefix('blueholdend', 'blue hold end');
				animation.addByPrefix('greenholdend', 'green hold end');
				animation.addByPrefix('redholdend', 'red hold end');

				animation.addByPrefix('purplehold', 'purple hold piece');
				animation.addByPrefix('bluehold', 'blue hold piece');
				animation.addByPrefix('greenhold', 'green hold piece');
				animation.addByPrefix('redhold', 'red hold piece');

				setGraphicSize(Std.int(width * 0.7));
				updateHitbox();
				antialiasing = PrismPrefs.antialiasing;
		}

		switch (noteData)
		{
			case 0:
				x += swagWidth * 0;
				animation.play('purpleScroll');
			case 1:
				x += swagWidth * 1;
				animation.play('blueScroll');
			case 2:
				x += swagWidth * 2;
				animation.play('greenScroll');
			case 3:
				x += swagWidth * 3;
				animation.play('redScroll');
		}

		// trace(prevNote);

		if (isSustainNote && prevNote != null)
		{
			alpha = 0.6;

			x += width / 2;

			switch (noteData)
			{
				case 0:
					animation.play('purpleholdend');
				case 1:
					animation.play('blueholdend');
				case 2:
					animation.play('greenholdend');
				case 3:
					animation.play('redholdend');
			}

			updateHitbox();

			x -= width / 2;

			if (PlayState.curStage.startsWith('school'))
				x += 30;

			if (prevNote.isSustainNote)
			{
				switch (prevNote.noteData)
				{
					case 0:
						prevNote.animation.play('purplehold');
					case 1:
						prevNote.animation.play('bluehold');
					case 2:
						prevNote.animation.play('greenhold');
					case 3:
						prevNote.animation.play('redhold');
				}
				prevNote.scale.y *= Conductor.stepCrochet / 100 * 1.5 * PlayState.SONG.speed;
				prevNote.updateHitbox();
				// prevNote.setGraphicSize();
			}
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		var laneID:Int = noteData; // 0-3 for opponent, 4-7 for player
		if (mustPress)
			laneID += 4;

		if (PlayState.instance != null
			&& PlayState.instance.strumLineNotes != null
			&& PlayState.instance.strumLineNotes.members != null
			&& PlayState.instance.strumLineNotes.members[laneID] != null)
		{
			var targetReceptor = PlayState.instance.strumLineNotes.members[laneID];

			this.x = targetReceptor.x + PrismJsonScript.getSwayX(laneID, Conductor.songPosition);
			this.y = targetReceptor.y + (strumTime - Conductor.songPosition) * (0.45 * PlayState.SONG.speed);
			this.angle = targetReceptor.angle + PrismJsonScript.noteAngles[laneID];

			// fix sus note
			if (isSustainNote)
				this.x += (Note.swagWidth / 2) - (this.width / 2);
		}
		else // CHART EDITOR FIX!!!
		{
			var gridLane:Int = noteData;
			if (mustPress)
				gridLane += 4;

			// had to edit offsets since notes werent showing properly due to the json note modchart shit
			this.x = 480 + (40 * gridLane);

			// this part took SOOO long but its fixed so yay!!!
			var sectionIndex:Int = Math.floor(Conductor.songPosition / (Conductor.stepCrochet * 16));
			var relativeStep:Float = (strumTime / Conductor.stepCrochet) - (sectionIndex * 16);
			this.y = relativeStep * 40;

			scrollFactor.set(0, 1);

			this.angle = 0;
		}

		if (mustPress)
		{
			// The * 0.5 us so that its easier to hit them too late, instead of too early
			if (strumTime > Conductor.songPosition - Conductor.safeZoneOffset
				&& strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * 0.5))
				canBeHit = true;
			else
				canBeHit = false;

			if (strumTime < Conductor.songPosition - Conductor.safeZoneOffset)
				tooLate = true;
		}
		else
		{
			canBeHit = false;

			if (strumTime <= Conductor.songPosition)
				wasGoodHit = true;
		}

		if (tooLate)
		{
			if (alpha > 0.3)
				alpha = 0.3;
		}
	}
}
