package external.crash;

import openfl.display.Sprite;
import openfl.events.KeyboardEvent;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;
import openfl.text.TextFormat;
import openfl.ui.Keyboard;

/**
 * In-game crash handler state.
 * 
 * @author crowplexus
**/
class CrashHandler extends Sprite {
	var loggedError:TextField;
	var _modReset:Bool = false;

	private static var _active:Bool = false;

	public function new(errorMsg:String, details:String):Void {
		super();

		if (!_active)
			_active = true;

		// draw a background
		graphics.beginFill(0xFF000000, 1.0);
		graphics.drawRect(0, 0, flixel.FlxG.stage.application.window.width, flixel.FlxG.stage.application.window.height);
		graphics.endFill();

		// create the error text
		loggedError = new TextField();
		loggedError.defaultTextFormat = new TextFormat(Paths.font("vcr"), 24, 0xFFFFFF);
		loggedError.text = 'Fatal Error!\n${errorMsg}'
			+ '\n\nDetails:\n${details}\n'
			+ "\nPress R to Unload your mods if needed, Press ESCAPE to Reset the Game"
			+ "\nIf you feel like this error shouldn't have happened,"
			+ "\nPlease report it to our GitHub Page by pressing SPACE";

		// and position it properly
		loggedError.autoSize = TextFieldAutoSize.CENTER;
		loggedError.width = flixel.FlxG.stage.application.window.width;
		loggedError.x = 0.5 * (flixel.FlxG.stage.application.window.width - loggedError.width) * 0.5;

		addChild(loggedError);

		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, keyActions);
	}

	public function keyActions(e:KeyboardEvent):Void {
		switch e.keyCode {
			case Keyboard.R:
				forever.core.Mods.loadMod(null);
				_modReset = true;
			case Keyboard.SPACE:
				FlxG.openURL("https://github.com/crowplexus/Forever-Engine/issues");
			case Keyboard.ESCAPE:
				FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyActions);
				_active = false;
				@:privateAccess Main.self.gameClient._viewingCrash = false;
				// now that the crash handler should be no longer active, remove it from the game container.
				if (FlxG.game.contains(this)) // kind of a redundant check but mhm.
					FlxG.game.removeChild(this);
				final endCall:Void->Void = _modReset ? forever.core.Mods.resetGame : flixel.FlxG.resetState;
				endCall();
		}
	}
}
