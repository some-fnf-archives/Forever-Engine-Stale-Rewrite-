package objects;

import backend.utils.ForeverSprite;

@:structInit class NoteData {
  public var time: Float;
  public var dire: Int;
  public var sLen: Float;
  public var type: String;
  public var lane: Int;
}

class Note extends ForeverSprite {
  /** Data associated with this note. **/
  public var data: NoteData;

  /** Receptor that requested the note to be spawned. **/
  public var receptor: Receptor;

  function set_type(v: String) {
    switch (v) {
      default:
	// init hscript here.
    }
    return type = v;
  }

  /**
   * Define the Note's Type.
   *
   * To add custom behavior to diffent notes,
   * go to the `set_type()` note and add a case for your custom note.
  **/
  public var type(default, set): String;

  /**
   * Whether the note behaves like a mine.
   *
   * a Mine does not count as a Miss when it passes by without being hit,
   * it also has Custom Hit behavior.
  **/
  public var isMine: Bool = false;

  // -- input stuff -- //
  public var wasHit: Bool = false;
  public var wasMissed: Bool = false;

  public var canBeHit(get, never): Bool;
  function get_canBeHit() return relTime < 166.67;

  // -- internal behavior stuff -- //
  private final relTime: Float = (Conductor.time - data.time);
  private var _ogLen: Float = 0.0;

  public function new() {
    super(-5000, -5000); // make sure it's offscreen
  }

  public function init(data: NoteData = null) {
    if (data == null) {
      trace("[Note:init()]: No data specified, appending dummy data.");
      this.data = { time: -5000, dire: 0, type: null, lane: -1, sLen: 0 };
      this.type = this.data.type;
      return;
    }
    this.data = data;
    this.type = data.type;
    this._ogLen = data.sLen;
  }

  public function followStrum() {
    if (receptr == null) return;
    this.x = receptor.x;

    final scrollSpeed: Float = relTime * (0.45 * receptor.speed);
    final scrollDiff: Int = receptor.downScroll ? 1 : -1;

    this.y = receptor.y * scrollSpeed * scrollDiff;
  }

  public function lifeCycle() {
    /* // some player check like this??
    if (!receptor.cpu) {
      if (relTime <= -.15) {
	// cause miss.
      }
      if (relTime <= -.15+(_ogLen)) // kill note if it's too far
	kill();
    }
    else {
      if (relTime <= Conductor.time) {
	this.wasHit = true;
	return;
      }
    }
    */
    // for now i'll just leave this here
    if (relTime <= -.15+(_ogLen))
      kill();
  }
}

