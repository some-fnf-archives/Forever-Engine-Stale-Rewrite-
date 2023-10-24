package funkin.components.parsers;

import funkin.components.ChartLoader;

/**
 * Codename Engine Chart Parser
 *
 * @author Ne_Eo
**/
class CodenameParser {
	public static function parseChart(json:Dynamic, diff:String):Chart {
		var chart:Chart = new Chart();

		var curBPM:Float = json.bpm;
		var keys:Int = 4;

		var data:ChartMetadata = {
			initialBPM: 100,
			initialSpeed: 1,
			keyAmount: 4,
			playerChar: "bf",
			enemyChar: "dad",
			crowdChar: "gf",
			stageBG: "stage"
		}

		// Load into codename format
		var cnebase:CNEChartMeta = {
			strumLines: [],
			noteTypes: [],
			events: [],
			meta: {
				name: null
			},
			scrollSpeed: 2,
			stage: "stage",
			codenameChart: true,
		};

		var valid:Bool = true;
		if (!Tools.fileExists(chartPath)) {
			trace('[WARN] Chart for song ${songName} ($difficulty) at "${chartPath}" was not found.');
			valid = false;
		}
		try {
			if (valid)
				cnebase = tjson.TJSON.parse(Tools.getText(chartPath));
		} catch(e)
			trace('[ERROR] Could not parse chart for song ${songName} ($difficulty): ${e}');

		var metaPath = AssetHelper.getPath('songs/${songName.toLowerCase()}/meta', JSON);
		var metaDiffPath = AssetHelper.getPath('songs/${songName.toLowerCase()}/meta-${diff.toLowerCase()}', JSON);

		var metadata:ChartMetadata = null;
		for(path in [metaDiffPath, metaPath]) {
			if (Tools.fileExists(path)) {
				try {
					metadata = AssetHelper.parseAsset(path, JSON);
				} catch(e)
					trace('[ERROR] Failed to load song metadata for ${songName} ($path): ${e}');
				if (metadata != null) break;
			}
		}

		if (cnebase.meta == null)
			cnebase.meta = metadata;
		else {
			var loadedMeta = metadata;
			for(field in Reflect.fields(cnebase.meta)) {
				var f = Reflect.field(cnebase.meta, field);
				if (f != null)
					Reflect.setField(loadedMeta, field, f);
			}
			cnebase.meta = loadedMeta;
		}


		for(strumLine in cnebase.strumLines) {
			var noteField = getNoteField(strumLine);

			if(noteField == 0) data.enemyChar = strumLine.characters[0];
			if(noteField == 1) data.playerChar = strumLine.characters[0];
			if(noteField == 2) data.crowdChar = strumLine.characters[0];
		}

		if(cnebase.strumLines.length > 2) {
			// TEMP until multi strumlines are supported
			cnebase.strumLines = [
				cnebase.strumLines[0],
				cnebase.strumLines[1],
				//cnebase.strumLines[2]
			]; // can probs use slice or smth, but im lazy
		}

		// preallocate
		var amt = 0;
		for(strumLine in cnebase.strumLines) {
			for(note in strumLine.notes) {
				amt++;
			}
		}
		chart.notes.resize(amt);

		// convert to forever format
		var i = 0;
		for(strumLine in cnebase.strumLines) {
			var noteField = getNoteField(strumLine);

			for(note in strumLine.notes) {
				var type = null;
				if(note.noteType != 0) {
					// its a srting
					type = Std.string(cnebase.noteTypes[note.noteType-1]);
				}

				var foreverNote:NoteData = {
					time: note.time / 1000.0,
					direction: note.direction,
					notefield: noteField,
					type: type,
					animation: "",
					length: Math.max(note.sLen, 0.0) / 1000.0
				};
				chart.notes[i] = foreverNote;
				i++;
			}
		}

		chart.data = data;
		chart.events = []; // TODO

		return chart;
	}

	@:dox(hide) @:noPrivateAccess
	private static function getNoteField(strumLine:ChartStrumLine) {
		return switch(strumLine.position) {
			case "dad": 0;
			case "boyfriend": 1;
			case "girlfriend": 2;
		}
	}
}


typedef ChartData = {
	public var strumLines:Array<ChartStrumLine>;
	public var events:Array<ChartEvent>;
	public var meta:ChartMetaData;
	public var codenameChart:Bool;
	public var stage:String;
	public var scrollSpeed:Float;
	public var noteTypes:Array<String>;
}

typedef ChartStrumLine = {
	var characters:Array<String>;
	var type:ChartStrumLineType;
	var notes:Array<ChartNote>;
	var position:String;
	var ?visible:Null<Bool>;
	var ?strumPos:Array<Float>;
	var ?strumScale:Float;
	var ?scrollSpeed:Float;

	var ?strumLinePos:Float; // Backwards compatability
}

typedef ChartNote = {
	var time:Float; // time at which the note will be hit (ms)
	var id:Int; // strum id of the note
	var type:Int; // type (int) of the note
	var sLen:Float; // sustain length of the note (ms)
}

typedef CNEChartMeta = {
	public var name:String;
	public var ?bpm:Float;
	public var ?displayName:String;
	public var ?beatsPerMesure:Float;
	public var ?stepsPerBeat:Float;
	public var ?needsVoices:Bool;
	public var ?icon:String;
	public var ?color:Dynamic;
	public var ?difficulties:Array<String>;
	public var ?coopAllowed:Bool;
	public var ?opponentModeAllowed:Bool;
}

typedef ChartEvent = {
	var name:String;
	var time:Float;
	var params:Array<Dynamic>;
}

enum abstract ChartStrumLineType(Int) from Int to Int {
	/**
	 * STRUMLINE IS MARKED AS OPPONENT - WILL BE PLAYED BY CPU, OR PLAYED BY PLAYER IF OPPONENT MODE IS ON
	 */
	var OPPONENT = 0;
	/**
	 * STRUMLINE IS MARKED AS PLAYER - WILL BE PLAYED AS PLAYER, OR PLAYED AS CPU IF OPPONENT MODE IS ON
	 */
	var PLAYER = 1;
	/**
	 * STRUMLINE IS MARKED AS ADDITIONAL - WILL BE PLAYED AS CPU EVEN IF OPPONENT MODE IS ENABLED
	 */
	var ADDITIONAL = 2;
}