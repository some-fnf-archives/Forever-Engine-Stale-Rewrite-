package funkin.objects.play;

import forever.display.ForeverSprite;
import funkin.components.Timings;
import funkin.components.parsers.ChartFormat.NoteData;
import funkin.objects.play.StrumLine;

/**
 * Note Types
 * Custom ones aren't listed here, they are instead
 * handled by the abstract automatically
**/
enum abstract NoteType(String) from String to String {
	var NORMAL:String = null;
	var MINE:String = "mine";

	/**
	 * Default List of Note Types.
	 * @return Array<String>
	**/
	inline function getDefaultList():Array<String> {
		return [NORMAL, MINE];
	}

	/**
	 * Obtains the priority of a notetype.
	 * @param type 
	 * @return Int
	**/
	public static inline function getHitbox(type:String):Float {
		return switch type {
			case MINE: 0.5; // nerf mines? lower values mean less room to hit
			case _: 1.0;
		}
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
	public var parent:StrumLine;

	/** If this note should follow its parent. **/
	public var mustFollowParent:Bool = true;

	/** Note Speed Multiplier. **/
	public var speedMult:Float = 1.0;

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
	public var hitbox:Float = 0.0;

	// NOTE TYPE BEHAVIOR //
	public var splash:Bool = false;
	public var isMine:Bool = false;

	// NOTESKIN CONFIG STUFF //
	var animations:Array<String> = new Array<String>();

	var sustain:Sustain;

	public function appendData(data:NoteData):Note {
		setPosition(-5000, -5000);

		this.data = data;
		this.type = data.type;
		this.speedMult = 1.0;

		wasHit = isLate = canBeHit = false;
		hitbox = NoteType.getHitbox(data.type);
		playAnim(animations[0], true);
		return this;
	}

	override function update(elapsed:Float):Void {
		if (parent != null && alive) {
			if (mustFollowParent)
				followParent();
			if (sustain != null && sustain.visible && sustain.alive && sustain.exists) {
				sustain.centerToObject(this, X);
				sustain.y = this.y - 5;
			}

			if (!parent.cpuControl) {
				final hitTime = (data.time - Conductor.time);
				canBeHit = hitTime < (Timings.timings.last() / 1000.0) * hitbox;
			}
			else // you can never be so sure.
				canBeHit = false;
		}
	}

	override function draw():Void {
		if (sustain != null && sustain.visible && sustain.alive && sustain.exists)
			sustain.draw();
		super.draw(); // draw behind the note for now
	}

	public function followParent():Void {
		if (parent == null || this.data == null || !alive) return;
		final strum:Receptor = parent.members[direction];
		if (strum == null) return;

		speed = strum.speed;
		visible = parent.visible;

		final time:Float = Conductor.time - data.time;
		final distance:Float = time * (400.0 * (speed * speedMult)) / 0.7; // this needs to be 400.0 since time is second-based

		x = strum.x;
		y = strum.y + distance * scrollDifference;

		// kill notes that are far from the screen view.
		var positionDifference:Float = parent.cpuControl ? y - strum.y : 100.0;
		if (!parent.cpuControl && scrollDifference > 0)
			positionDifference = -positionDifference;

		if (-distance <= (positionDifference * scrollDifference)) {
			if (!wasHit) {
				if (!parent.cpuControl) {
					if (!isMine) {
						parent.onNoteMiss.dispatch(direction, this);
						isLate = true;
					}
				}
				else {
					parent.members[data.dir].playStrum(HIT, true);
					parent.onNoteHit.dispatch(this);
				}
			}
		}
	}

	// -- GETTERS & SETTERS, DO NOT MESS WITH THESE -- //
	@:noCompletion inline function set_speed(v:Float):Float
		return speed = Tools.quantize(v, 1000);

	@:noCompletion inline function get_isSustain():Bool
		return data?.holdLen != 0.0;

	@:noCompletion inline function get_direction():Int
		return data?.dir ?? 0;

	@:noCompletion inline function get_type():String
		return data?.type ?? "normal";

	@:noCompletion function set_type(v:String):String {
		switch (v) {
			// case "your-note-type": // in case you wanna hardcode instead
			default:
				var image:String = parent.noteSkin.notes.image;
				frames = AssetHelper.getAsset('images/notes/${image}', ATLAS_SPARROW);

				for (i in parent.noteSkin.notes.animations) {
					var dir:String = Tools.NOTE_DIRECTIONS[direction ?? 0];
					var color:String = Tools.NOTE_COLORS[direction ?? 0];
					addAtlasAnim(i.name, i.prefix.replace("{dir}", dir).replace("{color}", color), i.fps, i.looped);
					if (i.offsets != null) setOffset(i.name, i.offsets.x, i.offsets.y);
					animations.push(i.name);
				}
				this.antialiasing = !(parent.noteSkin.name == "pixel" || parent.noteSkin.name.endsWith("-pixel"));
				scale.set(parent.noteSkin.notes.size, parent.noteSkin.notes.size);
				updateHitbox();

				/*
				if (isSustain) {
					final sLen:Float = (data.holdLen * 0.5) * Math.abs(speed) / Math.abs(scale.y);
					final img:String = parent.noteSkin.notes.sustain ?? parent.noteSkin.notes.image;
					sustain = new Sustain('notes/${img}', animations[1], sLen, parent.noteSkin.notes.size);
				}
				*/
		}

		return v;
	}

	static inline function get_scrollDifference():Int
		return Settings.downScroll ? 1 : -1;
}
