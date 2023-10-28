package funkin.components;

import haxe.ds.StringMap;

@:structInit class HighscoreSave {
	public var score:Int = 0;
	public var misses:Int = 0;
	public var accuracy:Float = 0.00;
	public var rank:String = "N/A";
}

class Highscore {
	public static var songScores:StringMap<HighscoreSave> = new StringMap<HighscoreSave>();
	public static var weekScores:StringMap<HighscoreSave> = new StringMap<HighscoreSave>();

	public static function saveSongScore(song:String, save:HighscoreSave):Void {
		_setScr(weekScores, song, save);
	}

	public static function saveWeekScore(week:String, save:HighscoreSave):Void {
		_setScr(weekScores, week, save);
	}

	public static function getSongScore(song:String):HighscoreSave {
		return _getScr(songScores, song);
	}

	public static function getWeekScore(week:String):HighscoreSave {
		return _getScr(weekScores, week);
	}

	@:dox(hide)
	private static inline function _getScr(map:StringMap<HighscoreSave>, id:String):HighscoreSave {
		final dummy:HighscoreSave = {
			score: 0,
			misses: 0,
			accuracy: 0.00,
			rank: "N/A"
		};
		return map.get(id) != null ? map.get(id) : dummy;
	}

	@:dox(hide)
	private static function _setScr(map:StringMap<HighscoreSave>, id:String, save:HighscoreSave):Void {
		if (map.exists(id))
			if (map.get(id).score < save.score)
				map.set(id, save);
			else
				map.set(id, save);
	}
}
