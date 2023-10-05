package forever.config.macros;

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
	public static var savePath(get, never):String;

	@:noCompletion @:dox(hide)
	static function get_savePath():String {
		var companyName:String = lime.app.Application.current.meta["company"];
		return '${companyName}/${lime.app.Application.current.meta["file"]}';
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
			}
		}

		// find flush and load fields
		for (field in fields) {
			switch (field.kind) {
				case FFun(fun):
					if (field.name == "flush") {
						var arr = [];
						// i have 0 clue if this even works, it did work first try
						for (name in savedFields) {
							arr.push(macro {
								flixel.FlxG.save.data.$name = $i{name};
							});
						}
						fun.expr = macro $b{arr};
					}

					if (field.name == "load") {
						var arr = [];
						arr.push(macro flixel.FlxG.save.bind("Settings", ConfigHelper.savePath));
						for (name in savedFields) {
							arr.push(macro {
								if (flixel.FlxG.save.data.$name != null)
									$i{name} = flixel.FlxG.save.data.$name;
							});
						}
						fun.expr = macro $b{arr};
					}
				default:
			}
		}

		return fields;
	}
	#end
}
