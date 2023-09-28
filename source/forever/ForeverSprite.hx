package forever;

import forever.config.Settings;
import flixel.FlxSprite;

/**
 * Global Sprite tools
**/
class ForeverSprite extends FlxSprite
{
	public function new(?x:Float, ?y:Float):Void
	{
		super(x, y);
		antialiasing = Settings.globalAntialias;
	}

	public function addGraphic(graphic:String, ?properties:Dynamic):ForeverSprite
	{
		loadGraphic(AssetHelper.getAsset('images/$graphic', IMAGE));
		return this;
	}

	/**
	 * Adds an animation from a sparrow/packer atlas file to this sprite
	 *
	 * @param name                  name of the animation
	 * @param prefix                prefix of the animation on your sparrow atlas file
	 * @param frameRate             the framerate for the animation, defaults to 24
	 * @param looped                whether the animation loops
	 * @param indices               array with animation indices, if unspecified, the animation gets added as a prefix animation only
	**/
	public function addAtlasAnim(name:String, prefix:String, frameRate:Int = 24, looped:Bool = false, ?indices:Array<Int>):Void {
		if (indices != null)
			animation.addByIndices(name, prefix, indices, "", frameRate, looped);
		else
			animation.addByPrefix(name, prefix, frameRate, looped);
	}
}
