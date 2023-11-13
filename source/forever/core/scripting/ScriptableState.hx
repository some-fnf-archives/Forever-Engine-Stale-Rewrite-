package forever.core.scripting;

import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import forever.core.scripting.HScript;

class ScriptableState extends FlxTransitionableState {
	public var stateName:String = "ScriptableState";

	public function new(?stateName:String = null) {
		super();
		this.stateName = stateName != null ? stateName : Type.getClassName(Type.getClass(this));
	}

	public var scriptPack:Array<HScript> = [];

	public function initAllScriptsAt(directories:Array<String>):Array<HScript> {
		final pack:Array<HScript> = [];
		for (directory in directories) {
			if (!Tools.fileExists(directory))
				continue;
			for (file in Tools.listFolders(directory)) {
				for (e in ForeverAsset.grabExtensions(HSCRIPT)) {
					if (!file.endsWith(e))
						continue;
					pack.push(new HScript('${directory}/${file}'));
				}
			}
		}
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

	public function validCheck(script:HScript):Void {
		@:privateAccess {
			if (script == null || script.interp == null)
				if (scriptPack.contains(script))
					scriptPack.remove(script);
		}
	}

	public function setPackVar(name:String, obj:Dynamic):Void {
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
}

class ScriptableSubState extends FlxSubState {
	public var substateName:String = "ScriptableSubState";

	public function new(?substateName:String = null) {
		super();
		this.substateName = substateName != null ? substateName : Type.getClassName(Type.getClass(this));
	}
}
