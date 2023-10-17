package funkin.components;

import haxe.ds.StringMap;

class ScoreManager {
	public static final rankings:StringMap<Float> = [
		"S+" => 100,
		"S" => 95,
		"A" => 90,
		"B" => 85,
		"C" => 80,
		"D" => 75,
		"E" => 70,
		"F" => 65,
	];

	public static final judgements:Array<String> = ["sick", "good", "bad", "shit"];
	public static final timings:StringMap<Array<Float>> = [
		"fnf" => [33.33, 91.67, 133.33, 166.67],
		"etterna" => [45.0, 90.0, 135.0, 180.0],
	];

	public var score:Int = 0;
	
	public var accuracy:Float = 0.00;
	public var misses(get, set):Int; // real misses.

	public var combo:Int = 0;
	public var comboBreaks:Int = 0;

	public var rank:String = "N/A";

	public var judgementsHit:StringMap<Int> = new StringMap<Int>();

	public function new():Void {
		judgementsHit.clear();
		for (judgement in judgements)
			judgementsHit.set(judgement, 0);
		judgementsHit.set("miss", 0);
	}

	public function updateRank():Void {
		for (score in rankings.keys())
			if (rankings.get(score) <= accuracy)
				rank = score;
	}

	// -- GETTERS & SETTERS, DO NOT MESS WITH THESE -- //

	@:dox(hide) @:noCompletion function get_misses():Int
		return judgementsHit.exists("miss") ? judgementsHit.get("miss") : 0;

	@:dox(hide) @:noCompletion function set_misses(v:Int):Int {
		if (judgementsHit.exists("miss"))
			judgementsHit.set("miss", v);
		return judgementsHit.exists("miss") ? judgementsHit.get("miss") : 0;
	}
}
