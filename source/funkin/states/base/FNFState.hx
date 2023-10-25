package funkin.states.base;

import forever.core.HScript;
import flixel.addons.transition.FlxTransitionableState;

class FNFState extends FlxTransitionableState {
	public var scriptPack:Array<HScript> = [];
	public var controls(get, never):BaseControls;

	public override function create():Void {
		super.create();

		Conductor.init();

		Conductor.onStep.add(onStep);
		Conductor.onBeat.add(onBeat);
		Conductor.onBar.add(onBar);
	}

	public override function update(elapsed:Float):Void {
		super.update(elapsed);
		Conductor.update(elapsed);
	}

	public function onStep(step:Int):Void {}

	public function onBeat(beat:Int):Void {}

	public function onBar(bar:Int):Void {}

	public function initAllScriptsAt(directories:Array<String>):Array<HScript> {
		final pack:Array<HScript> = [];
		function loopThrough(dir:String):Void {
			for (script in dir) {
				if (!Tools.fileExists(AssetHelper.getPath('${dir}/${script}', HSCRIPT)))
					continue;
				pack.push(new HScript(AssetHelper.getAsset('${dir}/${script}', HSCRIPT)));
			}
		}
		if (directories.length == 1)
			loopThrough(directories[0]);
		else
			for (directory in directories)
				loopThrough(directory);
		return pack;
	}

	public function initScriptPack():Void {
		if (scriptPack.length == 0)
			return;

		for (script in scriptPack) {
			if (script == null)
				continue;
			script.call("onInit");
		}
	}

	public function appendToScriptPack(newScript:HScript):Void {
		if (scriptPack.contains(newScript))
			return;
		scriptPack.push(newScript);
		newScript.call("onInit");
	}

	public function setVarPack(name:String, obj:Dynamic):Void {
		if (scriptPack.length == 0)
			return;

		for (script in scriptPack)
			script.set(name, obj);
	}

	public function callFunPack(method:String, ?args:Array<Dynamic>):Void {
		if (scriptPack.length == 0)
			return;

		if (args == null)
			args = [];

		for (script in scriptPack)
			script.call(method, args);
	}

	// -- GETTERS & SETTERS, DO NOT MESS WITH THESE -- //

	function get_controls():BaseControls
		return Controls.current;
}
