package funkin.components;

import flixel.FlxSubState;

class FNFSubState extends FlxSubState {
	public var controls(get, never):BaseControls;

	public function new(?initConductor:Bool = false):Void {
		super(0x00000000);
	}

	///////////////////////////////////////////////
	// GETTERS & SETTERS, DO NOT MESS WITH THESE //
	///////////////////////////////////////////////

	function get_controls():BaseControls
		return Controls.current;
}
