package funkin.objects.notes;

import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.util.FlxSignal.FlxTypedSignal;
import flixel.util.FlxSort;
import forever.ForeverSprite;
import haxe.ds.IntMap;
import haxe.ds.StringMap;
import openfl.events.KeyboardEvent;

enum abstract StrumAnimationType(Int) to Int {
	var STATIC = 0;
	var PRESS = 1;
	var HIT = 2;
}

class Strum extends ForeverSprite {
	public var speed:Float = 1.0;
	public var animations:IntMap<String> = new IntMap<String>();
	public var animPlayed:Int = -1;

	public function new(x:Float, y:Float, skin:String = "default", id:Int):Void {
		super(x, y);

		frames = AssetHelper.getAsset('images/notes/${NoteConfig.config.strums.image}', ATLAS_SPARROW);
		this.ID = id;

		if (NoteConfig.config.strums.anims.length > 0) {
			for (i in NoteConfig.config.strums.anims) {
				var dir:String = Utils.NOTE_DIRECTIONS[id];
				var color:String = Utils.NOTE_COLORS[id];

				addAtlasAnim(i.name, i.prefix.replace("${dir}", dir).replace("${color}", color), i.fps, i.looped);
				if (i.type != null)
					animations.set(i.type, i.name);
			}
		}

		playStrum(STATIC, true);
	}

	public function playStrum(type:Int, forced:Bool = false, reversed:Bool = false, frame:Int = 0):Void {
		playAnim(animations.get(type), forced, reversed, frame);
		centerOrigin();
		centerOffsets();
		animPlayed = type;
	}
}

class NoteField extends FlxTypedGroup<Strum> {
	public var skin:String;
	public var playField:PlayField;
	public var cpuControl:Bool;

	// READ ONLY VARIABLES
	public var size(get, never):Float;
	public var spacing(get, never):Int;
	public var fieldWidth(get, never):Float;

	public var onNoteHit:FlxTypedSignal<Note->Void>;
	public var onNoteMiss:FlxTypedSignal<(Int, Note) -> Void>;

	public function new(playField:PlayField, x:Float, y:Float, skin:String = "default", cpuControl:Bool = true):Void {
		super();

		this.skin = skin;
		this.cpuControl = cpuControl;
		this.playField = playField;

		onNoteHit = new FlxTypedSignal<Note->Void>();
		onNoteMiss = new FlxTypedSignal<(Int, Note) -> Void>();

		if (!cpuControl) {
			FlxG.stage.addEventListener(openfl.events.KeyboardEvent.KEY_DOWN, inputKeyPress);
			FlxG.stage.addEventListener(openfl.events.KeyboardEvent.KEY_UP, inputKeyRelease);
		}

		regenStrums(x, y);
	}

	public override function destroy():Void {
		if (!cpuControl) {
			FlxG.stage.removeEventListener(openfl.events.KeyboardEvent.KEY_DOWN, inputKeyPress);
			FlxG.stage.removeEventListener(openfl.events.KeyboardEvent.KEY_UP, inputKeyRelease);
		}
		super.destroy();
	}

	public function regenStrums(x:Float = 0, y:Float = 0):Void {
		for (i in 0...4) {
			var strum:Strum = new Strum(x, y, skin, i);
			strum.x += i * fieldWidth;
			strum.scale.set(size, size);
			strum.updateHitbox();
			add(strum);
		}
	}

	public function changeStrumSpeed(newSpeed:Float, strumID:Int = -1):Void {
		if (strumID == -1 || strumID > members.indexOf(members.last())) {
			for (i in 0...members.length)
				if (Std.isOfType(members[i], Strum))
					members[i].speed = newSpeed;
		}
		else
			members[strumID].speed = newSpeed;
	}

	public function inputKeyPress(event:KeyboardEvent):Void {
		var key:Int = getKeyFromEvent(event.keyCode);
		if (playField == null || key < 0 || cpuControl)
			return;

		var currentStrum:Strum = members[key];

		var notesHittable:Array<Note> = playField.noteSpawner.members.filter(function(n:Note) {
			return n.parent == this && n.alive && n.data.direction == key && !n.isLate && !n.wasHit && n.canBeHit;
		});
		notesHittable.sort(sortHitNotes);

		if (notesHittable.length > 0) {
			var frontNote:Note = notesHittable[0];

			if (notesHittable.length > 1) {
				var behindNote:Note = notesHittable[1];
				// calculate jacks in milliseconds -- TODO: find a better calculation that uses seconds instead
				final msF:Float = frontNote.data.time * 1000.0;
				final msB:Float = behindNote.data.time * 1000.0;

				if (Math.abs(msB - msF) < 1.0)
					invalidateNote(behindNote);
				else if (msB < msF)
					frontNote = behindNote;
			}

			onNoteHit.dispatch(frontNote);
			currentStrum?.playStrum(HIT, true);
		}
		else {
			if (!Settings.ghostTapping)
				onNoteMiss.dispatch(key, null);
		}

		if (currentStrum?.animPlayed != HIT)
			currentStrum?.playStrum(PRESS, true);
	}

	public function inputKeyRelease(event:KeyboardEvent):Void {
		var key:Int = getKeyFromEvent(event.keyCode);
		if (playField == null || key < 0 || cpuControl)
			return;

		members[key]?.playStrum(STATIC, true);
	}

	public function getKeyFromEvent(key:FlxKey):Int {
		if (key == NONE)
			return -1;

		final controls:Array<String> = ["left", "down", "up", "right"];

		for (i in 0...controls.length) {
			var kys:Array<FlxKey> = Controls.current.myControls.get(controls[i]);
			var press:Bool = Controls.current.justPressed(controls[i]);
			var release:Bool = Controls.current.justReleased(controls[i]);

			for (_key in kys) {
				if (key == _key && (press || release))
					return i;
			}
		}

		return -1;
	}

	/**
	 * Function to sort notes that can
	 * @author ShadowMario [https://github.com/ShadowMario/FNF-PsychEngine/blob/5d0a66dea226aa4a32ec5c41f113112ebb15e692/source/states/PlayState.hx#L2664]
	 * @return Int
	**/
	private function sortHitNotes(a:Note, b:Note):Int {
		if (a.lowPriority && !b.lowPriority)
			return 1;
		else if (!a.lowPriority && b.lowPriority)
			return -1;

		return FlxSort.byValues(FlxSort.ASCENDING, a.data.time, b.data.time);
	}

	public function invalidateNote(badNote:Note):Void {
		badNote.visible = badNote.active = false;
		badNote.kill();
		playField.noteSpawner.remove(badNote, true);
		// badNote.destroy();
	}

	@:dox(hide) @:noCompletion function get_spacing():Int {
		if (NoteConfig.config.strums.spacing >= 30) // minimum spacing is 30
			return NoteConfig.config.strums.spacing;
		return NoteConfig.getDummyConfig().strums.spacing;
	}

	@:dox(hide) @:noCompletion function get_size():Float {
		if (NoteConfig.config.strums.size > 0)
			return NoteConfig.config.strums.size;
		return NoteConfig.getDummyConfig().strums.size;
	}

	@:dox(hide) @:noCompletion function get_fieldWidth():Float
		return spacing * size;
}
