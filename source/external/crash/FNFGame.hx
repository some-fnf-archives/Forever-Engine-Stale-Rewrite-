package external.crash;

import flixel.FlxG;
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
	var _viewingCrash:Bool = false;

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
		try {
			if (_viewingCrash)
				return;
			super.onEnterFrame(_);
		}
		catch (e:haxe.Exception)
			return exceptionCaught(e, 'onEnterFrame');
	}

	/**
	 * This function is called by `step()` and updates the actual game state.
	 * May be called multiple times per "frame" or draw call.
	 */
	override function update():Void {
		try {
			if (_viewingCrash)
				return;
			super.update();
		}
		catch (e:haxe.Exception)
			return exceptionCaught(e, 'update');
	}

	/**
	 * Goes through the game state and draws all the game objects and special effects.
	 */
	override function draw():Void {
		try {
			if (_viewingCrash)
				return;
			super.draw();
		}
		catch (e:haxe.Exception)
			return exceptionCaught(e, 'draw');
	}

	@:allow(flixel.FlxG)
	override function onResize(_):Void {
		if (_viewingCrash)
			return;
		super.onResize(_);
	}

	/**
	 * Catches an Exception that was caused by a function executed in-game
	 * 
	 * Code was entirely made by sqirra-rng for their fnf engine named "Izzy Engine", big props to them!!!
	 * very cool person for real they don't get enough credit for their work
	 */
	private function exceptionCaught(e:haxe.Exception, func:String = null) {
		if (_viewingCrash)
			return;

		var path:String;
		var callStack:Array<StackItem> = CallStack.exceptionStack(true);
		var fileStack:Array<String> = [];
		var dateNow:String = Date.now().toString();
		var println = #if sys Sys.println #else trace #end;

		dateNow = StringTools.replace(dateNow, " ", "_");
		dateNow = StringTools.replace(dateNow, ":", "'");

		path = 'crash/Forever_${dateNow}.txt';

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
					println(stackItem);
			}
		}

		final msg:String = fileStack.join('\n');

		#if sys
		if (!FileSystem.exists("crash/"))
			FileSystem.createDirectory("crash/");
		File.saveContent(path, '${msg}\n');
		#end

		final funcThrew:String = '${func != null ? ' Thrown at "${func}" Function' : ""}';

		println(msg + funcThrew);
		println('Crash dump saved in ${Path.normalize(path)}');

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		@:privateAccess {
			// _requestedState = null;
			FlxG.game.addChild(new CrashHandler(e.message + funcThrew, e.details()));
		}

		_viewingCrash = true;
	}
}
