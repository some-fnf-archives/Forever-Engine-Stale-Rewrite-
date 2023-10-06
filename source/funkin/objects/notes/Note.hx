package funkin.objects.notes;

import forever.ForeverSprite;
import funkin.components.ChartLoader.NoteData;
import funkin.objects.notes.NoteField;

/**
 * Base Note Object, may appear differently visually depending on its type
 * it can be a spinning mine, a arrow, and less commonly a bar or circle
**/
class Note extends ForeverSprite {
	/**
	 * the Data of the note, often set when spawning it
	 *
	 * stores spawn time, direction, type, and sustain length
	**/
	public var data:NoteData;

	/**
	 * Note Parent Lane
	**/
	public var parent:NoteField;

	/**
	 * If this note should follow its parent.
	**/
	public var mustFollowParent:Bool = true;

	/**
	 * Note Speed Multiplier
	**/
	public var speedMult:Float = 0.0;

	/**
	 * the Type Data of this note, often defines behavior and texture
	**/
	public var type(get, set):String;

	/**
	 * the Direction of this note, simply returns what the direction on `data` is
	**/
	public var direction(get, never):Int;

	/**
	 * Checks if this note is a sustain note
	**/
	public var isSustain(get, never):Bool;

	/**
	 * the Scrolling Speed of this Note
	**/
	public var speed(default, set):Float = 1.0;

	public function new():Void {
		super(-5000, -5000); // make sure its offscreen initially
		visible = false;
	}

	public function appendData(data:NoteData):Note {
		this.data = data;
		this.type = data.type;
		playAnim("scroll", true);
		return this;
	}

	public override function update(elapsed:Float):Void {
		if (parent != null && mustFollowParent)
			followParent();
	}

	public function followParent():Void {
		if (parent == null || this.data == null)
			return;

		var strum:Strum = parent.members[direction];

		if (strum != null) {
			if (!visible)
				visible = true;
			var scrollDifference:Int = Settings.downScroll ? 1 : -1;

			speed = strum.speed;
			scale = strum.scale;

			var distance:Float = 0.45 * (Conductor.time - data.time) * (800.0 * Math.abs(speed)) / scale.y;

			x = strum.x - 10;
			y = strum.y + distance * scrollDifference;
		}
	}

	// -- GETTERS & SETTERS, DO NOT MESS WITH THESE -- //
	// do gay ass sustain nae nae shit here later
	// because I think tiled sprites will need it
	@:noCompletion function set_speed(v:Float):Float
		return speed = flixel.math.FlxMath.roundDecimal(v, 3);

	@:noCompletion function get_isSustain():Bool
		return false;

	@:noCompletion function get_direction():Int
		return data?.direction ?? 0;

	@:noCompletion function get_type():String
		return data?.type ?? "default";

	@noCompletion function set_type(v:String):String {
		switch (v) {
			default:
				frames = AssetHelper.getAsset('images/notes/${NoteConfig.config.notes.image}', ATLAS_SPARROW);
				if (NoteConfig.config.notes.anims.length > 0) {
					for (i in NoteConfig.config.notes.anims) {
						var dir:String = Utils.NOTE_DIRECTIONS[direction ?? 0];
						var color:String = Utils.NOTE_COLORS[direction ?? 0];
						addAtlasAnim(i.name, i.prefix.replace("${dir}", dir).replace("${color}", color), i.fps, i.looped);
					}
				}
		}

		return v;
	}
}
