package funkin.components;

import flixel.util.FlxSort;
import funkin.components.parsers.*;

class ChartLoader {
	public static function load(folder:String, file:String):Chart {
		var chart:Chart = new Chart();

		var json = cast AssetHelper.parseAsset('songs/${folder}/${file}', JSON);
		var dataType:String = VANILLA_V1;

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
					chart.notes = json.notes;
					chart.events = json.events;
					var meta:Dynamic = cast json.data;
					if (Tools.fileExists(AssetHelper.getPath('songs/${folder}/meta', JSON)))
						meta = cast AssetHelper.parseAsset('songs/${folder}/meta', JSON);
					chart.data = meta;
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

class Chart {
	public var notes:Array<NoteData> = [];
	public var events:Array<ForeverEvent> = [];
	public var data:ChartMetadata = {initialBPM: 100.0, initialSpeed: 1.0, keyAmount: 4};

	public static var current:Chart;

	public function new():Void {
		// hey so haxe needs this don't delete this DUDE DO NOT TOUCH THIS -Crow & Ne_Eo
	}
}

typedef NoteData = {
	var time:Float;
	var direction:Int;
	var notefield:Int;

	@:optional var type:String;
	@:optional var animation:String;
	@:optional var length:Float;
}

typedef NoteFieldData = {
	var notes:Array<NoteData>;
	var chars:Array<String>;
}

typedef ChartMetadata = {
	/** Chart's Amount of Keys. **/
	var keyAmount:Int;

	/** Chart's Initial BPM. **/
	var initialBPM:Float;

	/** Chart's Initial Speed. **/
	var initialSpeed:Float;

	/** Player Character. **/
	@:optional var playerChar:String;

	/** Enemy Character. **/
	@:optional var enemyChar:String;

	/** Spectator/GF/Crowd Character. **/
	@:optional var crowdChar:String;

	/** Stage Background Name. **/
	@:optional var stageBG:String;
}

typedef ChartEvent<T> = {
	var event:T;
	var time:Float;
	var delay:Float;
}

typedef ForeverEvent = ChartEvent<ForeverEvents>;

enum ForeverEvents {
	BPMChange(nextBPM:Float);
	PlayAnimation(who:Int, animation:String);
	ChangeCharacter(who:Int, toCharacter:String);
	FocusCamera(who:Int, noEasing:Bool);
	PlaySound(soundName:String, volume:Float);

	/**
	 * HScript Event
	 *
	 * @param name 		Name (in the chart editor).
	 * @param script	Script to run for the event.
	 * @param args 		Arguments for the event.
	**/
	Scripted(name:String, script:String, args:Array<String>);
}
