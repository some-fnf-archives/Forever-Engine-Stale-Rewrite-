package funkin.states.base;

import flixel.addons.transition.FlxTransitionableState;

class FNFState extends FlxTransitionableState {
	public var controls(get, never):BaseControls;
	public var conductor:Conductor;

	public override function create():Void {
		super.create();

		add(conductor = new Conductor());

		conductor.onStep.add(onStep);
		conductor.onBeat.add(onBeat);
		conductor.onBar.add(onBar);
	}

	public function onStep(step:Int):Void {}

	public function onBeat(beat:Int):Void {}

	public function onBar(bar:Int):Void {}

	// -- GETTERS & SETTERS, DO NOT MESS WITH THESE -- //

	function get_controls():BaseControls
		return Controls.current;
}
