package funkin.states.base;

class FNFState extends forever.core.scripting.ScriptableState {
	public var controls(get, never):forever.ControlsManager;

	override function new(stateName:String = null):Void {
		super(stateName);
	}

	override function create():Void {
		super.create();

		Conductor.init(true);
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

	function get_controls():forever.ControlsManager return Controls.current;
}
