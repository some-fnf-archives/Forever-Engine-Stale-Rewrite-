package forever.core.scripting;

#if SCRIPTING
import crowplexus.iris.Iris;
import forever.tools.Paths.LocalPaths;
#end

#if !SCRIPTING
@:build(forever.macros.StubMacro.build())
#end
class HScript #if SCRIPTING extends Iris #end {
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

	#if !SCRIPTING
	@:stubDefault(null) public override function get(field:String):Dynamic
		return super.get(field);

	public override function set(name:String, value:Dynamic, allowOverride:Bool = false):Void
		super.set(name, value, allowOverride);

	@:stubDefault(null) public override function call(fun:String, ?args:Array<Dynamic>):Dynamic
		return super.call(fun, args);

	@:stubDefault(false) public override function exists(field:String):Bool
		return super.exists(field);

	public override function destroy():Void
		super.destroy();

	public static function destroyAll():Void {}
	#end
}
