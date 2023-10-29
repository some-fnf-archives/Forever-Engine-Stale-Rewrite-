package forever.macros;

import haxe.macro.*;
import haxe.macro.Expr;

using StringTools;

/**
 * @author Ne_Eo
**/
class HScriptHelper {
	public static function build() {
		var fields = Context.getBuildFields();

		for (field in fields.copy()) {
			switch (field.kind) {
				case FProp(g, s, type):
					var hasRedirect = false;
					var redirect = null;
					for (meta in field.meta) {
						if (meta.name == ":redirect") {
							redirect = meta.params[0];
							hasRedirect = true;
						}
					}
					if (!hasRedirect)
						continue;
					var name = field.name;

					if (s != "never") {
						var setfunc:Function = {
							ret: type,
							params: [],
							expr: macro return $redirect.$name = v,
							args: [
								{
									name: "v",
									opt: false,
									meta: [],
									type: type
								}
							]
						};

						fields.push({
							name: "set_" + field.name,
							access: [APublic, AInline],
							kind: FFun(setfunc),
							pos: Context.currentPos(),
						});
					}

					if (g != "never") {
						var getfunc:Function = {
							ret: type,
							params: [],
							expr: macro return $redirect.$name,
							args: []
						};

						fields.push({
							name: "get_" + field.name,
							access: [APublic, AInline],
							kind: FFun(getfunc),
							pos: Context.currentPos(),
						});
					}
				default:
			}
		}

		/*for (field in fields) {
			var p = new Printer();
			var aa = p.printField(field);
			if(!aa.contains("static "))
			trace(aa);
		}*/

		return fields;
	}

	static function getString(expr:Expr) {
		return switch (expr.expr) {
			case EConst(CIdent(str)): str;
			case EConst(CString(str, _)): str;
			default: null;
		}
	}

	static function getArray(expr:Expr) {
		return switch (expr.expr) {
			case EArrayDecl(arr): arr;
			default: [];
		}
	}
}
