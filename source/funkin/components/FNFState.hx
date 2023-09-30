package funkin.components;

import flixel.addons.transition.FlxTransitionableState;

class FNFState extends FlxTransitionableState {
	public var conductor:Conductor;
    public var controls(get,never):BaseControls;

	public function new(?initConductor:Bool = false):Void {
		super();

		if (initConductor) {
			conductor = new Conductor();
            add(conductor);
        }
	}

    ///////////////////////////////////////////////
	// GETTERS & SETTERS, DO NOT MESS WITH THESE //
	///////////////////////////////////////////////

    function get_controls():BaseControls
        return Controls.current;
}
