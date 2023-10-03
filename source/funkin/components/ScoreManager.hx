package funkin.components;

import haxe.ds.StringMap;

class ScoreManager {
	public var score:Int = 0;
	public var accuracy:Float = 0.00;
	public var misses(get, set):Int = 0; // real misses.
	public var comboBreaks:Int = 0;

	public var judgementsHit:StringMap<Int> = ["miss" => 0,];

	// -- GETTERS & SETTERS, DO NOT MESS WITH THESE -- //

	@:noCompletion function get_misses():Int
		return judgementsHit.exists("miss") ? judgementsHit.get("miss") : 0;

	@:noCompletion function set_misses(v:Int):Void
		if (judgementsHit.exists("miss"))
			judgementsHit.set("miss", v);
}
