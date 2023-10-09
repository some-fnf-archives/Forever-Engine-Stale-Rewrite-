package forever;

#if !macro
import flixel.FlxG;
import flixel.FlxObject;
import flixel.math.FlxMath;
import flixel.util.FlxAxes;
#end
import openfl.Assets as OpenFLAssets;

using StringTools;

/** Global Utilities. **/
class Utils {
	public static final NOTE_DIRECTIONS:Array<String> = ["left", "down", "up", "right"];
	public static final NOTE_COLORS:Array<String> = ["purple", "blue", "green", "red"];
	private static var curMenuMusic:String = "";

	/** Creates a list from a filepath, it is recommended to use this with plaintext files. **/
	public static function listFromFile(path:String):Array<String> {
		return [
			for (t in OpenFLAssets.getText(path).split("\n"))
				if (t != "" && !StringTools.startsWith(t, "#")) t
		];
	}

	/**
	 * Removes every space from a string.
	 *
	 * @param str 			The string to remove spaces from.
	 * @param trim 			If leading and trailing spaces should also be removed.
	 *
	 * @return String
	**/
	public static function removeSpaces(str:String, trim:Bool = true):String {
		if (trim)
			StringTools.trim(str);
		return StringTools.replace(str, " ", "");
	}

	/**
	 * Replaces every space from a string with something else.
	 *
	 * @param str 			The string to replace spaces from.
	 * @param with 			Another string defining what to replace the spaces with (default "-").
	 * @param trim 			If leading and trailing spaces should also be removed.
	 *
	 * @return String
	**/
	public static function replaceSpaces(str:String, with:String = "-", trim:Bool = true):String {
		if (trim)
			StringTools.trim(str);
		return StringTools.replace(str, " ", with);
	}

	/**
	 * Replaces every dash (-) from a string with something else.
	 *
	 * @param str 			The string to replace dashes from.
	 * @param with 			Another string defining what to replace the dashes with (default " ").
	 * @param trim 			If leading and trailing spaces should be removed.
	 *
	 * @return String
	**/
	public static function replaceDashes(str:String, with:String = " ", trim:Bool = true):String {
		if (trim)
			StringTools.trim(str);
		return StringTools.replace(str, "-", with);
	}

	/**
	 * Lists every folder in the specified path
	 *
	 * @param path 				the path to get folders from
	 * @return Array<String>
	**/
	public static function listFolders(path:String):Array<String> {
		var assetsLibrary:Array<String> = [];
		for (folder in OpenFLAssets.list().filter(list -> list.contains('${path}'))) {
			var daFolder:String = folder.replace('${path}/', '');
			if (daFolder.contains('/'))
				daFolder = daFolder.replace(daFolder.substring(daFolder.indexOf('/'), daFolder.length), ''); // fancy

			if (!daFolder.startsWith('.') && !assetsLibrary.contains(daFolder))
				assetsLibrary.push(daFolder);
		}

		assetsLibrary.sort(function(a:String, b:String):Int {
			a = a.toUpperCase();
			b = b.toUpperCase();

			return (a < b ? -1 : a > b ? 1 : 0);
		});

		trace(assetsLibrary);
		return assetsLibrary;
	}

	#if !macro // prevent flixel classes from printing errors to the console (in haxe 4.3+)

	/**
	 * Checks whether or not the menu music is playing
	 * and plays it if its not.
	 *
	 * @param music 		Music filename you want to play.
	 * @param doFadeIn 		Quite self explanatory right?
	 * @param bpm 			The BPM of the music (needed for beat events and such).
	**/
	public static function checkMenuMusic(music:String, doFadeIn:Bool = false, bpm:Float = 102.0):Void {
		if (FlxG.sound.music == null || (FlxG.sound.music != null && !FlxG.sound.music.playing) || curMenuMusic != music) {
			FlxG.sound.playMusic(AssetHelper.getAsset("music/" + music, SOUND), doFadeIn ? 0.0 : 0.7);
			if (doFadeIn)
				FlxG.sound.music.fadeIn(4, 0, 0.7);

			Conductor.bpm = bpm;
			curMenuMusic = music;
		}
	}

	/**
	 * Centers an object to the center of another object
	 *
	 * @param axes 			in which axes should this be centered at (X, Y, XY)
	 *
	 * @return FlxObject
	**/
	public static function centerToObject(object:FlxObject, target:FlxObject, axes:FlxAxes = XY):FlxObject {
		// literally just FlxObject.screenCenter but it uses `base` instead of `FlxG.width` and `FlxG.height`
		if (axes.x)
			object.x = target.x + (target.width / 2.0) - (object.width / 2.0);
		if (axes.y)
			object.y = target.y + (target.height / 2.0) - (object.height / 2.0);
		return object;
	}

	public static function fpsLerp(from:Float, to:Float, weight:Float) {
		return FlxMath.lerp(from, to, FlxG.elapsed * 60.0 * weight);
	}

	/**
	 * Makes sure that value always stays between 0 and max,
	 * by wrapping the value around.
	 *
	 * Float-safe version of `FlxMath.wrap`
	 *
	 * @param 	value 	The value to wrap around
	 * @param 	min		The minimum the value is allowed to be
	 * @param 	max 	The maximum the value is allowed to be
	 * @return The wrapped value
	 */
	public static function wrapf(value:Int, min:Float, max:Float):Float {
		return (value < min) ? max : (value > max) ? min : 0;
	}
	#end

	/**
	 * Replaces the code to not set if the value is null
	 * if an error appears here, then the error is where its called, not in here, since it replaces the code
	 *
	 * @param variable		The variable with the value we wanna modify
	 * @param value			The new value for the variable given.
	**/
	public static macro function safeSet(variable:Null<haxe.macro.Expr>, value:Null<haxe.macro.Expr>):Null<haxe.macro.Expr> {
		return macro if (${value} != null) ${variable} = ${value};
	}

	/**
	 * Same as `Utils.safeSet`, but uses reflection, be careful as this may be slower
	 * if used outside of the create function.
	**/
	public static macro function safeReflection(variable:Null<haxe.macro.Expr>, value:Null<haxe.macro.Expr>,
			field:Null<haxe.macro.Expr>):Null<haxe.macro.Expr> {
		return macro if (Reflect.hasField(${value}, ${field})) ${variable} = Reflect.field(${value}, ${field});
	}
}
