package funkin.components;

import flixel.FlxSubState;

class FNFSubState extends FlxSubState {
	public var controls(get, never):BaseControls;

	public function new(color:FlxColor = 0x00000000):Void {
		super(color);
	}

	///////////////////////////////////////////////
	// GETTERS & SETTERS, DO NOT MESS WITH THESE //
	///////////////////////////////////////////////

	function get_controls():BaseControls
		return Controls.current;
}
