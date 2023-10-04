package forever.ui.overlay;

import external.memory.Memory;
import flixel.util.FlxStringUtil;

/** Displays your current (and highest) Memory Usage. **/
class MemoryMonitor extends BaseOverlayMonitor {
	public var staticRAM(get, never):Float;

	@:noCompletion private var peakRAM:Float = 0.0;

	public function new():Void {
		super();
		text = "??? / ???";
	}

	override function update():Void {
		if (staticRAM > peakRAM)
			peakRAM = staticRAM;

		text = ""
		#if cpp + '${FlxStringUtil.formatBytes(Memory.getCurrentUsage())} / ${FlxStringUtil.formatBytes(Memory.getPeakUsage())} [TASK] - ' #end //
		+ '${FlxStringUtil.formatBytes(staticRAM)} / ${FlxStringUtil.formatBytes(peakRAM)} [GC]';
		// + getExtraInfo();
	}

	/*
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
	 */
	// -- GETTERS & SETTERS, DO NOT MESS WITH THESE -- //

	function get_staticRAM():Float {
		return openfl.system.System.totalMemory;
	}
}
