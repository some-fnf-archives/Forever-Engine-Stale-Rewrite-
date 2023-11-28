package funkin.components;

import flixel.util.FlxSort;
import funkin.components.parsers.*;
import funkin.components.parsers.ChartFormat;

typedef ForeverEvent = ChartEvent<ForeverEvents>;

class ChartLoader {
	public static function load(folder:String, file:String):Chart {
		var chart:Chart = new Chart();

		// -- IDENTIFY CHART TYPE HERE -- //

		var json = cast(AssetHelper.parseAsset('songs/${folder}/${file}', JSON));
		var dataType:EngineImpl = FOREVER;

		if (Reflect.hasField(json, "song") && Reflect.hasField(json.song, "needsVoices")) dataType = VANILLA_V1;
		if (Reflect.hasField(json, "codenameChart")) dataType = CODENAME;
		if (Reflect.hasField(json, "mustHitSections")) dataType = CROW;

		// -- PARSING -- //

		try {
			switch (dataType) {
				// MISSING CROW
				case VANILLA_V1 | PSYCH: // v-1 -> Psych | v1 -> 0.2.8 | v2 -> 0.3
					chart = VanillaParser.parseChart(json.song, dataType == PSYCH ? -1 : 1);
				case CODENAME:
					chart = CodenameParser.parseChart(folder, file);
				case FOREVER:
					// welcome to my tutorial on how to parse charts, first off. -Crow
					// first you get the die
					// and then pour it all over yourself -Swordcube

					if (json.notes != null && json.notes.length > 0)
						chart.notes = cast(json.notes);
					if (json.events != null && json.events.length > 0)
						chart.events = Chart.eventListFromArray(json.events);

					if (json.songInfo != null) {
						chart.songInfo = {
							beatsPerMinute: json.songInfo?.beatsPerMinute ?? 100.0,
							stepsPerBeat: json.songInfo?.stepsPerBeat ?? 4,
							beatsPerBar: json.songInfo?.beatsPerBar ?? 4
						};
					}
					if (json.gameInfo != null) {
						final chars:Array<String> = json.gameInfo?.chars ?? ["bf", "dad", "gf"];
						chart.gameInfo = {
							noteSpeed: json.gameInfo?.noteSpeed ?? 1.0,
							chars: chars, stageBG: json.gameInfo?.stageBG ?? null,
							skin: json.gameInfo?.skin ?? "normal"
						};
					}

				default:
					trace('${dataType.toString()} Chart Type is not implemented *yet*');
			}

			if (chart.notes.length > 1) chart.notes.sort((a:NoteData, b:NoteData) -> FlxSort.byValues(FlxSort.ASCENDING, a.time, b.time));
			if (chart.events.length > 1) chart.events.sort((a:ForeverEvent, b:ForeverEvent) -> FlxSort.byValues(FlxSort.ASCENDING, a.time, b.time));
		}
		catch (e:haxe.Exception) {
			trace('Failed to parse chart, type was ${dataType.toString()}, Error:\n${e.details()} '
				+ haxe.CallStack.toString(haxe.CallStack.exceptionStack()));
		}

		// -- -- -- //

		return chart;
	}

	public static inline function exportChart(chart:Chart):String {
		final eventArray:Array<Dynamic> = Chart.eventListToArray(chart.events);
		final exported = haxe.Json.stringify({
			notes: chart.notes,
			events: eventArray,
			songInfo: chart.songInfo,
			gameInfo: chart.gameInfo,
		}, '\t');
		return exported;
	}
}

/** Structure for Forever Engine Charts. **/
class Chart {
	public var notes:Array<NoteData> = [];
	public var events:Array<ForeverEvent> = [];
	public var songInfo:BeatSignature = {beatsPerMinute: 100.0, stepsPerBeat: 4, beatsPerBar: 4};
	public var gameInfo:GameplayData = {noteSpeed: 1.0, chars: ["bf", "dad", "gf"], stageBG: null, skin: "normal"};

	public static var current:Chart;

	public function new():Void {}

	// "oh but if you were going to convert them to arrays anyways, why not using them in the first place?"
	// listen, I want events to also be easy to hardcode.

	public static inline function eventFromArray(arr:Array<Dynamic>):ChartEvent<ForeverEvents> {
		var eTime:Float = Std.parseFloat(arr[1]);
		var coolEvent:ChartEvent<ForeverEvents> = {event: Scripted(arr[0], arr[2], arr[3]), time: eTime}; // dummy event

		var parameters:Array<Dynamic> = [];
		for (i in 2...arr.length) // Skip "Name" and "Time" parameters
			parameters.push(arr[i]);

		var trueEvent:ChartEvent<ForeverEvents> = {
			event: Type.createEnum(ForeverEvents, arr[0], parameters),
			time: eTime
		};
		return trueEvent.event != null && trueEvent.time != -1 ? trueEvent : coolEvent;
	}

	public static inline function eventListFromArray(arr:Array<Array<Dynamic>>):Array<ChartEvent<ForeverEvents>> {
		var coolEvents:Array<ChartEvent<ForeverEvents>> = [];
		var i:Int = 0;
		while (i < arr.length - 1) {
			coolEvents.push(eventFromArray(arr[i]));
			i++;
		}
		return coolEvents;
	}

	public static inline function eventListToArray(arr:Array<ChartEvent<ForeverEvents>>):Array<Dynamic> {
		var coolEvents:Array<Dynamic> = [];
		var i:Int = 0;
		while (i < arr.length - 1) {
			coolEvents.push(eventToArray(arr[i]));
			i++;
		}
		return coolEvents;
	}

	public static inline function eventToArray(evt:ChartEvent<ForeverEvents>):Array<Dynamic> {
		var newEvent:Array<Dynamic> = evt.event.getParameters();
		newEvent.insert(0, evt.event.getName());
		newEvent.insert(1, evt.time);
		return newEvent;
	}
}
