package funkin.objects.notes;

import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.input.keyboard.FlxKey;
import flixel.util.FlxSignal.FlxTypedSignal;
import flixel.util.FlxSort;
import forever.display.ForeverSprite;
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

	// todo: make a better splash system that doesn't suck ass -Crow
	public var splash:ForeverSprite = null;

	public function new(x:Float, y:Float, skin:String = "default", id:Int):Void {
		super(x, y);

		frames = AssetHelper.getAsset('images/notes/${NoteConfig.config.strums.image}', ATLAS_SPARROW);
		this.ID = id;

		if (NoteConfig.config.strums.anims.length > 0) {
			for (i in NoteConfig.config.strums.anims) {
				var dir:String = Tools.NOTE_DIRECTIONS[id];
				var color:String = Tools.NOTE_COLORS[id];

				addAtlasAnim(i.name, i.prefix.replace("${dir}", dir).replace("${color}", color), i.fps, i.looped);
				if (i.type != null)
					animations.set(i.type, i.name);
			}
		}

		playStrum(STATIC, true);
	}

	override function update(elapsed:Float):Void {
		super.update(elapsed * timeScale);
		if (splash != null && splash.alive)
			splash.update(elapsed * timeScale);
	}

	public function playStrum(type:Int, forced:Bool = false, reversed:Bool = false, frame:Int = 0):Void {
		playAnim(animations.get(type), forced, reversed, frame);
		centerOrigin();
		centerOffsets();
		animPlayed = type;
	}

	public function doNoteSplash(note:Note = null, cache:Bool = false):Void {
		if (splash == null) {
			splash = new ForeverSprite();
			splash.frames = Paths.getSparrowAtlas('notes/${NoteConfig.config.splashes.image}');

			for (i in NoteConfig.config.splashes.anims) {
				var dir:String = Tools.NOTE_DIRECTIONS[ID];
				var color:String = Tools.NOTE_COLORS[ID];

				splash.addAtlasAnim(i.name, i.prefix.replace("${dir}", dir).replace("${color}", color), i.fps, i.looped);
				/*
					if (i.type != null)
						splash.animations.set(i.type, i.name);
				 */
			}

			splash.centerToObject(this, XY);
			splash.scale.set(NoteConfig.config.splashes.size, NoteConfig.config.splashes.size);
			splash.updateHitbox();

			splash.animation.finishCallback = function(anim:String):Void splash.kill();
		}

		splash.revive();
		splash.alpha = cache ? 0.000001 : NoteConfig.config.splashes.alpha;
		splash.playAnim('${FlxG.random.int(1, 2)}', true);
	}

	override function draw():Void {
		super.draw();
		if (splash != null && splash.alive)
			splash.draw();
	}
}

class StrumLine extends FlxTypedSpriteGroup<Strum> {
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

	override function update(elapsed:Float):Void {
		if (cpuControl) {
			for (i in 0...members.length) // this here? this is dumb, dumb as hell -Crow
				if (members[i].animPlayed == HIT && members[i].animation.finished)
					members[i].playStrum(STATIC, true);
		}
		super.update(elapsed);
	}

	override function destroy():Void {
		if (!cpuControl) {
			FlxG.stage.removeEventListener(openfl.events.KeyboardEvent.KEY_DOWN, inputKeyPress);
			FlxG.stage.removeEventListener(openfl.events.KeyboardEvent.KEY_UP, inputKeyRelease);
		}
		super.destroy();
	}

	public function regenStrums(x:Float = 0, y:Float = 0, skipStrumTween:Bool = false):Void {
		this.x = x;
		this.y = y;

		while (members.length > 0)
			members.pop().destroy();

		// bro think they psych engine
		var targetAlpha:Float = (Settings.centerStrums && cpuControl) ? 0.6 : 0.8; // pair with original FE

		for (i in 0...4) {
			final strum:Strum = new Strum(0, 0, skin, i);
			strum.x += i * fieldWidth;
			strum.scale.set(size, size);
			strum.updateHitbox();
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
		else
			members[strumID].speed = newSpeed;
	}

	public function inputKeyPress(event:KeyboardEvent):Void {
		var key:Int = getKeyFromEvent(event.keyCode);
		if (playField == null || (playField != null && playField.paused) || key < 0 || cpuControl)
			return;

		var currentStrum:Strum = members[key];

		var notesHittable:Array<Note> = playField.noteGroup.members.filter(function(n:Note) {
			return n.parent == this && n.alive && n.data.dir == key && !n.isLate && !n.wasHit && n.canBeHit;
		});

		if (notesHittable.length != 0) {
			var frontNote:Note = notesHittable[0];

			if (notesHittable.length > 1) {
				// sort through the notes
				notesHittable.sort(sortHitNotes);

				var behindNote:Note = notesHittable[1];
				// if the note behind is 5 seconds apart from the front one, invalidate it
				if (Math.abs(behindNote.data.time - frontNote.data.time) < 0.005)
					invalidateNote(behindNote);
				// just in case, if the note behind is actually in FRONT of the supposedly front note, swap them.
				else if (behindNote.data.time < frontNote.data.time)
					frontNote = behindNote;
				// wow that is a dumb check, which surprisingly works -Crow
			}

			onNoteHit.dispatch(frontNote);
			currentStrum.playStrum(HIT, true);
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
		if (playField == null || (playField != null && playField.paused) || key < 0 || cpuControl)
			return;
		members[key]?.playStrum(STATIC, true);
	}

	public inline function getKeyFromEvent(key:FlxKey):Int {
		var key:Int = -1;
		if (key == NONE)
			return key;

		final controls:Array<String> = ["left", "down", "up", "right"];

		for (i in 0...controls.length) {
			var kys:Array<FlxKey> = Controls.current.myControls.get(controls[i]);
			var press:Bool = Controls.current.justPressed(controls[i]);
			var release:Bool = Controls.current.justReleased(controls[i]);

			for (_key in kys)
				if (key == _key && (press || release)) {
					key = i;
					break;
				}
		}

		return key;
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
		if (NoteConfig.config.strums.spacing >= 30) // minimum spacing is 30
			return NoteConfig.config.strums.spacing;
		return NoteConfig.getDummyConfig().strums.spacing;
	}

	@:dox(hide) @:noCompletion function get_size():Float {
		if (NoteConfig.config.strums.size > 0)
			return NoteConfig.config.strums.size;
		return NoteConfig.getDummyConfig().strums.size;
	}

	@:dox(hide) @:noCompletion inline function get_fieldWidth():Float
		return spacing * size;
}
