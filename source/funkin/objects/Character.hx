package funkin.objects;

#if SCRIPTING
import forever.data.ForeverScript;
#end
import flixel.math.FlxPoint;
import forever.display.ForeverSprite;

enum abstract CharAnimationState(Int) to Int {
	var IDLE = 0;
	var SING = 1;
	var MISS = 2;
}

/**
 * Character Object used during gameplay.
**/
class Character extends ForeverSprite {
	/** Used to track the character's name **/
	public var name:String = "bf";

	/** Dance Steps, used to track which animations to play when calling `dance()` on a character. **/
	public var dancingSteps:Array<String> = ["idle"];

	/**
	 * Sing Steps, used to know which animations to use when singing
	 * this is note based, so LEFT note would be the first animation of the array, and so on...
	**/
	public var singingSteps:Array<String> = ["singLEFT", "singDOWN", "singUP", "singRIGHT"];

	/**
	 * Character offset in-game, doesn't affect the main offsets of the animations
	 * and simply acts as a global offset.
	**/
	public var positionDisplace:FlxPoint = FlxPoint.get(0, 0);

	/** Character camera offset, acts lie `positionDisplace`, but for the camera. **/
	public var cameraDisplace:FlxPoint = FlxPoint.get(0, 0);

	/** The sing duration time, makes the character idle after reaching 0. **/
	public var singDuration:Float = 4.0;

	/** The beat interval a character takes to headbop. **/
	public var danceInterval:Int = 2;

	/** Which animation state the character is currently at. **/
	public var animationState:Int = IDLE;

	public var characterScript:ForeverScript = null;

	@:dox(hide) public var holdTmr:Float = 0.0;

	@:dox(hide) private var _curDanceStep:Int = 0;
	@:dox(hide) private var _isPlayer:Bool = false;

	public function new(?x:Float = 0, ?y:Float = 0, ?character:String = null, player:Bool = false):Void {
		super(x, y);
		this._isPlayer = player;

		if (character != null)
			loadCharacter(character);
	}

	public override function destroy():Void {
		if (characterScript != null)
			characterScript.call("destroy", []);

		positionDisplace.put();
		cameraDisplace.put();
		super.destroy();
	}

	public function loadCharacter(character:String):Character {
		this.name = character;

		var implementation:String = FOREVER;
		var file:Dynamic = null;

		if (Tools.fileExists(AssetHelper.getPath('data/characters/${name}.json'))) {
			file = AssetHelper.getAsset('data/characters/${name}', JSON);
			var crowChar:Bool = Reflect.hasField(file, "singList");
			implementation = crowChar ? CROW : PSYCH;
		}

		switch (character) {
			default:
				try
					parseFromImpl(file, implementation)
				catch (e:haxe.Exception)
					trace('[Character:loadCharacter]: Failed to parse "${implementation}" type character\n\nError: ${e.details()}');
		}

		if (_isPlayer)
			flipX = !flipX;

		x += positionDisplace.x;
		y += positionDisplace.y;

		dance();

		return this;
	}

	public override function update(elapsed:Float):Void {
		if (characterScript != null)
			characterScript.set("update", [elapsed]);
		updateAnimation(elapsed);
		if (animation.curAnim != null) {
			if (animationState == SING)
				holdTmr += elapsed;
			else {
				if (_isPlayer)
					holdTmr = 0.0;
			}

			var stepDt:Float = ((60.0 / Conductor.bpm) * 4.0);
			if (holdTmr >= (stepDt * 1000.0) * singDuration * 0.0001) {
				dance();
				holdTmr = 0.0;
			}
		}
		if (characterScript != null)
			characterScript.call("updatePost", [elapsed]);
	}

	public function dance(forced:Bool = false):Void {
		playAnim(dancingSteps[_curDanceStep], forced);
		if (animationState != IDLE)
			animationState = IDLE;

		_curDanceStep += 1;
		if (_curDanceStep > dancingSteps.length - 1)
			_curDanceStep = 0;
	}

	public override function playAnim(name:String, ?forced:Bool = false, ?reversed:Bool = false, ?frame:Int = 0):Void {
		super.playAnim(name, forced, reversed, frame);

		if (singingSteps.contains(name) && animationState != SING)
			animationState = SING;
	}

	@:noPrivateAccess
	private function parseFromImpl(file:Dynamic, impl:String):Void {
		switch (impl) {
			case FOREVER:
				var script:ForeverScript = new ForeverScript(AssetHelper.getAsset('data/characters/${name}', HSCRIPT));
				script.set('char', this);
				@:privateAccess script.set('isPlayer', this._isPlayer);
				script.call('generate', []);

			case PSYCH:
				var charImage:String = file?.image ?? 'characters/${name}';
				frames = AssetHelper.getAsset('images/${charImage}', ATLAS);

				var psychAnimArray:Array<Dynamic> = file.animations;
				for (anim in psychAnimArray) {
					addAtlasAnim(anim.anim, anim.name, anim.fps, anim.anim.loop, anim.indices);
					setOffset(anim.anim, anim.offsets[0], anim.offsets[1]);
				}

				var globalOffset:Array<Dynamic> = file.position ?? [0, 0];
				var globalCamOffset:Array<Dynamic> = file.camera_position ?? [0, 0];

				positionDisplace = FlxPoint.get(Std.parseFloat(globalOffset[0]), Std.parseFloat(globalOffset[1]));
				cameraDisplace = FlxPoint.get(Std.parseFloat(globalCamOffset[0]), Std.parseFloat(globalCamOffset[1]));

				flipX = file.flip_x ?? false;
				scale.set(file.scale ?? 1.0, file.scale ?? 1.0);
				updateHitbox();

				if (animation.exists("danceLeft") && animation.exists("danceRight")) {
					dancingSteps = ["danceLeft", "danceRight"];
					danceInterval = 1;
				}

			case CROW:
				frames = AssetHelper.getAsset('images/characters/${name}/${name}', ATLAS);

				var crowAnimList:Array<Dynamic> = file.animationList;
				for (animData in crowAnimList) {
					addAtlasAnim(animData.name, animData.prefix, animData.fps, animData.looped, animData.indices);
					setOffset(animData.name, animData.offset.x, animData.offset.y);
				}

				flipX = file.flip?.x ?? false;
				flipY = file.flip?.y ?? false;

				dancingSteps = file.idleList ?? dancingSteps;
				singingSteps = file.singList ?? singingSteps;

				scale.set(file.scale?.x ?? 1.0, file.scale?.y ?? 1.0);
				updateHitbox();
		}

		// trace('parsed "${name}" character, origin: "${impl}"');
	}
}
