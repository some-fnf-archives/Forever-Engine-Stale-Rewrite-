package funkin.components.parsers;

import funkin.components.ChartLoader;

class VanillaParser {
	public static function parseChart(json:Dynamic, version:Int = 1):Chart {
		var chart:Chart = new Chart();
		chart.notes = [];
		chart.events = [];

		switch (version) {
			default:
				var curBPM:Float = json.bpm;
				var keys:Int = 4;

				function makePsychEvent():Dynamic {
					return {};
				}

				chart.data = {
					initialBPM: curBPM,
					initialSpeed: json.speed,
					keyAmount: keys,
					playerChar: json.player1 ?? "bf",
					enemyChar: json.player2 ?? "dad",
					crowdChar: json.gfVersion ?? json.player3 ?? "gf",
					stageBG: json.stage ?? getVanillaStage(json.song),
				}

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
				for (i in 0...bars.length) {
					var bar = bars[i];
					if (bar == null)
						continue;

					var curBar:Int = bars.indexOf(bar);
					var barTime:Float = (60.0 / curBPM) / 4.0;

					chart.events.push({
						event: FocusCamera(bar.mustHitSection ? 1 : 0, false),
						time: barTime * bar.lengthInSteps * curBar,
						delay: 0.0
					});

					if (bar.changeBPM == true && bar.bpm != curBPM) {
						curBPM = bar.bpm;
						chart.events.push({
							event: BPMChange(bar.bpm),
							time: barTime * bar.lengthInSteps * curBar,
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

							chart.notes[noteId] = {
								time: j[0] / 1000.0,
								direction: Std.int(j[1]) % keys,
								length: Math.max(j[2], 0.0) / 1000.0,
								notefield: Std.int(j[1]) >= keys != bar.mustHitSection ? 1 : 0,
								type: j[3] != null && Std.isOfType(j[3], String) ? j[3] : "default",
								animation: noteAnim,
							};

							noteId++;
						}
					}
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
