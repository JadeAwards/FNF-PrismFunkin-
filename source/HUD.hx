// done
package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

/**
 * HUD container for PlayState.
 * Holds health bar, icons, score and debug text.
 */
class HUD extends FlxTypedGroup<FlxSprite>
{
	public var healthBarBG:FlxSprite;
	public var healthBar:FlxBar;
	public var iconP1:HealthIcon;
	public var iconP2:HealthIcon;
	public var scoreTxt:FlxText;
	public var debugTxt:FlxText;
	public var cornerMark:FlxText;

	public var health:Float = 1;

	/**
	 * @param playerHealthColor Color of the opponent (dad) health bar.
	 * @param boyfriendHealthColor Color of the player (boyfriend) health bar.
	 */
	public function new()
	{
		super();

		healthBarBG = new FlxSprite(0, FlxG.height * 0.9).loadGraphic('${Directory.imagesFolder}/ui/healthBar.png');
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		if (PrismPrefs.downscroll)
			healthBarBG.y = FlxG.height * 0.1;
		add(healthBarBG);

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'health', 0, 2);
		healthBar.scrollFactor.set();
		add(healthBar);

		iconP1 = new HealthIcon(PlayState.SONG.player1, true);
		iconP1.y = healthBar.y - (iconP1.height / 2);
		add(iconP1);

		iconP2 = new HealthIcon(PlayState.SONG.player2, false);
		iconP2.y = healthBar.y - (iconP2.height / 2);
		add(iconP2);

		scoreTxt = new FlxText(healthBarBG.x + healthBarBG.width - 190, healthBarBG.y + 40, 0, "", 20);
		scoreTxt.setFormat('${Directory.fontsFolder}/vcr.ttf', 16, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreTxt.scrollFactor.set();
		scoreTxt.antialiasing = PrismPrefs.antialiasing;
		add(scoreTxt);

		debugTxt = new FlxText(10, healthBarBG.y - 40, 0, "", 16);
		debugTxt.setFormat(null, 16, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		debugTxt.scrollFactor.set();
		debugTxt.antialiasing = PrismPrefs.antialiasing;
		add(debugTxt);

		if (PrismPrefs.engineBrand)
		{
			cornerMark = new FlxText(0, 0, 0, "Prism Funkin' v" + Main.prismVer);
			cornerMark.setFormat('${Directory.fontsFolder}/vcr.ttf', 18, FlxColor.WHITE);
			cornerMark.setBorderStyle(OUTLINE, FlxColor.BLACK, 2);
			cornerMark.setPosition(FlxG.width - (cornerMark.width + 5), 5);
			cornerMark.antialiasing = PrismPrefs.antialiasing;
			add(cornerMark);
		}
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (healthBar != null)
			healthBar.value = health;
	}
}
