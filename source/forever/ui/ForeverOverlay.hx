package forever.ui;

import openfl.display.Sprite;
#if cpp
import external.memory.Memory;
#end
import flixel.util.FlxStringUtil;
import openfl.text.TextFormat;
import openfl.text.TextField;

/**
 * The main overlay container used to instantiate a nice looking information
 * box that shows game info (e.g: Frames per Second, Memory Usage, etc...)
**/
class OverlayContainer extends Sprite {
	public function new():Void {
		super();

		addChild(new ForeverOverlay());
	}

	@:noCompletion @:dox(hide)
	private var deltaTimeout:Int = 0;

	override function __enterFrame(deltaTime:Int):Void {
		if (deltaTimeout >= 1000) { // if 1 second has passed.
			deltaTimeout = 0;
			return;
		}
		getChildAt(0).__enterFrame(deltaTime);
		deltaTimeout += deltaTime;
	}
}

/**
 * Overlay that shows FPS and Debug information
 * 
 * TODO: give it an actual visuals later -Crow
**/
class ForeverOverlay extends TextField {
	/** Counts your current Frames per Second. **/
	public var currentFPS:Int = 0;

	/** Counts your current Memory Usage. **/
	public var staticRAM(get, never):Float;

	/** Counts your highest Memory Usage. **/
	private var peakRAM:Float = 0.0;

	@:dox(hide) private var times:Array<Float> = [];

	public function new():Void {
		super();

		x = 10;
		y = 10;

		defaultTextFormat = new TextFormat("_sans", 12, 0xFFFFFFFF);
		mouseEnabled = selectable = false;
		multiline = true;
		autoSize = LEFT;
	}

	override function __enterFrame(deltaTime:Int):Void {
		var now:Float = haxe.Timer.stamp();
		times.push(now);
		while (times[0] < now - 1)
			times.shift();

		currentFPS = currentFPS < FlxG.drawFramerate ? times.length : FlxG.drawFramerate;
		if (staticRAM > peakRAM)
			peakRAM = staticRAM;

		if (visible) {
			text = '${currentFPS} FPS'
			#if cpp + '\n${FlxStringUtil.formatBytes(Memory.getCurrentUsage())} / ${FlxStringUtil.formatBytes(Memory.getPeakUsage())} [TASK]' #end //
			+ '\n${FlxStringUtil.formatBytes(staticRAM)} / ${FlxStringUtil.formatBytes(peakRAM)} [GC]'
			+ '\n\nFOREVER ENGINE v${Main.version}';
		}
	}

	inline function get_staticRAM():Float {
		return openfl.system.System.totalMemory;
	}
}
