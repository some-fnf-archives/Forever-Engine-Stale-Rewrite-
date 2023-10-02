package funkin.components;

import flixel.util.FlxSort;

class ChartLoader {
	public static function load(folder:String, file:String):Chart {
		var chart:Chart = new Chart();

		var json = cast AssetHelper.getAsset('songs/${folder}/${file}', JSON).song;
		var dataType:String = VANILLA_V1;

		if (Reflect.hasField(json, "notes"))
			dataType = VANILLA_V1;
		if (Reflect.hasField(json, "codenameChart"))
			dataType = CODENAME;
		if (Reflect.hasField(json, "extraData"))
			dataType = CROW;

		try {
			switch (dataType) {
				case VANILLA_V1:
					var bars:Array<Dynamic> = Reflect.field(json, "notes");
					var curBPM:Float = json.bpm;
					chart.data.keyAmount = 4;

					// default bpm
					chart.data.initialBPM = curBPM;
					// default velocity/speed
					chart.data.initialSpeed = json.speed;

					for (bar in bars) {
						var barNotes:Array<Dynamic> = bar.sectionNotes;
						if (bar.changeBPM == true && bar.bpm != curBPM) {
							curBPM = bar.bpm;
							// chart.data.bpmChanges.push({bpm: bar.bpm, step: Conductor.timeToStep()});
						}

						for (note in barNotes) {
							var mustPress:Bool = bar.mustHitSection;
							if (Std.int(note[1]) >= chart.data.keyAmount)
								mustPress = !mustPress;

							chart.notes.push({
								time: note[0] / 1000.0,
								step: Conductor.timeToStep(note[0], curBPM),
								direction: Std.int(note[1] % chart.data.keyAmount),
								lane: mustPress ? 1 : 0,
								type: note[3] != null && Std.isOfType(note[3], String) ? note[3] : "default",
								animation: note[3] != null && Std.isOfType(note[3], Bool) && note[3] == true ? "-alt" : "",
								length: (note[2] / 1000.0) / (curBPM / 60.0) * 4.0
							});
						}
					}

					// Psych Events.
					var events:Array<Dynamic> = Reflect.field(json, "events");

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
	var direction:Int;
	@:optional var time:Float; // original millisecond timing, used for conversion to steps
	@:optional var type:String;
	@:optional var lane:Int;
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

	/** Opponent Character. **/
	@:optional var opponentChar:String;

	/** Spectator/GF/Crowd Character. **/
	@:optional var crowdChar:String;
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
