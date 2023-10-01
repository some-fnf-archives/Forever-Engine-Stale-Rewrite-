package funkin.components;

import flixel.addons.transition.FlxTransitionableState;

class FNFState extends FlxTransitionableState {
	public var controls(get, never):BaseControls;

	public function new():Void {
		super();

		if (!FlxG.signals.preUpdate.has(Conductor.update))
			FlxG.signals.preUpdate.add(Conductor.update);
	}

	///////////////////////////////////////////////
	// GETTERS & SETTERS, DO NOT MESS WITH THESE //
	///////////////////////////////////////////////

	function get_controls():BaseControls
		return Controls.current;
}
