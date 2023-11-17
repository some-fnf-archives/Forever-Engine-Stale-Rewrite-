package funkin.states.base;

import forever.core.scripting.ScriptableState;

class FNFState extends ScriptableState {
	public var controls(get, never):forever.ControlsManager;

	override function create():Void {
		super.create();

		Conductor.init();

		Conductor.onStep.add(onStep);
		Conductor.onBeat.add(onBeat);
		Conductor.onBar.add(onBar);
	}

	override function update(elapsed:Float):Void {
		Conductor.update(elapsed);
		super.update(elapsed);
	}

	public function onStep(step:Int):Void {}

	public function onBeat(beat:Int):Void {}

	public function onBar(bar:Int):Void {}

	// -- GETTERS & SETTERS, DO NOT MESS WITH THESE -- //

	function get_controls():forever.ControlsManager
		return Controls.current;
}
