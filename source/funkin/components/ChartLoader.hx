package funkin.components;

enum abstract ChartType(String) to String {
	/** Forever Engine Style Chart. **/
	var FOREVER = "forever";

	/** Base Game (pre-0.3) Style Chart. **/
	var VANILLA_V1 = "vanilla_v1";

	/** Codename Engine Style Chart. **/
	var CODENAME = "codename";

	/** Crow Engine Style Chart. **/
	var CROW = "crow"; // the engine, not the user. -CrowPlexus

}

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
					var bpm:Float = Reflect.field(json, "bpm");
					var speed:Float = Reflect.field(json, "speed");
					var bars:Array<Dynamic> = Reflect.field(json, "notes");

					// default bpm
					chart.metadata.bpmChanges.push({bpm: bpm, step: Math.NaN});
					// default velocity/speed
					chart.metadata.velocityChanges.push({speed: speed, step: Math.NaN});

					for (bar in bars) {
						var notes:Array<Dynamic> = Reflect.field(bar, "sectionNotes");
						if (Reflect.field(bar, "changeBPM") == true && Reflect.field(bar, "bpm") != bpm)
							bpm = Std.parseFloat(Reflect.field(bar, "bpm"));

						for (note in notes) {
							var funkyNote:NoteData = {
								time: note[0],
								step: Conductor.timeToStep(note[0], bpm),
								direction: Std.int(note[1] % 4),
								type: note[3] != null && Std.isOfType(note[3], String) ? note[3] : "default",
								animation: note[3] != null && Std.isOfType(note[3], Bool) && note[3] == true ? "-alt" : "",
								length: note[2] / Conductor.stepDelta
							}
							chart.notes.push(funkyNote);
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
		}
		catch (e:haxe.Exception)
			trace('Failed to parse chart, type was ${dataType}');

		return chart;
	}
}

class Chart {
	public var notes:Array<NoteData> = [];
	public var events:Array<ChartEvent<ForeverEvents>> = [];
	public var metadata:ChartMetadata = {bpmChanges: [], velocityChanges: []};

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
	@:optional var animation:String;
	@:optional var length:Float;
}

typedef ChartEvent<T> = {
	var event:T;
	var step:Int;
	// meta info, used to tell which bar/section this has been triggered
	var ?bar:Int;
}

typedef ChartMetadata = {
	/** Chart BPM Changes. **/
	var bpmChanges:Array<{bpm:Float, step:Float}>;

	/** Chart Velocity (Scroll Speed) Changes. **/
	var velocityChanges:Array<{speed:Float, step:Float}>;

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
