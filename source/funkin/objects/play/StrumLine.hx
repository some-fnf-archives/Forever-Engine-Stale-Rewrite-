package funkin.objects.play;

import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.input.keyboard.FlxKey;
import flixel.util.FlxSignal.FlxTypedSignal;
import forever.display.ForeverSprite;
import funkin.components.parsers.ForeverChartData.NoteData;
import funkin.ui.NoteSkin;
import openfl.events.KeyboardEvent;

enum abstract StrumAnimationType(Int) to Int {
	var STATIC = 0;
	var PRESS = 1;
	var HIT = 2;
}

class Strum extends ForeverSprite {
	public var speed:Float = 1.0;
	public var animations:Array<String> = new Array<String>();
	public var animPlayed:Int = -1;
	public var skin:NoteSkin = null;

	public function new(x:Float, y:Float, skin:NoteSkin, id:Int):Void {
		super(x, y);

		this.skin = skin;
		this.ID = id;

		frames = AssetHelper.getAsset('images/notes/${skin.strums.image}', ATLAS_SPARROW);
		this.antialiasing = !(skin.name == "pixel" || skin.name.endsWith("-pixel"));

		for (i in skin.strums.animations) {
			var dir:String = Tools.NOTE_DIRECTIONS[id];
			var color:String = Tools.NOTE_COLORS[id];

			addAtlasAnim(i.name, i.prefix.replace("{dir}", dir).replace("{color}", color), i.fps, i.looped);
			if (i.offsets != null)
				setOffset(i.name, i.offsets.x, i.offsets.y);
			animations.push(i.name);
		}

		playStrum(STATIC, true);
	}

	public function playStrum(type:Int, forced:Bool = false, reversed:Bool = false, frame:Int = 0):Void {
		playAnim(animations[type], forced, reversed, frame);
		centerOrigin();
		centerOffsets();
		animPlayed = type;
	}
}

class StrumLine extends FlxTypedSpriteGroup<Strum> {
	public var skin:String;
	public var playField:PlayField;
	public var cpuControl:Bool;
	public var globalSpeed(default, set):Float = 1.0;

	public var noteSkin:NoteSkin;

	// READ ONLY VARIABLES
	public var size(get, never):Float;
	public var spacing(get, never):Int;
	public var fieldWidth(get, never):Float;

	public var onNoteHit:FlxTypedSignal<Note->Void>;
	public var onNoteMiss:FlxTypedSignal<(Int, Note) -> Void>;

	public var controls:Array<String> = ["left", "down", "up", "right"];

	public function new(playField:PlayField, x:Float, y:Float, newSpeed:Float = 1.0, skin:String = "normal", cpuControl:Bool = true):Void {
		super();

		this.playField = playField;
		this.cpuControl = cpuControl;

		onNoteHit = new FlxTypedSignal<Note->Void>();
		onNoteMiss = new FlxTypedSignal<(Int, Note) -> Void>();

		if (!cpuControl && playField != null) {
			FlxG.stage.addEventListener(openfl.events.KeyboardEvent.KEY_DOWN, inputKeyPress);
			FlxG.stage.addEventListener(openfl.events.KeyboardEvent.KEY_UP, inputKeyRelease);
		}

		regenStrums(skin, false);
		// DON'T CALL THIS WHILE NO STRUMS EXIST, SINCE THEY NEED TO EXIST SO THEIR SPEED CAN BE SET
		setupStrumline(x, y, newSpeed);
	}

	override function update(elapsed:Float):Void {
		if (cpuControl) {
			for (i in 0...members.length) // this here? this is dumb, dumb as hell -Crow
				if (members[i].animPlayed == HIT && members[i].animation.finished)
					members[i].playStrum(STATIC, true);
		}
		super.update(elapsed);
	}

	override function destroy():Void {
		if (!cpuControl && playField != null) {
			FlxG.stage.removeEventListener(openfl.events.KeyboardEvent.KEY_DOWN, inputKeyPress);
			FlxG.stage.removeEventListener(openfl.events.KeyboardEvent.KEY_UP, inputKeyRelease);
		}
		super.destroy();
	}

	public function setupStrumline(?x:Null<Float>, ?y:Null<Float>, ?newSpeed:Null<Float>):Void {
		if (x != null) this.x = x;
		if (y != null) this.y = y;
		if (newSpeed != null) this.globalSpeed = newSpeed;
	}

