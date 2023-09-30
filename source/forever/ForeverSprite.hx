package forever;

import flixel.FlxSprite;
import flixel.tweens.FlxTween;
import forever.config.Settings;

typedef SpriteOptions = {
	/** Sprite Alpha. **/
	@:optional var alpha:Float;

	/** Sprite Color. **/
	@:optional var color:FlxColor;

	/** Sprite Size. **/
	@:optional var scale:{x:Float, y:Float};
}

/**
 * Global Sprite tools
**/
class ForeverSprite extends FlxSprite {
	public function new(?x:Float, ?y:Float):Void {
		super(x, y);
		antialiasing = Settings.globalAntialias;
	}

	/**
	 * Loads a Graphic with the given set of properties.
	 *
	 * @param graphic		the Name of the Graphic (will be searched for in `assets/images`).
	 * @param properties	the Properties to modify for this graphic, refer to `SpriteOptions` in `ForeverSprite.hx`.
	**/
	public function addGraphic(graphic:String, ?properties:SpriteOptions):ForeverSprite {
		loadGraphic(AssetHelper.getAsset('images/$graphic', IMAGE));
		return this;
	}

	/**
	 * Adds an animation from a sparrow/packer atlas file to this sprite.
	 *
	 * @param name                  name of the animation.
	 * @param prefix                prefix of the animation on your sparrow atlas file.
	 * @param frameRate             the framerate for the animation, defaults to 24.
	 * @param looped                whether the animation loops.
	 * @param indices               array with animation indices, if unspecified, the animation gets added as a prefix animation only.
	**/
	public function addAtlasAnim(name:String, prefix:String, frameRate:Int = 24, looped:Bool = false, ?indices:Array<Int>):Void {
		if (indices != null)
			animation.addByIndices(name, prefix, indices, "", frameRate, looped);
		else
			animation.addByPrefix(name, prefix, frameRate, looped);
	}

	//////////////
	// TWEENING //
	//////////////

	/**
	 * Tweens the sprite with any given values,
	 * shortcut to `FlxTween.tween(...)`.
	 *
	 * @param values		Dynamic table of values to tween, e.g: `{alpha: 0.5, color: FlxColor.RED}`.
	 * @param duration		The duration of the tween.
	 * @param options		The tween options, such as delay, type, easing, and callbacks.
	**/
	public function tween(values:Dynamic, duration:Float, ?options:TweenOptions):Void {
		FlxTween.tween(this, values, duration, options);
	}

	/**
	 * Tweens the sprite's color to any given value,
	 * shortcut to `FlxTween.color(...)`
	 *
	 * @param toColor		Which color should it tween to.
	 * @param fromColor		Which color should it begin to tween from.
	 * @param duration		The duration of the tween.
	 * @param options		The tween options, such as delay, type, easing, and callbacks.
	**/
	public function colorTween(toColor:FlxColor, ?fromColor:FlxColor, duration:Float, ?options:TweenOptions):Void {
		if (fromColor == null)
			fromColor = this.color;

		FlxTween.color(this, duration, fromColor, toColor, options);
	}

	/**
	 * Tweens the sprite to any given angle value,
	 * shortcut to `FlxTween.angle(...)`.
	 *
	 * @param x				The X angle the sprite should tween to.
	 * @param y				The Y angle the sprite should tween to.
	 * @param duration		The duration of the tween.
	 * @param options		The tween options, such as delay, type, easing, and callbacks.
	**/
	public function angleTween(x:Float = 0, y:Float = 0, duration:Float, ?options:TweenOptions):Void {
		FlxTween.angle(this, x, y, duration, options);
	}

	/**
	 * Stops every tween from the current sprite,
	 * shortcut to `FlxTween.cancelTweensOf(...)`.
	 *
	 * @param fieldPaths	Optional list of the tween field paths to search for.
	**/
	public function stopTweens(?fieldPaths:Array<String>):Void {
		FlxTween.cancelTweensOf(this, fieldPaths);
	}
}
