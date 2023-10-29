package funkin.components;

/**
 * Custom Abstract Enumerator for helping with the addition of difficulties and such
**/
enum abstract Difficulty(String) from String to String {
	// -- EDIT THIS WHEN HARDCODING --
	var EASY:String = "easy";
	var NORMAL:String = "normal";
	var HARD:String = "hard";

	public static inline function getDefault():Array<String> {
		return [EASY, NORMAL, HARD];
	}

	public inline function toString():String {
		return switch this {
			// case YOUR_DIFFICULTY: "name"; // if you want custom naming
			case _: this.firstUpperCase();
		}
	}

	// -- STOP EDITING HERE -- //
	public static var list(default, set):Array<String> = [];

	private static inline function set_list(v:Array<String>):Array<String> {
		if (v == null || v.length == 0)
			v = getDefault();
		return list = v;
	}
}
