package forever.macros;

#if macro
import haxe.macro.*;
import haxe.macro.Expr;
#end

using StringTools;

/**
 * Contains helpers for settings along with macros to save settings
 * @author @Ne_Eo
**/
class ConfigHelper {
	/** Returns the actual save path for settings. **/
	public static var savePath(get, default):String = "forever";

	@:noCompletion @:dox(hide)
	static function get_savePath():String {
		var companyName:String = lime.app.Application.current.meta["company"];
		return '${companyName}/${lime.app.Application.current.meta["file"]}/${savePath}';
	}

	#if macro // Macro Variables and Functions go here!

	/**
	 * a Macro that saves your settings
	**/
	public static function buildSaveMacro():Array<Field> {
		var fields = Context.getBuildFields();
		var savedFields = [];

		for (field in fields) {
			switch (field.kind) {
				case FVar(type, expr): // this doesnt find functions btw
					if (!field.name.startsWith("_")) // prevents saving internal or final variables
						savedFields.push(field.name);
				default:
					continue;
			}
		}

		// find flush and load fields
		for (field in fields) {
			switch (field.kind) {
				case FFun(fun):
					if (field.name == "load") {
						var arr = [(macro flixel.FlxG.save.bind("Settings", forever.macros.ConfigHelper.savePath))];
						for (name in savedFields) {
							arr.push(macro {
								if (flixel.FlxG.save.data.$name != null)
									$i{name} = flixel.FlxG.save.data.$name;
								forever.config.Settings.update();
							});
						}
						fun.expr = macro $b{arr};
					}

					if (field.name == "flush") {
						var arr = [(macro flixel.FlxG.save.bind("Settings", forever.macros.ConfigHelper.savePath))];
						// i have 0 clue if this even works, it did work first try
						for (name in savedFields) {
							arr.push(macro {
								flixel.FlxG.save.data.$name = $i{name};
								flixel.FlxG.save.flush();
								Settings.update();
							});
						}
						arr.push((macro forever.config.Settings.masterVolume = Std.int(flixel.FlxG.sound.volume / 100.0)));
						fun.expr = macro $b{arr};
					}

				default:
					continue;
			}
		}

		return fields;
	}
	#end
}
