package forever.ui.overlay;

/** Displays your current Framerate Usage. **/
class FramerateMonitor extends BaseOverlayMonitor {
	public function new():Void {
		super();
		text = "??? FPS";
	}

	override function update():Void {
		if (Main.overlay != null && Main.overlay.currentFPS != 0)
			text = '${Main.overlay.currentFPS} FPS';
	}
}
