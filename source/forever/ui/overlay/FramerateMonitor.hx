package forever.ui.overlay;

@:dox(hide)
/** Displays your current Framerate Usage. **/
class FramerateMonitor extends BaseOverlayMonitor {
	public function new():Void {
		super();
		text = "??? FPS";
	}

	override function update():Void {
		if (Main.self.overlay != null && Main.self.overlay.currentFPS != 0)
			text = '${Main.self.overlay.currentFPS} FPS';
	}
}