	public function regenStrums(skin:String, skipStrumTween:Bool = false):Void {
		this.skin = skin;

		if (noteSkin != null) noteSkin.loadSkin(skin);
		else noteSkin = new NoteSkin(skin);

		while (members.length > 0)
			members.pop().destroy();

		// bro think they psych engine
		var targetAlpha:Float = (Settings.centerStrums && cpuControl) ? 0.6 : 0.8; // pair with original FE
		var keys:Int = 4;

		for (i in 0...keys) {
			final strum:Strum = new Strum(0, 0, noteSkin, i);
			strum.scale.set(size, size);
			strum.updateHitbox();
			strum.x += (fieldWidth * i);
			add(strum);

			if (!skipStrumTween) {
				strum.alpha = 0.0;
				final crochet:Float = 60.0 / Conductor.bpm;
				strum.tween({alpha: targetAlpha}, (crochet) * 4.0, {
					ease: FlxEase.circOut,
					startDelay: crochet * i
				});
			}
		}
	}

	public function changeStrumSpeed(newSpeed:Float, strumID:Int = -1):Void {
		if (strumID == -1 || strumID > members.indexOf(members.last())) {
			for (i in 0...members.length)
				if (Std.isOfType(members[i], Strum))
					members[i].speed = newSpeed;
		}
		else {
			members[strumID].speed = newSpeed;
			globalSpeed = newSpeed;
		}
	}

	public function createSplash(note:NoteData, force:Bool = false, preload:Bool = false):Void {
		var image:String = noteSkin.splashes.image; // change to note type stuff later.

		// it looks like a ship when formatted like this lol -Crow
		var noteSplash:NoteSplash = playField.splashGroup.recycleLoop(NoteSplash) //
			.resetProps(image, noteSkin.splashes.animations, //
				noteSkin.splashes.size, note.dir);
		// *
		noteSplash.antialiasing = members[note.dir].antialiasing;
		noteSplash.alpha = preload ? 0.0000001 : noteSkin.splashes.alpha;
		noteSplash.centerToObject(members[note.dir], XY);
		noteSplash.pop(force);
	}

	public function inputKeyPress(event:KeyboardEvent):Void {
		var key:Int = getKeyFromEvent(event.keyCode);
		if (key == -1 || playField.paused)
			return;

		var currentStrum:Strum = members[key];
		var notesHittable:Array<Note> = playField.noteGroup.members.filter(function(n:Note):Bool {
			return n.parent == this && n.alive && n.data.dir == key && !n.isLate && !n.wasHit && n.canBeHit;
		});
		if (notesHittable.length > 1) // sort through the notes if we can
			notesHittable.sort(sortHitNotes);

		if (currentStrum?.animPlayed != HIT)
			currentStrum.playStrum(PRESS, true);

		if (notesHittable.length == 0) {
			if (!Settings.ghostTapping)
				onNoteMiss.dispatch(key, null);
			return;
		}

		var frontNote:Note = notesHittable[0];
		if (notesHittable.length > 1) {
			var behindNote:Note = notesHittable[1];
			// if the note behind is 2 seconds apart from the front one, invalidate it
			if (Math.abs(behindNote.data.time - frontNote.data.time) < 0.002)
				invalidateNote(behindNote);
			// just in case, if the note behind is actually in FRONT of the supposedly front note, swap them.
			else if (behindNote.data.time < frontNote.data.time)
				frontNote = behindNote;
			// wow that is a dumb check, which surprisingly works -Crow
		}
		onNoteHit.dispatch(frontNote);
		currentStrum.playStrum(HIT, true);
	}

	public function inputKeyRelease(event:KeyboardEvent):Void {
		var key:Int = getKeyFromEvent(event.keyCode);
		if (key == -1 || playField.paused)
			return;
		members[key]?.playStrum(STATIC, true);
	}

	public function getKeyFromEvent(key:FlxKey):Int {
		for (i in 0...controls.length) {
			for (targetKey in Controls.current.myControls.get(controls[i])) {
				var wasPressed:Bool = FlxG.keys.checkStatus(targetKey, JUST_PRESSED);
				var wasReleased:Bool = FlxG.keys.checkStatus(targetKey, JUST_RELEASED);
				if (key == targetKey && (wasPressed || wasReleased))
					return i;
			}
		}
		return -1;
	}

	/**
	 * Function to sort notes based on their time
	 * @return Int
	**/
	inline function sortHitNotes(a:Note, b:Note):Int {
		return Std.int(a.data.time - b.data.time);
	}

	public function invalidateNote(badNote:Note):Void {
		badNote.visible = badNote.active = false;
		badNote.kill();
		playField.noteGroup.remove(badNote, true);
		// badNote.destroy();
	}

	@:dox(hide) @:noCompletion function get_spacing():Int {
		return noteSkin.strums.spacing ?? 160;
	}

	@:dox(hide) @:noCompletion function get_size():Float {
		return noteSkin.strums.size ?? 0.7;
	}

	@:dox(hide) @:noCompletion inline function get_fieldWidth():Float
		return spacing * size;

	@:dox(hide) @:noCompletion function set_globalSpeed(v:Float):Float {
		changeStrumSpeed(v);
		return globalSpeed = v;
	}
}
