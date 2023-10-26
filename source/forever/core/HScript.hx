package forever.core;

import crowplexus.iris.Iris;
import forever.tools.Paths.LocalPaths;

#if SCRIPTING
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
		set("FlxText", flixel.text.FlxText);
		set("FlxTimer", flixel.util.FlxTimer);
		set("FlxTween", flixel.tweens.FlxTween);
		set("FlxEase", flixel.tweens.FlxEase);
		set("ForeverSprite", forever.display.ForeverSprite);
		set("ForeverText", forever.display.ForeverText);
		set("Conductor", funkin.components.Conductor);
		set("AssetHelper", forever.AssetHelper);
		set("Tools", forever.tools.Tools);

		if (localPath != null)
			set("Paths", new LocalPaths(localPath));
		else
			set("Paths", Paths);
	}
}
#else
class HScript { // stub
	var localPath:String = null;

	public function new(file:String, ?localPath:String = null):Void {}

	public function preset():Void {}

	public function get(field:String):Dynamic {}

	public function set(name:String, value:Dynamic, allowOverride:Bool = false):Void {}

	public function call(fun:String, ?args:Array<Dynamic>):Void {}

	public function exists(field:String):Bool {}

	public function destroy():Void {}

	public static function destroyAll():Void {}
}
#end
