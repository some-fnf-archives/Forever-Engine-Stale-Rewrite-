package forever;

import openfl.Assets as OpenFLAssets;
#if !macro
import flixel.FlxObject;
import flixel.math.FlxMath;
import flixel.util.FlxAxes;
#end

using StringTools;

class Utils {
	public static final NOTE_DIRECTIONS:Array<String> = ["left", "down", "up", "right"];
	public static final NOTE_COLORS:Array<String> = ["purple", "blue", "green", "red"];

	public static function listFromFile(path:String):Array<String> {
		return [
			for (t in OpenFLAssets.getText(path).split("\n"))
				if (t != "" && !StringTools.startsWith(t, "#")) t
		];
	}

	public static function removeSpaces(str:String, trim:Bool = true):String {
		if (trim)
			StringTools.trim(str);
		return StringTools.replace(str, " ", "");
	}

	public static function replaceSpaces(str:String, with:String = "-", trim:Bool = true):String {
		if (trim)
			StringTools.trim(str);
		return StringTools.replace(str, " ", with);
	}

	public static function replaceDashes(str:String, with:String = " ", trim:Bool = true):String {
		if (trim)
			StringTools.trim(str);
		return StringTools.replace(str, "-", with);
	}

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

	#if !macro
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
	#end

	/**
	 * Replaces the code to not set if the value is null
	 * if an error appears here, then the error is where its called, not in here, since it replaces the code
	 *
	 * @param variable		The variable with the value we wanna modify
	 * @param value			The new value for the variable given.
	**/
	public static macro function safeSet(variable:Null<haxe.macro.Expr>, value:Null<haxe.macro.Expr>):Null<haxe.macro.Expr> {
		return macro if (${value} != null)
			${variable} = ${value};
	}

	/**
	 * Same as `Utils.safeSet`, but uses reflection, be careful as this may be slower
	 * if used outside of the create function.
	**/
	public static macro function safeReflection(variable:Null<haxe.macro.Expr>, value:Null<haxe.macro.Expr>,
			field:Null<haxe.macro.Expr>):Null<haxe.macro.Expr> {
		return macro if (Reflect.hasField(${value}, ${field}))
			${variable} = Reflect.field(${value}, ${field});
	}
}
