package forever.ui.overlay;

import openfl.text.TextField;
import openfl.text.TextFormat;

/**
 * a Base Class for Overlay Monitors,
 * it is recommended for you to override this and
 * add your own custom behavior in a separate class.
**/
class BaseOverlayMonitor extends TextField {
	/** Creates a new Base Overlay Monitor **/
	public function new():Void {
		super();

		defaultTextFormat = new TextFormat(AssetHelper.getAsset("vcr", FONT), 20, 0xFFFFFFFF);
		autoSize = LEFT;
		mouseEnabled = false;
		selectable = false;
	}

	/** Override to add custom update behavior to your Monitor. **/
	public function update():Void {}
}
