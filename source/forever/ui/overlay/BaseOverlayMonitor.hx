package forever.ui.overlay;

import openfl.text.TextField;
import openfl.text.TextFormat;

class BaseOverlayMonitor extends TextField {
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
