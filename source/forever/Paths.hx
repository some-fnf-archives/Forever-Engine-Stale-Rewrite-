package forever;

import flixel.graphics.FlxGraphic;

/**
 * Parity with Base Game Paths.
**/
class Paths {
	public static inline function image(image:String):FlxGraphic {
		return AssetHelper.getAsset('images/${image}', IMAGE);
	}
}
