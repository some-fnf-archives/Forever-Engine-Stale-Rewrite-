package forever;

import flixel.FlxG;
import flixel.input.FlxInput;
import flixel.input.keyboard.FlxKey;

@:build(forever.macros.ControlsMacro.build())
class Controls {
	/** The global instance of the Base Controls class. **/
	public static var current:BaseControls;

	/**
	 * to have a shortcut to your key, simply create a function here for it
	 * to access your shortcut, use the expression `Controls.YOURCONTROL`
	**/
	// -- COMMON ACTIONS -- //
	@:justPressed(accept) function ACCEPT() {}

	@:justPressed(back) function BACK() {}

	@:justPressed(pause) function PAUSE() {}

	@:justPressed(reset) function RESET() {}

	// -- SINGLE PRESS -- //

	@:justPressed(left) function LEFT_P() {}

	@:justPressed(down) function DOWN_P() {}

	@:justPressed(up) function UP_P() {}

	@:justPressed(right) function RIGHT_P() {}

	@:justPressed(ui_left) function UI_LEFT_P() {}

	@:justPressed(ui_down) function UI_DOWN_P() {}

	@:justPressed(ui_up) function UI_UP_P() {}

	@:justPressed(ui_right) function UI_RIGHT_P() {}

	// -- HOLDING -- //

	@:pressed(left) function LEFT() {}

	@:pressed(down) function DOWN() {}

	@:pressed(up) function UP() {}

	@:pressed(right) function RIGHT() {}

	@:pressed(ui_left) function UI_LEFT() {}

	@:pressed(ui_down) function UI_DOWN() {}

	@:pressed(ui_up) function UI_UP() {}

	@:pressed(ui_right) function UI_RIGHT() {}
}

/**
 * Handles the base of the controls class, has helper functions to detect
 * whether a key has been just pressed, is being held, or was released.
**/
class BaseControls {
	/**
	 * Default Contorls, used when booting the game for the first time
	 * or resetting your key settings
	**/
	public static final defaultControls:Map<String, Array<FlxKey>> = [
		"left" => [A, LEFT],
		"down" => [S, DOWN],
		"up" => [W, UP],
		"right" => [D, RIGHT],
		//
		"ui_left" => [A, LEFT],
		"ui_down" => [S, DOWN],
		"ui_up" => [W, UP],
		"ui_right" => [D, RIGHT],
		//
		"accept" => [ENTER, SPACE],
		"back" => [BACKSPACE, ESCAPE],
		"pause" => [ENTER, ESCAPE],
		"reset" => [R, NONE],
		#if MODS
		"switch mods" => [SLASH, CONTROL],
		#end
	];

	/** Your own Custom Controls. **/
	public var myControls:Map<String, Array<FlxKey>> = [];

	/**
	 * Ordered Array with the order of which the control options should appear in the menu.
	**/
	public var keyOrder:Array<String> = [
        "left", "down", "up", "right",
		"ui_left", "ui_down", "ui_up", "ui_right",
		"accept", "back", "pause", "reset",
		#if MODS "switch mods", #end
    ];

	/** Indicator set if you are playing with a controller. **/
	public var gamepadMode:Bool = false;

	/** Creates a new instance of the Controls Base Class. **/
	public function new():Void {
		myControls = cloneControlsMap();
		gamepadMode = false;
	}

	/** Checks if a Control Key is held. **/
	public inline function pressed(act:String):Bool
		return keyChecker(act, PRESSED);

	/** Checks if a Control Key is released. **/
	public inline function released(act:String):Bool
		return keyChecker(act, RELEASED);

	/** Checks if a Control Key has just been pressed. **/
	public inline function justPressed(act:String):Bool
		return keyChecker(act, JUST_PRESSED);

	/** Checks if a Control Key has just been released. **/
	public inline function justReleased(act:String):Bool
		return keyChecker(act, JUST_RELEASED);

	// -- HELPERS -- //

	@:dox(hide) @:noCompletion private function keyChecker(act:String, state:FlxInputState):Bool {
		for (key in myControls.get(act))
			if (FlxG.keys.checkStatus(key, state))
				return true;
		return false;
	}

	@:dox(hide) @:noCompletion private static function cloneControlsMap():Map<String, Array<FlxKey>> {
		var newMap:Map<String, Array<FlxKey>> = [];
		for (key => value in defaultControls)
			newMap[key] = value.copy();
		return newMap;
	}

	@:dox(hide) public static inline function getKeyFromAction(action:String, id:Int = 0):FlxKey {
		var key:Int = -1;
		for (name => keysArray in Controls.current.myControls) {
			if (action == name && keysArray != null)
				key = keysArray[id];
		}
		return key;
	}

	@:dox(hide) public static inline function getActionFromKey(key:FlxKey):String {
		var action:String = null;
		for (name => keysArray in Controls.current.myControls) {
			for (k in keysArray)
				if (k == key)
					action = name;
		}
		return action;
	}
}
