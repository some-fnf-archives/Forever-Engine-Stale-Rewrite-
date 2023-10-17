package funkin.components;

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

					for (bar in cast(json.song.notes, Array<Dynamic>)) {
						if (bar == null)
							continue;

						final curBar:Int = json.song.notes.indexOf(bar);

						if (bar.changeBPM == true && bar.bpm != curBPM) {
							curBPM = bar.bpm;
							chart.events.push({
								event: BPMChange(bar.bpm),
								step: (60.0 / curBPM) * bar.lengthInSteps * curBar
							});
						}

						chart.events.push({
							event: FocusCamera(bar.mustHitSection ? 1 : 0, false),
							step: (60.0 / curBPM) * bar.lengthInSteps * curBar
						});

						for (j in cast(bar.sectionNotes, Array<Dynamic>)) {
							if (j[0] < 0 || bar.sectionNotes == null) {
								// trace('event note at ${j[1]}, skipping');
								continue;
							}

							var noteAnim:String = "sing" + Utils.NOTE_DIRECTIONS[Std.int(j[1] % chart.data.keyAmount)].toUpperCase();
							if (Std.isOfType(j[3], Bool) && j[3] == true || bar.altAnim)
								noteAnim += "-alt";

							final dirRaw:Int = Std.int(j[1]);

							chart.notes.push({
								time: j[0] / 1000.0,
								direction: dirRaw % keys,
								// barely works, I need to rewrite this later -Crow
								notefield: dirRaw >= keys != bar.mustHitSection ? 1 : 0,
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

			chart.notes.sort(function(a:NoteData, b:NoteData):Int {
				return Std.int(a.time - b.time);
			});

			chart.events.sort(function(a:ChartEvent<ForeverEvents>, b:ChartEvent<ForeverEvents>):Int {
				return Std.int(a.step - b.step);
			});
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
}

enum ForeverEvents {
	BPMChange(nextBPM:Float);
	PlayAnimation(who:Int, animation:String);
	ChangeCharacter(who:Int, toCharacter:String);
	FocusCamera(who:Int, noEasing:Bool);
	PlaySound(soundName:String, volume:Float);
}
