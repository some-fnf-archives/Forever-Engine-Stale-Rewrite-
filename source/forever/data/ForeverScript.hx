package forever.data;

import crowplexus.iris.Iris;
import forever.Paths.LocalPaths;

class ForeverScript extends Iris {
	var localPath:String = null;

	public function new(file:String, ?localPath:String = null):Void {
		super(file, {autoRun: true, preset: true});
		this.localPath = localPath;
	}

	public override function preset():Void {
		super.preset();

		set("FlxG", flixel.FlxG);
		set("FlxSprite", flixel.FlxSprite);
		set("Conductor", funkin.components.Conductor);
		set("AssetHelper", forever.AssetHelper);
		set("Utils", forever.Utils);

		if (localPath != null)
			set("Paths", new LocalPaths(localPath));
		else
			set("Paths", Paths);
	}
}
