package funkin.components;

import flixel.util.FlxSort;

class ChartLoader {
	public static function load(folder:String, file:String):Chart {
		var chart:Chart = new Chart();

		var json = cast AssetHelper.getAsset('songs/${folder}/${file}', JSON);
		var dataType:String = VANILLA_V1;

		if (Reflect.hasField(json, "player2"))
			dataType = VANILLA_V1;
		if (Reflect.hasField(json, "codenameChart"))
			dataType = CODENAME;
		if (Reflect.hasField(json, "extraData"))
			dataType = CROW;

		try {
			switch (dataType) {
				case VANILLA_V1:
					var curBPM:Float = json.song.bpm;
					var keys:Int = 4;

					chart.data = {
						initialBPM: curBPM,
						initialSpeed: json.song.speed,
						keyAmount: keys,
						playerChar: json.song.player1 ?? "bf",
						enemyChar: json.song.player2 ?? "dad",
						crowdChar: json.song.player3 ?? json.song.gfVersion ?? "gf",
						stageBG: json.song.stage ?? getVanillaStage(json.song.song),
					}

					var bars:Array<Dynamic> = cast(json.song.notes, Array<Dynamic>);
					for (i in 0...bars.length) {
						var bar = bars[i];
						if (bar == null)
							continue;

						var curBar:Int = json.song.notes.indexOf(bar);
						var barTime:Float = (60.0 / curBPM) / 4.0;

						chart.events.push({
							event: FocusCamera(bar.mustHitSection ? 1 : 0, false),
							step: barTime * bar.lengthInSteps * curBar,
							delay: 0.0
						});

						if (bar.changeBPM == true && bar.bpm != curBPM) {
							curBPM = bar.bpm;
							chart.events.push({
								event: BPMChange(bar.bpm),
								step: barTime * bar.lengthInSteps * curBar,
								delay: 0.0
							});
						}

						var barNotes:Array<Array<Dynamic>> = Reflect.field(bar, "sectionNotes");

						if (barNotes != null) {
							for (j in barNotes) {
								// old psych events
								if (Std.int(j[1]) < 0)
									continue;

								var noteAnim:String = "";
								if (Std.isOfType(j[3], Bool) && j[3] == true || bar.altAnim)
									noteAnim = "-alt";

								chart.notes.push({
									time: j[0] / 1000.0,
									direction: Std.int(j[1]) % keys,
									length: j[2] > 0.0 ? j[2] / 1000.0 : 0.0,
									notefield: Std.int(j[1]) >= keys != bar.mustHitSection ? 1 : 0,
									type: j[3] != null && Std.isOfType(j[3], String) ? j[3] : "default",
									animation: "",
								});
							}
						}
					}
				case CROW:
					trace('Crow Engine Charts are not implemented *yet*');
				case FOREVER:
					trace("Forever Engine Charts are not implemented *yet*"); // lol ironic i guess.
				case CODENAME:
					trace('Codename Engine Charts are not implemented *yet*');
			}

			chart.notes.sort(function(a:NoteData, b:NoteData):Int return Std.int(a.time - b.time));
			chart.events.sort(function(a:ForeverEvent, b:ForeverEvent):Int return Std.int(a.step - b.step));
		}
		catch (e:haxe.Exception)
			trace('Failed to parse chart, type was ${dataType}');
		return chart;
	}

	public static inline function getVanillaStage(song:String):String {
		return switch (song.toLowerCase().replace(" ", "-")) {
			case "ugh", "guns", "stress": "militaryZone";
			case "thorns": "schoolGlitch";
			case "senpai", "roses": "school";
			case "winter-horrorland": "redMall";
			case "cocoa", "eggnog": "mall";
			case "satin-panties", "high", "milf": "highway";
			case "pico", "philly", "philly-nice", "blammed": "phillyCity";
			case "spookeez", "south", "monster": "spookyHouse";
			default: "stage";
		}
	}
}

class Chart {
	public var notes:Array<NoteData> = [];
	public var events:Array<ForeverEvent> = [];
	public var data:ChartExtraData = {initialBPM: 100.0, initialSpeed: 1.0, keyAmount: 4};

	public static var current:Chart;

	public function new():Void {
		current = this;
	}
}

/**
 * Note Data Config
**/
typedef NoteData = {
	var time:Float;
	var direction:Int;
	var notefield:Int;

	@:optional var type:String;
	@:optional var animation:String;
	@:optional var length:Float;
}

typedef ChartExtraData = {
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
	var step:Float;
	var delay:Float;
}

typedef ForeverEvent = ChartEvent<ForeverEvents>;

enum ForeverEvents {
	BPMChange(nextBPM:Float);
	PlayAnimation(who:Int, animation:String);
	ChangeCharacter(who:Int, toCharacter:String);
	FocusCamera(who:Int, noEasing:Bool);
	PlaySound(soundName:String, volume:Float);
}
