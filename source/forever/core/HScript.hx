package forever.core;

import crowplexus.iris.Iris;
import forever.tools.Paths.LocalPaths;

class HScript extends Iris {
	var localPath:String = null;

	public function new(file:String, ?localPath:String = null):Void {
		super(Tools.getText(file), {name: file.substr(0, file.lastIndexOf(".")), autoRun: true, preset: true});
		this.localPath = localPath;
	}

	public override function preset():Void {
		super.preset();

		set("FlxG", flixel.FlxG);
		set("FlxSprite", flixel.FlxSprite);
		set("Conductor", funkin.components.Conductor);
		set("AssetHelper", forever.AssetHelper);
		set("Tools", forever.tools.Tools);

		if (localPath != null)
			set("Paths", new LocalPaths(localPath));
		else
			set("Paths", Paths);
	}
}
