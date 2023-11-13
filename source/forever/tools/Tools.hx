package forever.tools;

#if !macro
import flixel.FlxG;
import flixel.FlxObject;
import flixel.math.FlxMath;
import flixel.util.FlxAxes;
import flixel.input.keyboard.FlxKey;
import forever.display.ForeverSprite;
#end
import openfl.Assets as OpenFLAssets;

using StringTools;

/** Global Utilities. **/
class Tools {
	public static final NOTE_DIRECTIONS:Array<String> = ["left", "down", "up", "right"];
	public static final NOTE_COLORS:Array<String> = ["purple", "blue", "green", "red"];

	public static var defaultMenuMusic:String = "freakyMenu";
	public static var defaultMenuBeats:Float = 102.0;

	public static inline function fileExists(file:String, ?type:openfl.utils.AssetType = BINARY):Bool {
		return #if sys sys.FileSystem.exists(file) #else OpenFLAssets.exists(file, type) #end;
	}

	public static inline function getText(str:String):String {
		return #if sys sys.io.File.getContent(str) #else OpenFLAssets.getText(str) #end;
	}

	/** Creates a list from a filepath, it is recommended to use this with plaintext files. **/
	public static function listFromFile(path:String):Array<String> {
		return [
			for (t in Tools.getText(path).split("\n"))
				if (t != "" && !StringTools.startsWith(t, "#")) t
		];
	}

	/**
	 * Removes every space from a string.
	 * @param str 			The string to remove spaces from.
	 * @param trim 			If leading and trailing spaces should also be removed.
	 * @return String
	**/
	public static function removeSpaces(str:String, trim:Bool = true):String {
		if (trim)
			StringTools.trim(str);
		return StringTools.replace(str, " ", "");
	}

	/**
	 * Replaces every space from a string with something else.
	 * @param str 			The string to replace spaces from.
	 * @param with 			Another string defining what to replace the spaces with (default "-").
	 * @param trim 			If leading and trailing spaces should also be removed.
	 * @return String
	**/
	public static function replaceSpaces(str:String, with:String = "-", trim:Bool = true):String {
		if (trim)
			StringTools.trim(str);
		return StringTools.replace(str, " ", with);
	}

	/**
	 * Replaces every dash (-) from a string with something else.
	 * @param str 			The string to replace dashes from.
	 * @param with 			Another string defining what to replace the dashes with (default " ").
	 * @param trim 			If leading and trailing spaces should be removed.
	 * @return String
	**/
	public static function replaceDashes(str:String, with:String = " ", trim:Bool = true):String {
		if (trim)
			StringTools.trim(str);
		return StringTools.replace(str, "-", with);
	}

	/**
	 * Formats each word in a string so the first character of the word is uppercase
	 *
	 * ex:
	 * "hello world-test" -> "Hello World Test"
	 * @param str The string to be formatted
	 * @return String
	 */
	public static function firstUpperCase(str:String, ?replaceDashes:Bool = true):String {
		if (replaceDashes)
			str = str.replace("-", " "); // yeah.
		var split = str.split(" ");

		// apply for each word
		for (i in 0...split.length)
			split[i] = split[i].charAt(0).toUpperCase() + split[i].substr(1).toLowerCase();
		return split.join(" ");
	}

	/**
	 * Converts a float value to an integer.
	 * 
	 * e.g: 0.5 -> 50, 1.0 -> 100
	 * @param steps 		Float to transform into a Int
	**/
	public static inline function toIntPercent(steps:Float):Int {
		return Std.int(steps * 100.0);
	}

	/**
	 * Converts a int value to a float.
	 * 
	 * e.g: 50 -> 0.5, 100 -> 1.0
	 * @param step 		Int to transform into a Float
	**/
	public static inline function toFloatPercent(step:Int):Float {
		return step * 0.01;
	}

	public static inline function getPossibleEnumValues(e:EnumValue):Array<Dynamic> {
		// TODO: Abstracts
		// return e.getParameters();
		return [];
	}

	/**
	 * Returns every value in a enum constructor as an ordered array
	 * 
	 * @param e 			the Enum to obtain the parameters from.
	 * @return Array<Dynamic>
	**/
	public static inline function getEnumParams(e:EnumValue):Array<Dynamic> {
		return e.getParameters();
	}

	/**
	 * Returns a specified enum value from its constructor.
	 * @param e 			the Enum to look for said value.
	 * @param value  		the Value ID in the constructor (e.g: 1).
	 * @return Dynamic
	**/
	public static inline function getEnumValue(e:EnumValue, value:Int):Dynamic {
		return e.getParameters()[value];
	}

	/**
	 * Lists every folder in the specified path
	 * @param path 				the path to get folders from
	 * @return Array<String>
	**/
	public static inline function listFolders(path:String):Array<String> {
		var assetsLibrary:Array<String> = [];
		#if sys
		assetsLibrary = sys.FileSystem.readDirectory(path);
		#else
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
		#end
		return assetsLibrary;
	}

