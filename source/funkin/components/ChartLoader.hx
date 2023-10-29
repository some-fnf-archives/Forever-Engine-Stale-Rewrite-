package funkin.components;

import funkin.components.parsers.*;
import funkin.components.parsers.ForeverChartData;

typedef ForeverEvent = ChartEvent<ForeverEvents>;

class ChartLoader {
	public static function load(folder:String, file:String):Chart {
		var chart:Chart = new Chart();
		var json = cast(AssetHelper.parseAsset('songs/${folder}/${file}', JSON));
		var dataType:EngineImpl = VANILLA_V1;

		if (Reflect.hasField(json, "song") && Reflect.hasField(json.song, "player2"))
			dataType = VANILLA_V1;
		if (Reflect.hasField(json, "codenameChart"))
			dataType = CODENAME;
		if (Reflect.hasField(json, "mustHitSections"))
			dataType = CROW;

		try {
			switch (dataType) {
				// MISSING CROW
				case VANILLA_V1 | PSYCH:
					var ver:Int = dataType == PSYCH ? -1 : 1;
					// v-1 -> Psych | v1 -> 0.2.8 | v2 -> 0.3
					chart = VanillaParser.parseChart(json.song, ver);
				// its unfinished rn so yeah.
				// case CODENAME: chart = CodenameParser.parseChart(json, file);
				case FOREVER:
					// welcome to my tutorial on how to parse charts, first off. -Crow
					// first you get the die
					// and then pour it all over yourself -Swordcube
					chart.notes = json.notes;
					chart.events = json.events;
					if (Tools.fileExists(AssetHelper.getPath('songs/${folder}/meta', YAML))) {
						var sd = cast(AssetHelper.parseAsset('songs/${folder}/meta', YAML));
						chart.songInfo = {beatsPerMinute: sd?.beatsPerMinute ?? 100.0, stepsPerBeat: sd?.stepsPerBeat, beatsPerBar: sd?.beatsPerMeasure};
						chart.gameInfo = {
							noteSpeed: sd?.speed,
							player: sd?.player,
							enemy: sd?.enemy,
							crowd: sd?.crowd
						};
					}
				default:
					trace('${dataType.toString()} Chart Type is not implemented *yet*');
			}

			chart.notes.sort(function(a:NoteData, b:NoteData):Int return Std.int(a.time - b.time));
			chart.events.sort(function(a:ForeverEvent, b:ForeverEvent):Int return Std.int(a.time - b.time));
		}
		catch (e:haxe.Exception)
			trace('Failed to parse chart, type was ${dataType}, Error:\n${e.details()} ' + haxe.CallStack.toString(haxe.CallStack.exceptionStack()));

		return chart;
	}
}

/**
 * Structure for Forever Engine Charts.
**/
class Chart {
	public var notes:Array<NoteData> = [];
	public var events:Array<ForeverEvent> = [];
	public var songInfo:ForeverSongData = null;
	public var gameInfo:ForeverGameplayData = null;

	public static var current:Chart;

	public function new():Void {}
}
