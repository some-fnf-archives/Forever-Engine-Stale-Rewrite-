package funkin.objects;

import flixel.math.FlxPoint;
import forever.core.scripting.HScript;
import forever.display.ForeverSprite;
import haxe.xml.Access;

enum abstract CharacterAnimContext(Int) to Int {
	var IDLE = 0;
	var SING = 1;
	var MISS = 2;

	/** Special Animations prevent the Character from dancing until their current animation is over. **/
	var SPECIAL = 3;
}

/**
 * Character Object used during gameplay.
**/
class Character extends ForeverSprite {
	/** Used to track the character's name **/
	public var name:String = "bf";

	/** Used to declare the character's health icon. **/
	public var icon:String = "bf";

	/** Small data structure for the game over screen. **/
	public var gameOverInfo:Dynamic = {
		character: "bf-dead",
		/** Plays during the game over screen. **/
		loopMusic: "gameOver",
		/** Plays after hitting the confirm key on the game over screen. **/
		confirmSound: "gameOverEnd",
		/** Plays when entering the game over screen**/
		startSfx: "fnf_loss_sfx",
		/** deathLifter the sfx, and slightly delays the music, Used in week7 **/
		deathLines: "tank/jeffGameover-{1...25}"
	};

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
	public var animationContext:Int = IDLE;

	public var characterScript:HScript = null;

	@:dox(hide) public var holdTmr:Float = 0.0;

	@:dox(hide) private var _curDanceStep:Int = 0;
	@:dox(hide) private var _isPlayer:Bool = false;

	public function new(?x:Float = 0, ?y:Float = 0, ?character:String = null, player:Bool = false):Void {
		super(x, y);
		this._isPlayer = player;
		if (character != null)
			loadCharacter(character);
	}

	override function destroy():Void {
		if (characterScript != null)
			characterScript.call("destroy", []);
		cameraDisplace?.put();
		positionDisplace?.put();
		super.destroy();
	}

	public function loadCharacter(character:String):Character {
		this.name = character;

		var implementation:EngineImpl = FOREVER;
		var file:Dynamic = null;

		if (Tools.fileExists(AssetHelper.getPath('data/characters/${name}.json'))) {
			file = AssetHelper.parseAsset('data/characters/${name}', JSON);
			var crowChar:Bool = Reflect.hasField(file, "singList");
			implementation = crowChar ? CROW : PSYCH;
		}

		switch (character) {
			default:
				try
					parseFromImpl(file, implementation)
				catch (e:haxe.Exception) {
					// trace('[Character:loadCharacter]: Failed to parse "${implementation.toString()}" type character of name "${name}"\n\nError: ${e.details()}');
				}
		}

		if (Tools.fileExists(AssetHelper.getAsset('data/characters/${name}', HSCRIPT))) {
			characterScript = new HScript(AssetHelper.getAsset('data/characters/${name}', HSCRIPT));
			characterScript.set('char', this);
			@:privateAccess characterScript.set('isPlayer', this._isPlayer);
			characterScript.call('generate', []);
			cast(FlxG.state, funkin.states.base.FNFState).appendToScriptPack(characterScript);
		}

		if (_isPlayer)
			flipX = !flipX;

		x += positionDisplace.x;
		y += positionDisplace.y;

		dance(true);

		return this;
	}

	override function update(elapsed:Float):Void {
		updateAnimation(elapsed);
		if (animation.curAnim != null) {
			if (animationContext == SING)
				holdTmr += elapsed;
			else if (_isPlayer)
				holdTmr = 0.0;
			final stepDt:Float = (Conductor.crochet * 4.0);
			if (holdTmr >= ((stepDt * 1000.0) * Conductor.rate) * singDuration * 0.0001) {
				dance();
				holdTmr = 0.0;
			}
		}
	}

	public function dance(forced:Bool = false):Void {
		if (animationContext == SPECIAL)
			return;
		playAnim(dancingSteps[_curDanceStep], forced);
		if (animationContext != IDLE) // same here
			animationContext = IDLE;
		_curDanceStep += 1;
		if (_curDanceStep > dancingSteps.length - 1)
			_curDanceStep = 0;
	}

