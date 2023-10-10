package forever.macros;

import haxe.macro.*;
import haxe.macro.Expr;

/**
 * Macro that generates Control Callbacks for the Controls Class,
 * Example Usage:
 * 
 * ```haxe
 * // empty function, the macro automatically handles the contents of this function by
 * function MY_CUSTOM_KEY(jp_my_custom_key):Void {}
 * ```
 * 
 * @author Ne_Eo
**/
class ControlsMacro {
	/**
	 * Builds the Controls Macro.
	**/
	public static function build() {
		var fields = Context.getBuildFields();

		for (field in fields.copy()) {
			switch (field.kind) {
				case FFun(fun):
					var _ = fun.args[0].name.split("_");
					var cID = field.name;
					var type = _.shift();
					var id = _.join("_");

					var expr = switch (type) {
						case "jp": macro {
								return Controls.current.justPressed($v{id});
							}
						case "p": macro {
								return Controls.current.pressed($v{id});
							}
						case "jr": macro {
								return Controls.current.justReleased($v{id});
							}
						case "r": macro {
								return Controls.current.released($v{id});
							}
						default: macro {
								return false;
							}
					}

					// TODO: make it use custom expr if like the length of the exprs isnt 0
					// function RANDOM_P() {
					//     return current.justPressed(["left", "right", "up", "down"][FlxG.random.int(0, 3)]);
					// }

					var func:Function = {
						ret: TPath({name: "Bool", params: [], pack: []}),
						params: [],
						expr: expr,
						args: []
					};

					var getField:Field = {
						name: "get_" + cID,
						access: [AStatic], // field.access.copy(),
						kind: FFun(func),
						pos: Context.currentPos(),
						doc: field.doc,
						meta: field.meta.copy()
					};

					getField.meta.push({name: ":dox", params: [macro hide], pos: Context.currentPos()});
					getField.meta.push({name: ":noCompletion", params: [], pos: Context.currentPos()});

					var propertyField:Field = {
						name: field.name,
						access: [APublic, AStatic],
						kind: FieldType.FProp("get", "never", func.ret),
						pos: Context.currentPos(),
					};

					fields.remove(field);
					fields.push(propertyField);
					fields.push(getField);

				default:
			}
		}

		return fields;
	}
}
