package funkin.objects.notes;

import forever.display.ForeverSprite;
import funkin.components.Timings;
import funkin.components.parsers.ForeverChartData.NoteData;
import funkin.objects.notes.NoteField;
import haxe.ds.IntMap;

/**
 * Note Types
 * Custom one aren't listed here, they are instead
 * handled by the abstract automatically
**/
enum abstract NoteType(String) from String to String {
	var NORMAL:String = null;
	var MINE:String = "mine";

	inline function getDefList():Array<String> {
		return [NORMAL, MINE];
	}
}

/**
 * Base Note Object, may appear differently visually depending on its type
 * it can be a spinning mine, a arrow, and less commonly a bar or circle
**/
class Note extends ForeverSprite {
	public static var scrollDifference(get, never):Int;

	/**
	 * the Data of the note, often set when spawning it
	 *
	 * stores spawn time, direction, type, and sustain length
	**/
	public var data:NoteData;

	/** Note Parent Notefield. **/
	public var parent:NoteField;

	/** If this note should follow its parent. **/
	public var mustFollowParent:Bool = true;

	/** Note Speed Multiplier. **/
	public var speedMult:Float = 0.0;

	/** the Type Data of this note, often defines behavior and texture. **/
	public var type(get, set):String;

	/** the Direction of this note, simply returns what the direction on `data` is. **/
	public var direction(get, never):Int;

	/** Checks if this note is a sustain note. **/
	public var isSustain(get, never):Bool;

	/** the Scrolling Speed of this Note. **/
	public var speed(default, set):Float = 1.0;

	// INPUT BEHAVIOR //
	public var wasHit:Bool = false;
	public var isLate:Bool = false;
	public var canBeHit:Bool = false;
	public var lowPriority:Bool = false;

	// NOTE TYPE BEHAVIOR //
	public var splash:Bool = false;
	public var isMine:Bool = false;

	// NOTESKIN CONFIG STUFF //
	var animations:IntMap<String> = new IntMap<String>();

	public function appendData(data:NoteData):Note {
		setPosition(-5000, -5000);

		this.data = data;
		this.type = data.type;
		wasHit = isLate = canBeHit = false;
		playAnim(animations.get(0), true);
		return this;
	}

	override function update(elapsed:Float):Void {
		if (parent != null && alive) {
			if (mustFollowParent)
				followParent();

			if (!parent.cpuControl) {
				final timings = Timings.timings.get("fnf");
				final hitTime = (data.time - Conductor.time);
				canBeHit = hitTime < (timings.last() / 1000.0);
			}
			else // you can never be so sure.
				canBeHit = false;
		}
	}

	public function followParent():Void {
		if (parent == null || this.data == null || !alive)
			return;

		var strum:Strum = parent.members[direction];

		if (strum != null) {
			speed = strum.speed;
			scale = scale.set(NoteConfig.config.notes.size, NoteConfig.config.notes.size);
			visible = parent.visible;

			final time:Float = Conductor.time - data.time;
			final distance:Float = time * (400.0 * Math.abs(speed)) / scale.y;

			x = strum.x - 10;
			y = strum.y + distance * scrollDifference;

			// kill notes that are far from the screen view.
			var positionDifference:Float = parent.cpuControl ? (y - strum.y + 10.0) : 100.0;
			if (!parent.cpuControl && scrollDifference > 0)
				positionDifference = -positionDifference;

			if (-distance <= (positionDifference * scrollDifference)) {
				if (!wasHit) {
					if (!parent.cpuControl)
						parent.onNoteMiss.dispatch(direction, this);
					else
						parent.onNoteHit.dispatch(this);
					isLate = true;
				}
			}
		}
	}

	// -- GETTERS & SETTERS, DO NOT MESS WITH THESE -- //
	// do gay ass sustain nae nae shit here later
	// because I think tiled sprites will need it
	@:noCompletion inline function set_speed(v:Float):Float
		return speed = Tools.quantize(v, 1000); // roundDecimal(v, 3)

	@:noCompletion inline function get_isSustain():Bool
		return false;

	@:noCompletion inline function get_direction():Int
		return data?.dir ?? 0;

	@:noCompletion inline function get_type():String
		return data?.type ?? "default";

	@:noCompletion function set_type(v:String):String {
		switch (v) {
			// case "your-note-type": // in case you wanna hardcode instead
			default:
				frames = AssetHelper.getAsset('images/notes/${NoteConfig.config.notes.image}', ATLAS_SPARROW);
				if (NoteConfig.config.notes.anims.length > 0) {
					for (i in NoteConfig.config.notes.anims) {
						var dir:String = Tools.NOTE_DIRECTIONS[direction ?? 0];
						var color:String = Tools.NOTE_COLORS[direction ?? 0];
						addAtlasAnim(i.name, i.prefix.replace("${dir}", dir).replace("${color}", color), i.fps, i.looped);
						if (i.type != null)
							animations.set(i.type, i.name);
					}
				}
		}

		return v;
	}

	static inline function get_scrollDifference():Int
		return Settings.downScroll ? 1 : -1;
}
