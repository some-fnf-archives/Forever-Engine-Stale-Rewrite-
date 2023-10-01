package;

import flixel.FlxGame;
import forever.ui.ForeverOverlay;
import openfl.display.Sprite;

class Main extends Sprite {
	public static var framerate:Int = 60;

	public static var overlay:ForeverOverlay;

	public static final initialState = funkin.states.menus.FreeplayMenu;
	public static final version:String = "1.0.0";

	public function new():Void {
		super();

		addChild(new FlxGame(1280, 720, Init, framerate, framerate, true));
		addChild(overlay = new ForeverOverlay(0, 0, 0xFFFFFFFF));
	}

	public static function setFPSCap(newFramerate:Int):Void {
		if (newFramerate > FlxG.drawFramerate) {
			FlxG.updateFramerate = newFramerate;
			FlxG.drawFramerate = newFramerate;
		}
		else {
			FlxG.drawFramerate = newFramerate;
			FlxG.updateFramerate = newFramerate;
		}
	}
}
