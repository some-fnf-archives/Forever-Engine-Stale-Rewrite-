package forever.ui;

import flixel.FlxG;
import flixel.util.FlxStringUtil;
import haxe.Timer as HaxeTimer;
import openfl.text.TextField;
import openfl.text.TextFormat;

/**
 * Displays FPS and Memory Info on-screen.
 *
 * based on this tutorial: https://keyreal-code.github.io/haxecoder-tutorials/17_displaying_fps_and_memory_usage_using_openfl.html
**/
class ForeverOverlay extends TextField {
	public var currentFPS:Int = 0;
	public var staticRAM(get, never):Float;

	@:noCompletion private var peakRAM:Float = 0.0;
	@:noCompletion private var times:Array<Float> = [];

	public function new(x:Float = 0, y:Float = 0, color:Int = 0xFFFFFFFF):Void {
		super();

		defaultTextFormat = new TextFormat(AssetHelper.getAsset("vcr", FONT), 16, color);
		autoSize = LEFT;
		mouseEnabled = false;
		width = FlxG.width;

		addEventListener(openfl.events.Event.ENTER_FRAME, updateText);
	}

	private function updateText(_):Void {
		var now:Float = HaxeTimer.stamp();

		times.push(now);
		while (times[0] < now - 1)
			times.shift();

		currentFPS = currentFPS < FlxG.drawFramerate ? times.length : FlxG.drawFramerate;
		if (staticRAM > peakRAM)
			peakRAM = staticRAM;

		text = '${currentFPS} FPS' //
			+ '\n${FlxStringUtil.formatBytes(staticRAM)} / ${FlxStringUtil.formatBytes(peakRAM)}' //
			+ getExtraInfo();
	}

	private function getExtraInfo():String {
		#if (debug && !USE_FLIXEL_DEBUGGER)
		return '\nState: ${Type.getClassName(Type.getClass(FlxG.state))}' //
			+ '\nObjects: ${FlxG.state.countLiving()}' //
			+ ' | Cameras: ${FlxG.state.cameras.length}' //
			+ ' | Draws: ${flixel.graphics.tile.FlxDrawBaseItem.drawCalls}';
		#else
		return "";
		#end
	}

	///////////////////////////////////////////////
	// GETTERS & SETTERS, DO NOT MESS WITH THESE //
	///////////////////////////////////////////////

	function get_staticRAM():Float {
		return openfl.system.System.totalMemory;
	}
}
