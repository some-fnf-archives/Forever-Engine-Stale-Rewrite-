package forever.ui;

import flixel.text.FlxText;

/**
 * FlxText which automatic sets the default font to VCR
**/
class ForeverText extends FlxText {
	/**
	 * Creates a new `ForeverText` object at the specified position.
	 *
	 * @param   X              The x position of the text.
	 * @param   Y              The y position of the text.
	 * @param   FieldWidth     The `width` of the text object. Enables `autoSize` if `<= 0`.
	 *                         (`height` is determined automatically).
	 * @param   Text           The actual text you would like to display initially.
	 * @param   Size           The font size for this text object.
	**/
	public function new(X:Float = 0, Y:Float = 0, FieldWidth:Float = 0, Text:String, Size:Int = 8):Void {
		super(X, Y, Math.floor(FieldWidth), Text, Size);
		setFormat(AssetHelper.getAsset("vcr", FONT), size, 0xFFFFFFFF, LEFT, OUTLINE, 0xFF000000);
	}
}
