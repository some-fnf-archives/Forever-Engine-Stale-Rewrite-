package funkin.components;

import flixel.FlxSubState;

class FNFSubState extends FlxSubState {
	public var conductor:Conductor;
    public var controls(get,never):BaseControls;

	public function new(?initConductor:Bool = false):Void {
		super(0x00000000);

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
