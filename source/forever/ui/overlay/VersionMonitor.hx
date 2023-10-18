package forever.ui.overlay;

@:dox(hide)
/** Displays your current Engine Version. **/
class VersionMonitor extends BaseOverlayMonitor {
	public function new():Void {
		super(RIGHT);
		text = 'FOREVER ENGINE v${Main.version}';
	}
}
