package funkin.objects;

import flixel.math.FlxPoint;
import forever.ForeverSprite;

/**
 * Character Object used during gameplay.
**/
class Character extends ForeverSprite {
	/** Used to track the character's name **/
	public var name:String = "bf";

	/**
	 * Dance Steps, used to track which animations to play when calling `dance()`
	 * on a character.
	**/
	public var dancingSteps:Array<String> = ["idle"];

	/**
	 * Sing Steps, used to know which animations to use when singing
	 * this is note based, so LEFT note would be the first animation of the array, and so on...
	**/
	public var singingStepss:Array<String> = ["singLEFT", "singDOWN", "singUP", "singRIGHT"];

	/**
	 * Character Displacement in-game, doesn't affect the main offsets of the animations
	 * and simply acts as a global offset.
	**/
	public var positionDisplace:FlxPoint = FlxPoint.get(0, 0);

	/**
	 * Character Camera Displacement, acts lie `positionDisplace`, but for the camera.
	**/
	public var cameraDisplace:FlxPoint = FlxPoint.get(0, 0);

    /** The Beat Interval a character takes to headbop. **/
    public var danceInterval:Int = 2;

	private var _curDanceStep:Int = 0;
	private var _isPlayer:Bool = false;

	public function new(?x:Float = 0, ?y:Float = 0, player:Bool = false):Void {
		super(x, y);

		this._isPlayer = player;
	}

	public function loadCharacter(character:String):Void {
		this.name = character;

		var implementation:String = PSYCH;

		switch (implementation) {
			case FOREVER:
			case PSYCH:
				var psychJson:Dynamic = AssetHelper.getAsset('data/characters/${name}/${name}', JSON);
				var charImage:String = Reflect.field(psychJson, "image");
				var globalOffset:Array<Float> = Reflect.field(psychJson, "position");
				var globalCamOffset:Array<Float> = Reflect.field(psychJson, "camera_position");

				frames = AssetHelper.getAsset('images/${charImage}', ATLAS_SPARROW);

				positionDisplace = FlxPoint.get(globalOffset[0], globalOffset[1]);
				cameraDisplace = FlxPoint.get(globalCamOffset[1], globalCamOffset[2]);
				flipX = Reflect.field(psychJson, "flip_x");

				var animations:Array<Dynamic> = Reflect.field(psychJson, "animations");
				for (anim in animations) {
					var name:String = Reflect.field(anim, "anim");
					var prefix:String = Reflect.field(anim, "name");
					var fps:Int = Reflect.field(anim, "fps");
					var loop:Bool = Reflect.field(anim, "loop");
					var indices:Array<Int> = Reflect.field(anim, "indices");
					var offset:Array<Float> = Reflect.field(anim, "offsets");

					addAtlasAnim(name, prefix, fps, loop, indices);
					setOffset(name, offset[0], offset[1]);
				}

				if (animation.exists("danceLeft") && animation.exists("danceRight")) {
					dancingSteps = ["danceLeft", "danceRight"];
                    danceInterval = 1;
                }
		}

		dance(true);
	}

	public function dance(forced:Bool = false):Void {
		playAnim(dancingSteps[_curDanceStep], forced);

		_curDanceStep += 1;
		if (_curDanceStep > dancingSteps.length - 1)
			_curDanceStep = 0;
	}
}
