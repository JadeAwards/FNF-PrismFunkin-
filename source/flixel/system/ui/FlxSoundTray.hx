package flixel.system.ui;

#if FLX_SOUND_SYSTEM
import flash.Lib;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import flixel.FlxG;
import flixel.system.FlxAssets;
import flixel.util.FlxColor;
import openfl.Assets;
import openfl.utils.AssetType;

/**
 * The flixel sound tray, the little volume meter that pops down sometimes.
 * This project override swaps the default beep for custom volume sounds.
 */
class FlxSoundTray extends Sprite
{
	public var active:Bool;

	var _timer:Float;
	var _bars:Array<Bitmap>;
	var _width:Int = 80;
	var _defaultScale:Float = 2.0;

	var _lastVolume:Float = 1;
	var _lastMuted:Bool = false;

	@:keep
	public function new()
	{
		super();

		visible = false;
		scaleX = _defaultScale;
		scaleY = _defaultScale;

		var tmp:Bitmap = new Bitmap(new BitmapData(_width, 30, true, 0x7F000000));
		screenCenter();
		addChild(tmp);

		var text:TextField = new TextField();
		text.width = tmp.width;
		text.height = tmp.height;
		text.multiline = true;
		text.wordWrap = true;
		text.selectable = false;

		var dtf:TextFormat = new TextFormat(FlxAssets.FONT_DEFAULT, 10, 0xffffff);
		dtf.align = TextFormatAlign.CENTER;
		text.defaultTextFormat = dtf;
		addChild(text);
		text.text = "VOLUME";
		text.y = 16;

		var bx:Int = 10;
		var by:Int = 14;
		_bars = new Array();

		for (i in 0...10)
		{
			tmp = new Bitmap(new BitmapData(4, i + 1, false, FlxColor.WHITE));
			tmp.x = bx;
			tmp.y = by;
			addChild(tmp);
			_bars.push(tmp);
			bx += 6;
			by--;
		}

		y = -height;
		visible = false;
	}

	public function update(MS:Float):Void
	{
		if (_timer > 0)
			_timer -= MS / 1000;
		else if (y > -height)
		{
			y -= (MS / 1000) * FlxG.height * 2;

			if (y <= -height)
			{
				visible = false;
				active = false;

				FlxG.save.data.mute = FlxG.sound.muted;
				FlxG.save.data.volume = FlxG.sound.volume;
				FlxG.save.flush();
			}
		}
	}

	public function show(Silent:Bool = false):Void
	{
		if (!Silent)
			playVolumeSound();

		_timer = 1;
		y = 0;
		visible = true;
		active = true;

		var globalVolume:Int = Math.round(FlxG.sound.volume * 10);

		if (FlxG.sound.muted)
			globalVolume = 0;

		for (i in 0..._bars.length)
		{
			if (i < globalVolume)
				_bars[i].alpha = 1;
			else
				_bars[i].alpha = 0.5;
		}

		_lastVolume = FlxG.sound.volume;
		_lastMuted = FlxG.sound.muted;
	}

	function playVolumeSound():Void
	{
		var currentVolume:Float = FlxG.sound.volume;
		var isMuted:Bool = FlxG.sound.muted;
		var soundPath:String = null;
		if (isMuted && !_lastMuted)
			soundPath = '${Directory.soundsFolder}/soundtray/Voldown.ogg';
		else if (!isMuted && _lastMuted)
			soundPath = currentVolume >= 1 ? '${Directory.soundsFolder}/soundtray/VolMAX.ogg' : '${Directory.soundsFolder}/soundtray/Volup.ogg';
		else if (currentVolume > _lastVolume)
			soundPath = currentVolume >= 1 ? '${Directory.soundsFolder}/soundtray/VolMAX.ogg' : '${Directory.soundsFolder}/soundtray/Volup.ogg';
		else if (currentVolume < _lastVolume)
			soundPath = '${Directory.soundsFolder}/soundtray/Voldown.ogg';

		if (soundPath != null && (Assets.exists(soundPath, AssetType.SOUND) || Assets.exists(soundPath, AssetType.MUSIC)))
			FlxG.sound.play(soundPath);
	}

	public function screenCenter():Void
	{
		scaleX = _defaultScale;
		scaleY = _defaultScale;

		x = (0.5 * (Lib.current.stage.stageWidth - _width * _defaultScale) - FlxG.game.x);
	}
}
#end
