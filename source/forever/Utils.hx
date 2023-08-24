package forever;

import openfl.Assets as OpenFLAssets;
#if macro
import haxe.macro.Expr;
#end

class Utils {
	public static final noteDirections:Array<String> = ["left", "down", "up", "right"];
	public static final noteColors:Array<String> = ["purple", "blue", "green", "red"];

	public static function listFromFile(path:String):Array<String> {
		return [
			for (t in OpenFLAssets.getText(path).split("\n"))
				if (t != "" && !StringTools.startsWith(t, "#")) t
		];
	}

	/**
	 * Replaces the code to not set if the value is null
	 * if an error appears here, then the error is where its called, not in here, since it replaces the code
	**/
	public static macro function safeSet(setTo:Expr, value:Expr) {
		return macro if (${value} != null)
			${setTo} = ${value};
	}
}
