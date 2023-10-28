package external.crash;

import flixel.FlxGame;
import haxe.CallStack;
import haxe.io.Path;
#if sys
import sys.FileSystem;
import sys.io.File;
#end

/**
 * FlxGame with error handling
 * 
 * @author crowplexus
**/
class FNFGame extends FlxGame {
	/**
	 * Used to instantiate the guts of the flixel game object once we have a valid reference to the root.
	 */
	override function create(_):Void {
		try
			super.create(_)
		catch (e:haxe.Exception)
			return exceptionCaught(e, 'create');
	}

	/**
	 * Called when the user on the game window
	 */
	override function onFocus(_):Void {
		try
			super.onFocus(_)
		catch (e:haxe.Exception)
			return exceptionCaught(e, 'onFocus');
	}

	/**
	 * Called when the user clicks off the game window
	 */
	override function onFocusLost(_):Void {
		try
			super.onFocusLost(_)
		catch (e:haxe.Exception)
			return exceptionCaught(e, 'onFocusLost');
	}

	/**
	 * Handles the `onEnterFrame` call and figures out how many updates and draw calls to do.
	 */
	override function onEnterFrame(_):Void {
		try
			super.onEnterFrame(_)
		catch (e:haxe.Exception)
			return exceptionCaught(e, 'onEnterFrame');
	}

	/**
	 * This function is called by `step()` and updates the actual game state.
	 * May be called multiple times per "frame" or draw call.
	 */
	override function update():Void {
		try
			super.update()
		catch (e:haxe.Exception)
			return exceptionCaught(e, 'update');
	}

	/**
	 * Goes through the game state and draws all the game objects and special effects.
	 */
	override function draw():Void {
		try
			super.draw()
		catch (e:haxe.Exception)
			return exceptionCaught(e, 'draw');
	}

	/**
	 * Catches an Exception that was caused by a function executed in-game
	 * 
	 * Code was entirely made by sqirra-rng for their fnf engine named "Izzy Engine", big props to them!!!
	 * very cool person for real they don't get enough credit for their work
	 */
	private function exceptionCaught(e:haxe.Exception, func:String = null) {
		var path:String;
		var callStack:Array<StackItem> = CallStack.exceptionStack(true);
		var fileStack:Array<String> = [];
		var dateNow:String = Date.now().toString();

		dateNow = StringTools.replace(dateNow, " ", "_");
		dateNow = StringTools.replace(dateNow, ":", "'");

		path = "crash/" + "PsychEngine_" + dateNow + ".txt";

		for (stackItem in callStack) {
			switch (stackItem) {
				case CFunction:
					fileStack.push('Non-Haxe (C) Function');
				case Module(moduleName):
					fileStack.push('Module (${moduleName})');
				case FilePos(s, file, line, column):
					fileStack.push('${file} (line ${line})');
				case Method(className, method):
					fileStack.push('${className} (method ${method})');
				case LocalFunction(name):
					fileStack.push('Local Function (${name})');
				default:
					#if sys Sys.println #else trace #end (stackItem);
			}
		}

		final msg:String = fileStack.join('\n');

		#if sys
		if (!FileSystem.exists("crash/"))
			FileSystem.createDirectory("crash/");
		File.saveContent(path, '${msg}\n');
		#end

		#if sys Sys.println #else trace #end (msg + '${func != null ? 'Thrown at "${func}" Function' : ""}');
		#if sys Sys.println #else trace #end ('Crash dump saved in ${Path.normalize(path)}');

		goToExceptionState(e.message, e.details(), true);
	}

	private function goToExceptionState(error:String, details:String, shouldGithubReport:Bool) {
		_requestedState = Type.createInstance(external.crash.CrashHandler, [error, details, shouldGithubReport]);
		switchState();
	}
}
