package;

import flixel.FlxGame;
import openfl.display.Sprite;

class Main extends Sprite {
	public static var framerate:Int = 60;

	public static final initialState = PlayState;
	public static final version:String = "1.0.0";

	public function new():Void {
		super();

		addChild(new FlxGame(1280, 720, Init, framerate, framerate, true));
		addChild(new openfl.display.FPS());
	}
}
