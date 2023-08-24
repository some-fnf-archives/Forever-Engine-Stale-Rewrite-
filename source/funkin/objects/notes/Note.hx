package funkin.objects.notes;

import forever.ForeverSprite;

/**
 * Note Data Config
**/
typedef NoteData = {
	var time:Float;
	var direction:Int;
	var type:String;
	var length:Float;
}

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
	 * the Direction of this note, simply returns what the direction on `data` is
	**/
	public final direction:Int = data.direction;

	/**
	 * the Scrolling Speed of this Note
	**/
	public var speed(default, set):Float = 1.0;

	/**
	 * Checks if this note is a sustain note
	**/
	public var isSustain(get, never):Bool;

	public function new(data:NoteData):Void {
		super(-5000, -5000); // make sure its offscreen initially

		this.data = data;

		switch (data.type) {
			case "default", "normal", "":
				var noteImg:String = NoteConfig.config.noteImage;
				frames = AssetHelper.getAsset('images/notes/${type}/${noteImg}', ATLAS_SPARROW);

				if (NoteConfig.config.noteAnims.length > 0)
					for (i in NoteConfig.config.noteAnims) {
						var dir:String = Utils.noteDirections[direction];
						var color:String = Utils.noteColors[direction];

						addAtlasAnim(i.name, i.prefix.replace("${dir}", dir).replace("${color}", color), i.fps, i.looped);
					}
		}
	}

	// do gay ass sustain nae nae shit here later
	// because I think tiled sprites will need it
	@:noCompletion function set_speed(v:Float):Float
		return speed = v;

	@:noCompletion function get_isSustain():Bool
		return data.length > 0;
}
