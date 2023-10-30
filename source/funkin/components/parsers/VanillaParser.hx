package funkin.components.parsers;

import funkin.components.ChartLoader;
import funkin.components.parsers.ForeverChartData;

class VanillaParser {
	public static function parseChart(json:Dynamic, version:Int = 1):Chart {
		var chart:Chart = new Chart();
		chart.notes = [];
		chart.events = [];

		switch (version) {
			default:
				var keys:Int = 4;

				function makePsychEvent():Dynamic {
					return {};
				}

				chart.songInfo = {beatsPerMinute: json.bpm, stepsPerBeat: 4, beatsPerBar: 4};
				chart.gameInfo = {
					noteSpeed: json.speed ?? 1.0,
					player: json.player1 ?? "bf",
					enemy: json.player2 ?? "dad",
					crowd: json.player3 ?? json.gfVersion ?? "gf",
					stageBG: json.stage ?? getVanillaStage(json.song)
				};

				var bars:Array<Dynamic> = cast(json.notes, Array<Dynamic>);

				// Preallocate notes
				var amt = 0;
				for (i in 0...bars.length) {
					var bar = bars[i];
					if (bar == null)
						continue;

					var barNotes:Array<Array<Dynamic>> = cast(bar.sectionNotes);
					if (barNotes != null) {
						for (j in barNotes) {
							if (Std.int(j[1]) >= 0)
								amt++;
						}
					}
				}
				chart.notes.resize(amt);

				// Load notes + event
				var noteId = 0;
				var _time:Float = 0;
				var currentBPM:Float = json.bpm;

				var beatDelta:Float = (60.0 / currentBPM);
				var stepDelta:Float = beatDelta * 0.25;

				for (i in 0...bars.length) {
					var bar = bars[i];
					if (bar == null) {
						_time += beatDelta * chart.songInfo.beatsPerBar;
						continue;
					}

					final curBar:Int = bars.indexOf(bar);

					chart.events.push({
						event: FocusCamera(bar.mustHitSection ? 1 : 0, false),
						time: _time,
						delay: 0.0
					});

					if (bar.changeBPM == true && bar.bpm != currentBPM) {
						beatDelta = (60.0 / bar.bpm);
						stepDelta = beatDelta * 0.25;
						currentBPM = bar.bpm;
						chart.events.push({
							event: BPMChange(bar.bpm),
							time: beatDelta + _time * curBar,
							delay: 0.0
						});
					}

					var barNotes:Array<Array<Dynamic>> = cast(bar.sectionNotes);
					if (barNotes == null)
						continue;

					for (j in barNotes) {
						if (Std.int(j[1]) >= 0) { // prevent old psych events from spawning
							var noteAnim:String = "";
							if (Std.isOfType(j[3], Bool) && j[3] == true || bar.altAnim)
								noteAnim = "-alt";

							final note:NoteData = {
								time: j[0] / 1000.0,
								dir: Std.int(j[1]) % keys,
								holdLen: Math.max(j[2], 0.0) / 1000.0,
								notefield: Std.int(j[1]) >= keys != bar.mustHitSection ? 1 : 0,
								type: j[3] != null && Std.isOfType(j[3], String) ? j[3] : "default",
								animation: noteAnim,
							};

							chart.notes[noteId] = note;
							noteId++;
						}
					}

					_time += beatDelta * chart.songInfo.beatsPerBar;
				}
		}
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
