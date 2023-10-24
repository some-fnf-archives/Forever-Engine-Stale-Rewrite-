package forever.display;

import flixel.FlxSprite;
import flixel.tweens.FlxTween;
import forever.Settings;
import openfl.text.TextFormatAlign;

/**
 * Global Sprite tools
**/
class ForeverSprite extends FlxSprite {
	/**
	 * Animation Offset Map
	**/
	public var animOffsets:haxe.ds.StringMap<Array<Float>> = new haxe.ds.StringMap();

	/**
	 * Creates a new Forever Sprite.
	 * @param x				The initial X Position of the Sprite.
	 * @param y				The initial Y Position of the Sprite.
	 * @param graphic		The name of the graphic (will be searched for in `assets/images`).
	 * @param properties	The properties to modify for this graphic, options: alpha, color, "scale.x", "scale.y".
	**/
	public function new(?x:Float = 0, ?y:Float = 0, ?graphic:String, ?properties:Dynamic):Void {
		super(x, y);

		antialiasing = Settings.globalAntialias;
		if (graphic != null)
			addGraphic(graphic, properties);
	}

	/**
	 * Loads a Graphic with the given set of properties.
	 * @param graphic		The name of the graphic (will be searched for in `assets/images`).
	 * @param properties	The properties to modify for this graphic, options: alpha, color, "scale.x", "scale.y".
	**/
	public function addGraphic(graphic:String, ?properties:Dynamic):ForeverSprite {
		loadGraphic(AssetHelper.getAsset('${graphic}', IMAGE));

		if (properties != null) {
			Tools.safeReflection(this.alpha, properties, "alpha");
			Tools.safeReflection(this.color, properties, "color");
			Tools.safeReflection(this.color, properties, "colour"); // british
			Tools.safeReflection(this.scale.x, properties, "scale.x");
			Tools.safeReflection(this.scale.y, properties, "scale.y");

			Tools.safeReflection(this.scrollFactor.x, properties, "scroll.x");
			Tools.safeReflection(this.scrollFactor.y, properties, "scroll.y");
		}

		return this;
	}

	/**
	 * Adds an animation from a sparrow/packer atlas file to this sprite.
	 * @param name                  Name of the animation.
	 * @param prefix                Prefix of the animation on your sparrow atlas file.
	 * @param frameRate             The framerate for the animation, defaults to 24.
	 * @param looped                Whether the animation loops.
	 * @param indices               Array with animation indices, if unspecified, the animation gets added as a prefix animation only.
	**/
	public function addAtlasAnim(name:String, prefix:String, frameRate:Float = 24.0, looped:Bool = false, ?indices:Array<Int>):Void {
		if (indices != null && indices.length > 0)
			animation.addByIndices(name, prefix, indices, "", frameRate, looped);
		else
			animation.addByPrefix(name, prefix, frameRate, looped);
	}

	/**
	 * Plays an animation in the current sprite, while also offsetting it.
	 * @param name			The name of the animation to play.
	 * @param forced		Will force the animation to play, interrupting existing ones and resetting the frame.
	 * @param reversed		Will play the animation backwards.
	 * @param frame			Defines the starting frame of the animation.
	**/
	public function playAnim(name:String, ?forced:Bool = false, ?reversed:Bool = false, ?frame:Int = 0):Void {
		animation.play(name, forced, reversed, frame);
		var offsets:Array<Float> = animOffsets.exists(name) ? animOffsets.get(name) : [0.0, 0.0];
		frameOffset.set(offsets[0], offsets[1]);
	}

	/**
	 * Sets the offset of an animation.
	 * @param name			The name of the animation.
	 * @param x				The X coordinate of the offset.
	 * @param y				The Y coordinate of the offset.
	**/
	public function setOffset(name:String, ?x:Null<Float> = 0, ?y:Null<Float> = 0):Void {
		animOffsets.set(name, [x ?? 0.0, y ?? 0.0]);
	}

	// -- TWEENING -- //

	/**
	 * Tweens the sprite with any given values,
	 * shortcut to `FlxTween.tween(...)`.
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
	 * @param toColor		Which color should it tween to.
	 * @param fromColor		Which color should it begin to tween from.
	 * @param duration		The duration of the tween.
	 * @param options		The tween options, such as delay, type, easing, and callbacks.
	**/
	public function colorTween(toColor:FlxColor, duration:Float, ?options:TweenOptions):Void {
		FlxTween.color(this, duration, this.color, toColor, options);
	}

	/**
	 * Tweens the sprite to any given angle value,
	 * shortcut to `FlxTween.angle(...)`.
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
	 * @param fieldPaths	Optional list of the tween field paths to search for.
	**/
	public function stopTweens(?fieldPaths:Array<String>):Void {
		FlxTween.cancelTweensOf(this, fieldPaths);
	}
}

class ChildSprite extends ForeverSprite {
	/** This sprite's parent. **/
	public var parent:FlxSprite;

	/** This sprite's alignment. **/
	public var align:TextFormatAlign = RIGHT;

	public override function update(elapsed:Float):Void {
		super.update(elapsed);

		if (parent != null) {
			switch (align) {
				case LEFT:
					setPosition(parent.x - 80, parent.y - 30);
				case CENTER:
					Tools.centerToObject(this, parent, X);
					this.y = parent.y - 30;
				default:
					setPosition(parent.x + parent.width + 10, parent.y - 30);
			}
		}
	}
}
