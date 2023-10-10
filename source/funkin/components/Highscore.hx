package funkin.components;

import haxe.ds.StringMap;

typedef HighscoreSave = {
	var score:Int;
	@:optional var accuracy:Float;
	@:optional var misses:Int;
	@:optional var rank:String;
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
	private static function _getScr(map:StringMap<HighscoreSave>, id:String):HighscoreSave {
		if (map.exists(id) && map.get(id) != null)
			return map.get(id);

		return {score: 0, accuracy: 0.00, misses: 0};
	}

	@:dox(hide)
	private static function _setScr(map:StringMap<HighscoreSave>, id:String, save:HighscoreSave):Void {
		if (map.exists(id)) {
			if (map.get(id).score < save.score)
				map.set(id, save);
		}
		else
			map.set(id, save);
	}
}
