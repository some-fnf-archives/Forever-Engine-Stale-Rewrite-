package forever;

import openfl.Assets as OpenFLAssets;
#if macro
import haxe.macro.Expr;
#end

class Utils {
	public static final NOTE_DIRECTIONS:Array<String> = ["left", "down", "up", "right"];
	public static final NOTE_COLORS:Array<String> = ["purple", "blue", "green", "red"];

	public static function listFromFile(path:String):Array<String> {
		return [
			for (t in OpenFLAssets.getText(path).split("\n"))
				if (t != "" && !StringTools.startsWith(t, "#")) t
		];
	}

	/**
	 * Replaces the code to not set if the value is null
	 * if an error appears here, then the error is where its called, not in here, since it replaces the code
	 *
	 * @param variable		The variable with the value we wanna modify
	 * @param value			The new value for the variable given.
	**/
	public static macro function safeSet(variable:Null<Expr>, value:Null<Expr>):Null<Expr> {
		return macro if (${value} != null)
			${variable} = ${value};
	}

	/**
	 * Same as `Utils.safeSet`, but uses reflection, be careful as this may be slower
	 * if used outside of the create function.
	**/
	public static macro function safeReflection(variable:Null<Expr>, value:Null<Expr>, field:Null<Expr>):Null<Expr> {
		return macro if (Reflect.hasField(${value}, ${field}))
			${variable} = Reflect.field(${value}, ${field});
	}
}
