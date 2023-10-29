package forever.macros;

import haxe.macro.*;
import haxe.macro.Expr;

using StringTools;

/**
 * Creates an abstract enum of integers by using strings, while also adding a `toString()` method to them
 * 
 * @author Ne_Eo
**/
class EnumHelper {
	public static function print() {
		var fields = Context.getBuildFields();
		var clRef = Context.getLocalClass();
		if (clRef == null)
			return fields;
		var cl = clRef.get();

		trace(cl);

		return fields;
	}

	public static function makeEnum(_values:Array<String>) {
		var fields = Context.getBuildFields();

		var values = [];
		var displayNames = [];
		for (val in _values) {
			var displayName = val;
			var constName = displayName.toUpperCase().replace(" ", "_");
			// -- CUSTOM NAMING FOR `toString()` METHOD -- //
			if (displayName.contains("=>")) {
				var a = displayName.split("=>");
				constName = a[0].toUpperCase().replace(" ", "_");
				displayName = a[1];
			}
			// -- -- -- //
			values.push(constName);
			displayNames.push(displayName);
		}

		for (i => value in values) {
			fields.push({
				name: value,
				access: [APublic],
				kind: FVar(macro :Int, macro $v{i}),
				pos: Context.currentPos(),
			});
		}

		// generate toString function
		var toStringExpr:Expr = macro return switch this {
			case _: Std.string(this);
		};

		// fill switch case
		switch (toStringExpr.expr) {
			case ESwitch(t, v, g):
				for (i => value in values) {
					var displayName = displayNames[i];
					v.insert(v.length - 1, {
						values: [macro $i{value}],
						expr: macro $v{displayName}
					});
				}
			default:
		}

		var func:Function = {
			ret: (macro :String),
			params: [],
			expr: toStringExpr,
			args: []
		};

		fields.push({
			name: "toString",
			access: [APublic, AInline],
			kind: FFun(func),
			pos: Context.currentPos(),
		});

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
