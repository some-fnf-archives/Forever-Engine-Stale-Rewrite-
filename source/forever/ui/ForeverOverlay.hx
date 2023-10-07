package forever.ui;

import external.memory.Memory;
import flixel.FlxG;
import forever.ui.overlay.*;
import openfl.display.Sprite;

/**
 * Displays a Bar at the top of the screen with Text Information,
 * such as Current Framerate, RAM Usage, etc,
 * all the displayed info can be customized.
**/
class ForeverOverlay extends Sprite {
	/** List of Monitors that have been appended to this Overlay. **/
	public var monitors:Array<BaseOverlayMonitor> = [];

	/** Counts your Current Frames per Second. **/
	public var currentFPS:Int = 0;

	@:noCompletion @:dox(hide)
	private var deltaTimeout:Int = 0;
	private var times:Array<Float> = [];

	/**
	 * Instantiates the Overlay.
	 * 
	 * @param monis 		the Monitors that should be appended by default when creating the overlay.
	**/
	public function new(monis:Array<BaseOverlayMonitor>):Void {
		super();

		if (monis == null)
			monis == [];

		this.monitors = monis;
		_appendMonitors(monitors);

		flixel.FlxG.stage.addEventListener(openfl.events.KeyboardEvent.KEY_DOWN, (e) -> {
			switch (e.keyCode) {
				case openfl.ui.Keyboard.F1:
					visible = !visible;
			}
		});

		doMonitorUpdate();
	}

	/** Updates each overlay monitor (if any). **/
	public function doMonitorUpdate():Void {
		if (monitors.length == 0 || monitors == null)
			return;

		for (monitor in monitors)
			monitor.update();
	}

	override function __enterFrame(deltaTime:Int) {
		super.__enterFrame(deltaTime);

		var now:Float = haxe.Timer.stamp();
		times.push(now);
		while (times[0] < now - 1)
			times.shift();

		currentFPS = currentFPS < FlxG.drawFramerate ? times.length : FlxG.drawFramerate;

		if (monitors.length > 0) {
			graphics.clear();
			graphics.beginFill(0, 0.6);
			graphics.drawRect(0, 0, flixel.FlxG.stage.application.window.width, 25);
			graphics.endFill();

			deltaTimeout += deltaTime;
			if (deltaTimeout >= 1000) { // if 1 second has passed.
				doMonitorUpdate();
				deltaTimeout = 0;
			}

			_repositionMonitors();
		}
	}

	private function _appendMonitors(monitor:Array<BaseOverlayMonitor>):Void {
		if (monitors.length == 0 || monitors == null)
			return;

		for (i in 0...monitors.length) {
			addChild(monitors[i]);
			trace('adding new overlay monitor ${Type.getClassName(Type.getClass(monitors[i]))}.');
		}
	}

	private function _repositionMonitors():Void {
		if (monitors.length == 0 || monitors == null)
			return;

		monitors[0].x = 5;
		monitors[0].x = 0;

		if (monitors.length > 1) {
			for (i in 1...monitors.length) {
				var mon:BaseOverlayMonitor = monitors[i];
				var last = monitors[i - 1];

				mon.x = last.x + (last.width + 20);
				mon.y = last.y;
			}
		}
	}
}
