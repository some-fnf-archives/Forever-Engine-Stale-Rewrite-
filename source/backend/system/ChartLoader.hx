package backend.system;

class ChartLoader {
  public static function load(songName: String, difficulty: String = "normal") {
    var path: String = Paths.chart(songName, difficulty);
    var song: Dynamic = haxe.Json.parse(AssetServer.getCont(path));
    var chart: Chart = new Chart();

    if (song.needsVoices != null) chart.loadLegacy(song);
  }
}

@:structInit class Chart {
  public var notes: Array<NoteData>  = [];
  public var events: Array<MapEvent> = [];
  public var keyCount: Int = 4;
  public var version: String = "Unknown";

  public static function loadLegacy(json: Dynamic) {
    if (this == null) return null;

    this.version = "Vanilla V1";
    if (json.disableNoteRGB != null) this.version = "Psych";
    else if (json.arrowSkin != null) this.version = "Psych Legacy";

    // from base game //
    final noteData: Array<FunkinSection> = json.notes;
    for (section in noteData) {
      /*
        final cameraPan: MapEvent = {
          name: "Camera Pan",
          args: [ Std.int(section.mustHitSection) ],
          time: curParsingTime,
          type: MapEvent.ONESHOT
        };
        this.events.push(cameraPan);
      */

      for (songNotes in section.sectionNotes) {
        /*
          final newNote: NoteData = {
            time: songNotes[0].
            dire: Std.int(songNotes[1] % chart.keyCount),
            sLen: songNotes[2] / Conductor.stepCrochet,
            type: songNotes[3],
            lane: gottaHitNote ? 1 : 0
          };
          this.notes.push(newNote);
        */
      }
    }

    return this;
  }
}

/**
 * Old Chart Section Format (pre-0.3)
**/
typedef FunkinSection = {
  // note format: [time, direction, sustainLength, noteType]
  var sectionNotes: Array<Dynamic>;
  var lengthInSteps: Int;
  // var sectionBeats: Float; // Psych Support (TODO)
  var mustHitSection: Int; // Changed this to an int to specify player
  // BPM & TIME CHANGES //
  var bpm: Float;
  var changeBPM: Bool;
  // SECTION MODIFIERS //
  var gfSection: Bool;
  var altAnim: Bool;
}
/**
 * Old Chart Song Format (pre-0.3)
**/
typedef FunkinSong = {
  var song: String;
  var notes: Array<FunkinSection>;
  var bpm: Float;
  var needsVoices: Bool;
  var speed: Float;

  var player1: String;
  var player2: String;
  var gfVersion: String;
  var validScore: Bool;
}
