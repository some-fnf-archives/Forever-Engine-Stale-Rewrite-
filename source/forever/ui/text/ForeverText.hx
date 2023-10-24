package forever.ui.text;

import flixel.text.FlxText;
import forever.ui.text.ForeverTextField;

class ForeverText extends FlxText {
	/**
	 * Creates a new `ForeverText` object at the specified position.
	 * @param   x              The x position of the text.
	 * @param   y              The y position of the text.
	 * @param   width          The `width` of the text object. Enables `autoSize` if `<= 0`.
	 *                         (`height` is determined automatically).
	 * @param   text           The actual text you would like to display initially.
	 * @param   size           The font size for this text object.
	**/
	public function new(x:Float = 0, y:Float = 0, width:Float = 0, text:String, size:Int = 10):Void {
		super(x, y, width, text, size);

		/*
			super(x, y);

			this.text = text;
			_width = Math.floor(width);
			font = AssetHelper.getAsset("vcr", FONT);
			_size = size;
		 */

		setFormat(AssetHelper.getAsset("vcr", FONT), size, 0xFFFFFFFF, LEFT, convertBorder(OUTLINE(1.5)), 0xFF000000);
	}

	@:noCompletion @:dox(hide)
	function convertBorder(border:Any):Any {
		inline function fromFlixelBorder() {
			return switch cast(border, ForeverTextBorder) {
				case OUTLINE(size):
					this.borderSize = size;
					FlxTextBorderStyle.OUTLINE;
				case SHADOW(offsetX, offsetY):
					this.shadowOffset.set(offsetX, offsetY);
					FlxTextBorderStyle.SHADOW;
				case NONE: FlxTextBorderStyle.NONE;
			}
		}

		inline function fromForeverBorder() {
			return switch cast(border, FlxTextBorderStyle) {
				case OUTLINE | OUTLINE_FAST: OUTLINE(1.5);
				case SHADOW: SHADOW(1, 1);
				case NONE: NONE;
			}
		}

		if (Std.isOfType(this, FlxText))
			return cast fromForeverBorder();
		else if (Std.isOfType(this, ForeverTextField))
			return cast fromFlixelBorder();

		return NONE;
	}
}