	#if !macro // prevent flixel classes from printing errors to the console (in haxe 4.3+)
	public static function changeMaxFramerate(newFramerate:Int):Void {
		if (newFramerate > FlxG.drawFramerate) {
			FlxG.updateFramerate = newFramerate;
			FlxG.drawFramerate = newFramerate;
		}
		else {
			FlxG.drawFramerate = newFramerate;
			FlxG.updateFramerate = newFramerate;
		}
	}

	public static function generateCheckmark():ChildSprite {
		var newCheckmark:ChildSprite = new ChildSprite();
		newCheckmark.frames = AssetHelper.getAsset("menus/options/checkboxThingie", ATLAS_SPARROW);

		newCheckmark.animation.addByPrefix('false finished', 'uncheckFinished');
		newCheckmark.animation.addByPrefix('false', 'uncheck', 12, false);
		newCheckmark.animation.addByPrefix('true finished', 'checkFinished');
		newCheckmark.animation.addByPrefix('true', 'check', 12, false);

		newCheckmark.scale.set(0.7, 0.7);
		newCheckmark.updateHitbox();

		///*
		var offsetByX:Int = 45;
		var offsetByY:Int = 5;
		newCheckmark.setOffset('false', offsetByX, offsetByY);
		newCheckmark.setOffset('true', offsetByX, offsetByY);
		newCheckmark.setOffset('true finished', offsetByX, offsetByY);
		newCheckmark.setOffset('false finished', offsetByX, offsetByY);
		// */

		return newCheckmark;
	}

	/**
	 * Checks whether or not the menu music is playing
	 * and plays it if its not.
	 * @param music 		Music filename you want to play.
	 * @param doFadeIn 		Quite self explanatory right?
	 * @param bpm 			The BPM of the music (needed for beat events and such).
	**/
	public static function checkMenuMusic(music:String = null, ?doFadeIn:Bool = false, ?bpm:Null<Float>):Void {
		if (FlxG.sound.music != null && FlxG.sound.music.playing)
			return;

		if (music == null) music = defaultMenuMusic;
		if (bpm == null) bpm = defaultMenuBeats;

		FlxG.sound.playMusic(AssetHelper.getAsset('audio/bgm/${music}', SOUND), doFadeIn ? 0.0 : 0.7);
		if (doFadeIn)
			FlxG.sound.music.fadeIn(4, 0, 0.7);
		FlxG.sound.music.looped = true;
		Conductor.bpm = bpm;

		// reset stuff
		FlxG.sound.music.onComplete = function():Void Conductor.init(false);
	}

	/**
	 * Centers an object to the center of another object
	 * @param axes 			in which axes should this be centered at (X, Y, XY)
	 * @return FlxObject
	**/
	public static function centerToObject(object:FlxObject, target:FlxObject, axes:FlxAxes = XY):FlxObject {
		// literally just FlxObject.screenCenter but it uses `base` instead of `FlxG.width` and `FlxG.height`
		if (axes.x)
			object.x = target.x + (target.width * 0.5) - (object.width * 0.5);
		if (axes.y)
			object.y = target.y + (target.height * 0.5) - (object.height * 0.5);
		return object;
	}

	public static inline function fpsLerp(from:Float, to:Float, weight:Float) {
		return FlxMath.lerp(from, to, FlxG.elapsed * 60.0 * weight);
	}

	/**
	 * Makes sure that value always stays between 0 and max,
	 * by wrapping the value around.
	 * Float-safe version of `FlxMath.wrap`
	 * @param 	value 	The value to wrap around
	 * @param 	min		The minimum the value is allowed to be
	 * @param 	max 	The maximum the value is allowed to be
	 * @return The wrapped value
	 */
	public static function wrapf(value:Int, min:Float, max:Float):Float {
		return (value < min) ? max : (value > max) ? min : 0;
	}

	public static inline function quantize(Value:Float, Quant:Float) {
		return Math.fround(Value * Quant) / Quant;
	}

	public static inline function keyCodeFromString(str:String):FlxKey {
		return FlxKey.fromString(str.toUpperCase());
	}
	#end

	/**
	 * Replaces the code to not set if the value is null
	 * if an error appears here, then the error is where its called, not in here, since it replaces the code
	 * @param variable		The variable with the value we wanna modify
	 * @param value			The new value for the variable given.
	**/
	public static macro function safeSet(variable:Null<haxe.macro.Expr>, value:Null<haxe.macro.Expr>):Null<haxe.macro.Expr> {
		return macro if (${value} != null) ${variable} = ${value};
	}

	/**
	 * Same as `Tools.safeSet`, but uses reflection, be careful as this may be slower
	 * if used outside of the create function.
	**/
	public static macro function safeReflection(variable:Null<haxe.macro.Expr>, value:Null<haxe.macro.Expr>,
			field:Null<haxe.macro.Expr>):Null<haxe.macro.Expr> {
		return macro if (Reflect.hasField(${value}, ${field})) ${variable} = Reflect.field(${value}, ${field});
	}
}
