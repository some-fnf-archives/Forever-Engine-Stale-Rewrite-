package funkin.components;

import flixel.addons.transition.FlxTransitionableState;

class FNFState extends FlxTransitionableState {
	public var controls(get, never):BaseControls;

	public function new():Void {
		super();
	}

	///////////////////////////////////////////////
	// GETTERS & SETTERS, DO NOT MESS WITH THESE //
	///////////////////////////////////////////////

	function get_controls():BaseControls
		return Controls.current;
}
