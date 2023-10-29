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

	public static function build() {
		var fields = Context.getBuildFields();
		var clRef = Context.getLocalClass();
		if (clRef == null)
			return fields;
		var cl = clRef.get();

		if (cl.isAbstract || cl.isExtern || cl.isFinal || cl.isInterface)
			return fields;

		// trace(cl.meta.get());

		for (meta in cl.meta.get()) {
			if (meta.name == ":makeEnum") {
				// trace(meta);

				var className = getString(meta.params[0]);
				var values = [];
				var displayNames = [];

				for (val in getArray(meta.params[1])) {
					var displayName = getString(val);
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

				// should result in `enum abstract "className"(Int) from Int to Int`
				trace("Making Enum " + className + " with sttuffs " + values + " > " + displayNames);

				var enumValues = [];
				for (i => value in values) {
					enumValues.push(macro {
						$v{value} = $v{i};
					});
				}

				trace(enumValues);

				var enumExpr = macro {
					enum abstract Cock(Int)
					from
					Int
					to
					Int
					{}
				};
			}
		}

		/*for (field in fields) {
			var p = new Printer();
			var aa = p.printField(field);
			// if(aa.length < 5024)
			trace(aa);
		}*/
		/*
			@:makeEnum("JudgementDisplay", ["Legacy", "Never Offscreen", "Forever"])
			@:makeEnum("JudgementPopupType", )
			@:makeEnum("ScreenFilterType", ["None", "Deuteranopia", "Protanopia", "Tritanopia"])
			class _SettingsHelper {} */

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

	public static function setupMetas(shadowClass:TypeDefinition, imports) {
		shadowClass.meta = [
			{
				name: ':dox',
				pos: Context.currentPos(),
				params: [
					{
						expr: EConst(CIdent("hide")),
						pos: Context.currentPos()
					}
				]
			}
		];
		var module = Context.getModule(Context.getLocalModule());
		for (t in module) {
			switch (t) {
				case TInst(t, params):
					if (t != null) {
						var e = t.get();
						processModule(shadowClass, e.module, e.name);
						processImport(imports, e.module, e.name);
					}
				case TEnum(t, params):
					if (t != null) {
						var e = t.get();
						processModule(shadowClass, e.module, e.name);
						processImport(imports, e.module, e.name);
					}
				case TType(t, params):
					if (t != null) {
						var e = t.get();
						processModule(shadowClass, e.module, e.name);
						processImport(imports, e.module, e.name);
					}
				case TAbstract(t, params):
					if (t != null) {
						var e = t.get();
						processModule(shadowClass, e.module, e.name);
						processImport(imports, e.module, e.name);
					}
				default:
					// not needed?
			}
		}
	}

	public static function processModule(shadowClass:TypeDefinition, module:String, n:String) {
		if (n.endsWith("_Impl_"))
			n = n.substr(0, n.length - 6);
		if (module.endsWith("_Impl_"))
			module = module.substr(0, module.length - 6);

		shadowClass.meta.push({
			name: ':access',
			params: [
				Context.parse(fixModuleName(module.endsWith('.${n}') ? module : '${module}.${n}'), Context.currentPos())
			],
			pos: Context.currentPos()
		});
	}

	/*public static function getModuleName(path:Type) {
		switch(path) {
			case TPath(name, pack):// | TDClass(name, pack):
				var str = "";
				for(p in pack) {
					str += p + ".";
				}
				str += name;
				return str;

			default:
		}
		return "INVALID";
	}*/
	public static function fixModuleName(name:String) {
		return [for (s in name.split(".")) if (s.charAt(0) == "_") s.substr(1) else s].join(".");
	}

	public static function processImport(imports:Array<ImportExpr>, module:String, n:String) {
		if (n.endsWith("_Impl_"))
			n = n.substr(0, n.length - 6);
		module = fixModuleName(module);
		if (module.endsWith("_Impl_"))
			module = module.substr(0, module.length - 6);

		imports.push({
			path: [
				for (m in module.split("."))
					{
						name: m,
						pos: Context.currentPos()
					}
			],
			mode: INormal
		});
	}
}
