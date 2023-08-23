package forever.config.macros;

import haxe.macro.*;
import haxe.macro.Expr;

/**
 * Macro by @Ne_Eo
**/
class ControlsMacro {
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

					// oh my fucking god, i just had the best idea, what if like

					/**

						@:build(AIMacro.build())
						\**
						  traces the words "Hello World", and then exits the program
						*\
						function hello() {

						}

						// it'd be interesting actually
						// each time it has a chance of not working lol, since chat gpt is unique per session

					**/

					fields.remove(field);

					fields.push(propertyField);
					fields.push(getField);

				// trace('name: ${field.name}, type: ${type}, id: ${id}');
				default:
			}
		}

		/*for(field in fields) {
			var p = new Printer();
			var aa = p.printField(field);
			trace(aa);
		}*/

		return fields;
	}
}