	override function playAnim(name:String, ?forced:Bool = false, ?reversed:Bool = false, ?frame:Int = 0):Void {
		if (characterScript != null)
			characterScript.call("playAnim", [name, forced, reversed, frame]);

		if (singingSteps.contains(name) && animationContext != SING) //  && animationContext != SING isnt needed
			animationContext = SING;

		super.playAnim(name, forced, reversed, frame);

		if (characterScript != null)
			characterScript.call("postPlayAnim", [name, forced, reversed, frame]);
	}

	@:noPrivateAccess
	private function parseFromImpl(file:Dynamic, impl:EngineImpl):Void {
		function setScale(newScale:FlxPoint):Void {
			if (newScale != null) {
				var oldScale:FlxPoint = this.scale;
				if (newScale != oldScale) {
					scale.set(newScale.x, newScale.y);
					updateHitbox();
				}
			}
		}
		switch (impl) {
			case FOREVER:
				var data = AssetHelper.parseAsset('data/characters/${name}.yaml', YAML);
				if (data == null)
					return
						trace('[Character:parseFromImpl()]: Character ${name} could not be parsed due to a inexistent file, Please provide a file called "${name}.yaml" in the "data/characters directory.');

				// automatically searches for packer and sparrow
				frames = AssetHelper.getAsset('images/characters/${data.spritesheet}', ATLAS);

				var animations:Array<Dynamic> = data.animations ?? [];
				if (animations.length > 0) {
					for (i in animations) {
						addAtlasAnim(i.name, i.prefix, i.fps ?? 24, i.loop ?? false, cast(i.indices ?? []));
						if (i.x != null)
							setOffset(i.name, i.x, i.y);
					}
				}
				else
					addAtlasAnim("idle", "BF idle dance", 24, false, []);

				positionDisplace.set(data.positionDisplace?.x ?? 0.0, data.positionDisplace?.y ?? 0.0);
				cameraDisplace.set(data.cameraDisplace?.x ?? 0.0, data.cameraDisplace?.y ?? 0.0);

				flipX = data.flip?.x ?? false;
				flipY = data.flip?.y ?? false;

				if (data.scale != null)
					setScale(FlxPoint.get(data.scale.x ?? 1.0, data.scale.y ?? 1.0));

				dancingSteps = data.dancingSteps ?? dancingSteps;
				singingSteps = data.singingSteps ?? singingSteps;

				singDuration = data.singDuration ?? 4.0;
				danceInterval = data.danceInterval ?? 2;
				icon = data.icon;

			case PSYCH:
				frames = AssetHelper.getAsset('images/characters/${name}', ATLAS);

				var psychAnimArray:Array<Dynamic> = file.animations;
				for (anim in psychAnimArray) {
					addAtlasAnim(anim.anim, anim.name, anim.fps, anim.anim.loop, anim.indices);
					setOffset(anim.anim, anim.offsets[0], anim.offsets[1]);
				}

				final globalOffset:Array<Float> = cast(file.position) ?? [0, 0];
				final globalCamOffset:Array<Float> = cast(file.camera_position) ?? [0, 0];

				positionDisplace.set(globalOffset[0], globalOffset[1]);
				cameraDisplace.set(globalCamOffset[0], globalCamOffset[1]);

				icon = file.healthicon;
				flipX = file.flip_x ?? false;
				if (file.scale != null)
					setScale(FlxPoint.get(file.scale.x ?? 1.0, file.scale.y ?? 1.0));
				singDuration = file.sing_duration ?? 4;

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

				icon = name;

				dancingSteps = file.idleList ?? dancingSteps;
				singingSteps = file.singList ?? singingSteps;

				if (file.scale != null)
					setScale(FlxPoint.get(file.scale.x ?? 1.0, file.scale.y ?? 1.0));

			default:
				trace('[Character:parseFromImpl()]: Missing character parsing for "${impl.toString()}" on character $name.');
		}
	}
}
