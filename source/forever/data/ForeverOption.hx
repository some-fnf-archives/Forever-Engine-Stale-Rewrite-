package forever.data;

import flixel.math.FlxMath;

/** Helper Enumerator for Option Types. **/
enum ForeverOptionType {
	/** Boolean Type Option. **/
	CHECKMARK();

	/** Category Type Option. **/
	CATEGORY();

	/**
	 * Number Type Option.
	 * @param min 		The minimum Value the option can go.
	 * @param max 		The maximum Value the option can go.
	 * @param decimals 	How many decimals the option has.
	 * @param clamp 	If the value should stop updating once the `max` is reached
	**/
	NUMBER(min:Float, max:Float, ?decimals:Null<Float>, ?clamp:Bool);

	/**
	 * StringArray Type Option.
	 * @param options 		A list with options that this option can be changed to.
	**/
	CHOICE(options:Array<String>);
}

/** Class Structure that handles options. **/
class ForeverOption {
	/** Name of the Option. **/
	public var name:String = "NO NAME.";

	/** Option Descriptor. **/
	public var description:String = "No Description.";

	/** Variable Reference in `Settings` **/
	public var variable:String = null;

	/** Type of the Option. **/
	public var type:ForeverOptionType = CHECKMARK;

	/** the Value of the Variable. **/
	public var value(get, set):Dynamic;

	/**
	 * Creates a new option reference struct.
	**/
	public function new(name:String, ?description:String = "", ?variable:String = "", type:ForeverOptionType = CHECKMARK):Void {
		this.name = name;
		this.description = description;
		this.variable = variable;
		this.type = type;
	}

	/**
	 * Changes the value of the option
	 * @param increment 		by how much should it be changed (used by `NUMBER` and `CHOICE` options)
	**/
	public function changeValue(increment:Int = 0):Void {
		switch (type) {
			case CHECKMARK:
				if (increment == 0)
					value = !value;

			case NUMBER(min, max, decimals, clamp):
				if (decimals == null)
					decimals = 0.01;
				if (clamp == null)
					clamp = false;

				value = (clamp ? FlxMath.bound : Utils.wrapf)(value + increment * decimals, min, max);

			case CHOICE(options):
				var curValue:Int = options.indexOf(value);
				var stringFound:String = options[FlxMath.wrap(curValue + increment, 0, options.length - 1)];
				value = stringFound;

			default:
				// nothing
		}
	}

	@:dox(hide) @:noCompletion
	function get_value():Dynamic
		return Reflect.field(Settings, variable);

	@:dox(hide) @:noCompletion
	function set_value(v:Dynamic):Dynamic {
		if (Reflect.hasField(Settings, variable))
			Reflect.setField(Settings, variable, v);
		return v;
	}
}
