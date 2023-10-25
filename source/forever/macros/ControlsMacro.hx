package forever.macros;

import haxe.macro.*;
import haxe.macro.Expr;

/**
 * Macro that generates Control Callbacks for the Controls Class,
 * Example Usage:
 * 
 * ```haxe
 * // empty function, the macro automatically handles the contents of this function by
 * @:justPressed(my_custom_key) function MY_CUSTOM_KEY():Void {}
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
					var cID = field.name;
					var id = "unknown";

					var type = "unknown";
					for (meta in field.meta) {
						if ([":justPressed", ":pressed", ":justReleased", ":released"].contains(meta.name)) {
							type = meta.name;
							switch (meta.params[0].expr) {
								case EConst(CIdent(_i)):
									id = _i;
								default:
							}
						}
					}

					if (id == "unknown" || type == "unknown") {
						trace("Controls: Unknown Meta");
						fields.remove(field);
						continue;
					}

					var expr = switch (type) {
						case ":justPressed": macro {
								return Controls.current.justPressed($v{id});
							}
						case ":pressed": macro {
								return Controls.current.pressed($v{id});
							}
						case ":justReleased": macro {
								return Controls.current.justReleased($v{id});
							}
						case ":released": macro {
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
