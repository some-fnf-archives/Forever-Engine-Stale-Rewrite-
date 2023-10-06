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
					var keys:Int = 4; // TODO: convert shaggy charts??
					var totalSteps:Int = 0;

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
						var bar:Dynamic = bars[i];
						var dtSteps:Int = bars[i].lengthInSteps;
						totalSteps += dtSteps;

						if (bar.changeBPM == true && bar.bpm != curBPM) {
							curBPM = bar.bpm;
							chart.data.bpmChanges.push({bpm: bar.bpm, step: totalSteps});
						}

						for (j in cast(bar.sectionNotes, Array<Dynamic>)) {
							if (j[0] < 0) {
								// trace('event note at ${j[1]}, skipping');
								continue;
							}

							var noteAnim:String = "sing" + Utils.NOTE_DIRECTIONS[Std.int(j[1] % chart.data.keyAmount)].toUpperCase();
							if (Std.isOfType(j[3], Bool) && j[3] == true || bar.altAnim)
								noteAnim += "-alt";

							final laneID:Int = (Std.int(j[1]) >= chart.data.keyAmount != bar.mustHitSection) ? 1 : 0;

							chart.notes.push({
								time: j[0] / 1000.0,
								step: Conductor.timeToStep(j[0], curBPM),
								direction: Std.int(j[1] % chart.data.keyAmount),
								lane: laneID,
								type: j[3] != null && Std.isOfType(j[3], String) ? j[3] : "default",
								animation: noteAnim,
								length: j[2] / 1000.0
							});
						}
					}
				case CROW:
					trace('Crow Engine Charts are not implemented *yet*');
				case FOREVER:
					trace("Forever Engine Charts are not implemented *yet*"); // lol ironic i guess.
				case CODENAME:
					trace('Codename Engine Charts are not implemented *yet*');
			}

			chart.notes.sort(function(a:NoteData, b:NoteData):Int return FlxSort.byValues(FlxSort.ASCENDING, a.time, b.time));
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
	public var events:Array<ChartEvent<ForeverEvents>> = [];
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
	var step:Float;
	var time:Float; // original millisecond timing, used for conversion to steps
	var direction:Int;
	var lane:Int;

	@:optional var type:String;
	@:optional var animation:String;
	@:optional var length:Float;
}

typedef ChartEvent<T> = {
	var event:T;
	var step:Int;
	// meta info, used to tell which bar/section this has been triggered
	var ?bar:Int;
}

typedef ChartExtraData = {
	/** Chart's Amount of Keys. **/
	var keyAmount:Int;

	/** Chart's Initial BPM. **/
	var initialBPM:Float;

	/** Chart's Initial Speed. **/
	var initialSpeed:Float;

	/** Chart BPM Changes. **/
	@:optional var bpmChanges:Array<{bpm:Float, step:Float}>;

	/** Chart Velocity (Scroll Speed) Changes. **/
	@:optional var velocityChanges:Array<{speed:Float, step:Float}>;

	/** Player Character. **/
	@:optional var playerChar:String;

	/** Enemy Character. **/
	@:optional var enemyChar:String;

	/** Spectator/GF/Crowd Character. **/
	@:optional var crowdChar:String;

	/** Stage Background Name. **/
	@:optional var stageBG:String;
}

enum ForeverEvents {
	BPMChange(step:Int, nextBPM:Float);
	PlayAnimation(who:Int, animation:String);
	ChangeCharacter(who:Int, toCharacter:String);
	FocusCamera(who:Int, noEasing:Bool);
	PlaySound(soundName:String, volume:Float);
	NoteFieldChange(who:Int, event:NoteFieldEvents);
}

enum NoteFieldEvents {
	VelocityChange(newSpeed:Float, duration:Float);
	NoteRotate(newRotation:Int, duration:Float);
	NoteShake(intensity:Int, duration:Float);
}
