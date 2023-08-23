package;

import flixel.FlxG;
import flixel.FlxState;
import forever.config.Controls;

/**
 * This is the initialization class, it simply modifies and initializes a few important variables
 * add anything in here for the game to initialize before beginning
**/
class Init extends FlxState {
	public override function create():Void {
		super.create();

		FlxG.fixedTimestep = false;
		FlxG.mouse.useSystemCursor = true;
		FlxG.mouse.visible = false;

		Controls.current = new BaseControls();

		FlxG.switchState(Type.createInstance(Main.initialState, []));
	}
}
