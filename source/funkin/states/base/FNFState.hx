package funkin.states.base;

import forever.core.scripting.ScriptableState;

class FNFState extends ScriptableState {
	public var controls(get, never):forever.ControlsManager;

	override function new(stateName:String = null):Void {
		super(stateName);

		Conductor.active = false;

		if (!Conductor.onStep.has(onStep)) Conductor.onStep.add(onStep);
		if (!Conductor.onBeat.has(onBeat)) Conductor.onBeat.add(onBeat);
		if (!Conductor.onBar.has(onBar)) Conductor.onBar.add(onBar);
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
