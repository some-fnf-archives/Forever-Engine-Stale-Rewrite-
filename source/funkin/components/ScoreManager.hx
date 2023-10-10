package funkin.components;

import haxe.ds.StringMap;

class ScoreManager {
	public static final jdugements:Array<String> = ["sick", "good", "bad", "shit"];
	public static final timings:StringMap<Array<Float>> = [
		"fnf" => [33.33, 91.67, 133.33, 166.67],
		"etterna" => [45.0, 90.0, 135.0, 180.0],
	];

	var timingWorst(get, never):Float;

	public var score:Int = 0;
	public var accuracy:Float = 0.00;
	public var misses(get, set):Int = 0; // real misses.
	public var comboBreaks:Int = 0;

	public var judgementsHit:StringMap<Int> = [];

	public function new():Void {
		judgementsHit.clear();
		for (judgement in judgements)
			judgementsHit.set(judgement, 0);
		judgementsHit.set("miss", 0);
	}

	// -- GETTERS & SETTERS, DO NOT MESS WITH THESE -- //

	@:noCompletion function get_timingWorst():Float
		return timings[timings.length - 1];

	@:noCompletion function get_misses():Int
		return judgementsHit.exists("miss") ? judgementsHit.get("miss") : 0;

	@:noCompletion function set_misses(v:Int):Void
		if (judgementsHit.exists("miss"))
			judgementsHit.set("miss", v);
}
