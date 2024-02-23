package objects;

import backend.utils.ForeverSprite;

@:structInit class NoteData {
  public var time: Float;
  public var dire: Int;
  public var sLen: Float;
  public var type: String;
  public var lane: Int;
}

class Note extends ForeverSprite {}
