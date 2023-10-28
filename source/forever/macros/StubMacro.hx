package forever.macros;

import haxe.macro.*;
import haxe.macro.Expr;

/**
 * Macro that makes stubs if you build with it
 *
 * @author Ne_Eo
**/
class StubMacro {
	public static function build() {
		var fields = Context.getBuildFields();
		var clRef = Context.getLocalClass();
		if (clRef == null)
			return fields;
		var cl = clRef.get();

		if (cl.isAbstract || cl.isExtern || cl.isFinal || cl.isInterface)
			return fields;

		for (field in fields.copy()) {
			switch (field.kind) {
				case FFun(fun):
					// if(field.name)
					var value = [];
					for (meta in field.meta) {
						if (meta.name == ":stubDefault") {
							value = [macro return ${meta.params[0]}];
						}
					}

					fun.expr.expr = EBlock(value);
				default:
			}

			for (meta in field.meta) {
				if (meta.name == ":stubRemove") {
					fields.remove(field);
					break;
				}
			}

			field.access.remove(AOverride);
		}

		trace(cl);

		cl.superClass = null;

		/*switch(cl.kind) {
			case TDClass(superClass, interfaces, isInterface, isFinal, isAbstract):
				cl.kind = TDClass(null, interfaces, isInterface, isFinal, isAbstract);
			default:
		}*/

		for (field in fields) {
			var p = new Printer();
			var aa = p.printField(field);
			// if(aa.length < 5024)
			trace(aa);
		}

		return fields;
	}
}
