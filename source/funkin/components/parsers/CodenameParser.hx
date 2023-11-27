package funkin.components.parsers;

import funkin.components.ChartLoader;
import funkin.components.parsers.ChartFormat;

/**
 * Codename Engine Chart Parser
 *
 * @author Ne_Eo
**/
class CodenameParser {
	public static function parseChart(songName:String, diff:String):Chart {
		var chart:Chart = new Chart();

		var songData:BeatSignature = {beatsPerMinute: 100.0, stepsPerBeat: 4, beatsPerBar: 4};
		var gameplayData:GameplayData = {
			noteSpeed: 1.0,
			chars: ["bf", "dad", "gf"],
			stageBG: "stage",
			skin: "default"
		}

		// Load into codename format
		var cnebase:ChartData = {
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

		final chartPath:String = AssetHelper.getPath('songs/${songName}/${diff}', JSON);

		final valid:Bool = Tools.fileExists(chartPath);
		if (valid) {
			try cnebase = external.Json.parse(Tools.getText(chartPath))
			catch (e) trace('[ERROR] Could not parse chart for song ${songName} ($diff): ${e}');
		}

		final metaPath = AssetHelper.getPath('songs/${songName.toLowerCase()}/meta', JSON);
		final metaDiffPath = AssetHelper.getPath('songs/${songName.toLowerCase()}/meta-${diff.toLowerCase()}', JSON);

		var metadata:CNEChartMeta = null;
		for (path in [metaDiffPath, metaPath]) {
			if (Tools.fileExists(path)) {
				try metadata = AssetHelper.parseAsset(path, JSON)
				catch (e) trace('[ERROR] Failed to load song metadata for ${songName} ($path): ${e}');
				if (metadata != null) break;
			}
		}

		if (cnebase.meta == null)
			cnebase.meta = metadata;
		else {
			var loadedMeta = metadata;
			for (field in Reflect.fields(cnebase.meta)) {
				var f = Reflect.field(cnebase.meta, field);
				if (f != null)
					Reflect.setField(loadedMeta, field, f);
			}
			cnebase.meta = loadedMeta;
		}

		songData.beatsPerMinute = cnebase.meta.bpm;
		songData.stepsPerBeat = Math.floor(cnebase.meta.stepsPerBeat) ?? 4;
		songData.beatsPerBar = Math.floor(cnebase.meta.beatsPerMesure) ?? 4;

		for (strumLine in cnebase.strumLines) {
			var sl:Int = getStrumLine(strumLine);
			if (strumLine.characters[0] == null) continue;
			gameplayData.chars[sl] = strumLine.characters[0];
		}

		if (cnebase.strumLines.length > 2) {
			// TEMP until multi strumlines are supported
			cnebase.strumLines = [
				cnebase.strumLines[0],
				cnebase.strumLines[1],
				// cnebase.strumLines[2]
			]; // can probs use slice or smth, but im lazy
		}

		// preallocate
		var amt = 0;
		for (strumLine in cnebase.strumLines)
			for (note in strumLine.notes)
				amt++;
		chart.notes.resize(amt);

		// convert to forever format
		var i = 0;
		for (strumLine in cnebase.strumLines) {
			final sl:Int = getStrumLine(strumLine);
			for (note in strumLine.notes) {
				var type = null;
				if (note.type != 0) {
					// its a srting
					type = Std.string(cnebase.noteTypes[note.type - 1]);
				}

				var fnote:NoteData = {time: note.time / 1000.0, dir: note.id};

				// completely optional fields
				if (note.sLen != 0.0) fnote.holdLen = Math.max(note.sLen, 0.0) / 1000.0;
				if (type != null) fnote.type = type;
				if (sl != 0) fnote.lane = sl;

				chart.notes[i] = fnote;
				i++;
			}
		}

		chart.songInfo = songData;
		chart.gameInfo = gameplayData;
		chart.events = []; // TODO

		return chart;
	}

	@:dox(hide) @:noPrivateAccess
	private static function getStrumLine(strumLine:CNEChartSL) {
		return switch (strumLine.position) {
			case "dad": 0;
			case "boyfriend": 1;
			case "girlfriend": 2;
			case _: -1;
		}
	}
}

typedef ChartData = {
	public var strumLines:Array<CNEChartSL>;
	public var events:Array<CNEChartEvent>;
	public var meta:CNEChartMeta;
	public var codenameChart:Bool;
	public var stage:String;
	public var scrollSpeed:Float;
	public var noteTypes:Array<String>;
}

typedef CNEChartSL = {
	var characters:Array<String>;
	var type:CNESLType;
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

typedef CNEChartEvent = {
	public var name:String;
	public var time:Float;
	public var params:Array<Dynamic>;
}

enum abstract CNESLType(Int) from Int to Int {
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
