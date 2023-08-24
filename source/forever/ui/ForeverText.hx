package forever.ui;

import flixel.text.FlxText;

/**
 * FlxText which automatic sets the default font to VCR
**/
class ForeverText extends FlxText {
	public function new(X:Float = 0, Y:Float = 0, FieldWidth:Int = 0, Text:String, Size:Int = 8):Void {
		super(X, Y, FieldWidth, Text, Size);
		setFormat(AssetHelper.getAsset("vcr", FONT), size, 0xFFFFFFFF, LEFT, OUTLINE, 0xFF000000);
	}
}
