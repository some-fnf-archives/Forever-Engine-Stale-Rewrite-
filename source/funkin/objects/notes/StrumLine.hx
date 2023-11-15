package funkin.objects.notes;

import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.input.FlxInput.FlxInputState;
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
	public var globalSpeed(default, set):Float = 1.0;

	// READ ONLY VARIABLES
	public var size(get, never):Float;
	public var spacing(get, never):Int;
	public var fieldWidth(get, never):Float;

	public var onNoteHit:FlxTypedSignal<Note->Void>;
	public var onNoteMiss:FlxTypedSignal<(Int, Note) -> Void>;

	public var controls:Array<String> = ["left", "down", "up", "right"];

	public function new(playField:PlayField, x:Float, y:Float, newSpeed:Float = 1.0, skin:String = "default", cpuControl:Bool = true):Void {
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

	public function regenStrums(skin:String = "default", skipStrumTween:Bool = false):Void {
		this.skin = skin;

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
		else {
			members[strumID].speed = newSpeed;
			globalSpeed = newSpeed;
		}
	}

	public function inputKeyPress(event:KeyboardEvent):Void {
		var key:Int = getKeyFromEvent(event.keyCode);
		if (key == -1 || playField.paused) return;

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
		if (key == -1 || playField.paused) return;
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

	@:dox(hide) @:noCompletion function set_globalSpeed(v:Float):Float {
		changeStrumSpeed(v);
		return globalSpeed = v;
	}
}
