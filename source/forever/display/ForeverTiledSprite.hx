package forever.display;

import forever.display.ForeverSprite;

enum abstract TileMode(Int) to Int {
	var TILE = 0;
	var SCALE = 0;
}

/**
 * a Sprite that displays a repeated graphic when scaled,
 * instead of stretching the graphic.
**/
class ForeverTiledSprite extends ForeverSprite {
	/** Tile Mode of the Sprite, use SCALE for a similar behavior to normal sprites. **/
	public var tileMode:Int = TILE;

	/**
	 * Creates a new Tiled Sprite.
	 * @param x				The initial X Position of the Sprite.
	 * @param y				The initial Y Position of the Sprite.
	 * @param graphic		The name of the graphic (will be searched for in `assets/images`).
	 * @param properties	The properties to modify for this graphic, options: alpha, color, "scale.x", "scale.y".
	**/
	public function new(?x:Float = 0, ?y:Float = 0, ?image:String, ?properties:Dynamic):Void {
		super(x, y);

		antialiasing = Settings.globalAntialias;
		if (image != null)
			addGraphic(image, properties);
	}
}
