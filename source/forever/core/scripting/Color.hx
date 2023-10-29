package forever.core.scripting;

/**
 * Workaround Class for using FlxColor in HScript
 * 
 * @author crowplexus & Ne_Eo
 * @author (Original) Joe Williamson (JoeCreates)
**/
@:build(forever.macros.HScriptHelper.build())
class Color {
	public static inline var TRANSPARENT:FlxColor = 0x00000000;
	public static inline var WHITE:FlxColor = 0xFFFFFFFF;
	public static inline var GRAY:FlxColor = 0xFF808080;
	public static inline var BLACK:FlxColor = 0xFF000000;

	public static inline var GREEN:FlxColor = 0xFF008000;
	public static inline var LIME:FlxColor = 0xFF00FF00;
	public static inline var YELLOW:FlxColor = 0xFFFFFF00;
	public static inline var ORANGE:FlxColor = 0xFFFFA500;
	public static inline var RED:FlxColor = 0xFFFF0000;
	public static inline var PURPLE:FlxColor = 0xFF800080;
	public static inline var BLUE:FlxColor = 0xFF0000FF;
	public static inline var BROWN:FlxColor = 0xFF8B4513;
	public static inline var PINK:FlxColor = 0xFFFFC0CB;
	public static inline var MAGENTA:FlxColor = 0xFFFF00FF;
	public static inline var CYAN:FlxColor = 0xFF00FFFF;

	public var color:FlxColor;

	public function new(col:Int):Void {
		color = new FlxColor(col);
	}

	@:redirect(color) public var red(get, set):Int;
	@:redirect(color) public var green(get, set):Int;
	@:redirect(color) public var blue(get, set):Int;
	@:redirect(color) public var alpha(get, set):Int;

	@:redirect(color) public var redFloat(get, set):Float;
	@:redirect(color) public var blueFloat(get, set):Float;
	@:redirect(color) public var greenFloat(get, set):Float;
	@:redirect(color) public var alphaFloat(get, set):Float;

	@:redirect(color) public var cyan(get, set):Float;
	@:redirect(color) public var magenta(get, set):Float;
	@:redirect(color) public var yellow(get, set):Float;
	@:redirect(color) public var black(get, set):Float;

	/**
	 * The red, green and blue channels of this color as a 24 bit integer (from 0 to 0xFFFFFF)
	 */
	@:redirect(color) public var rgb(get, set):FlxColor;

	/**
	 * The hue of the color in degrees (from 0 to 359)
	 */
	@:redirect(color) public var hue(get, set):Float;

	/**
	 * The saturation of the color (from 0 to 1)
	 */
	@:redirect(color) public var saturation(get, set):Float;

	/**
	 * The brightness (aka value) of the color (from 0 to 1)
	 */
	@:redirect(color) public var brightness(get, set):Float;

	/**
	 * The lightness of the color (from 0 to 1)
	 */
	@:redirect(color) public var lightness(get, set):Float;

	// Statics
	public static inline function fromRGB(r:Int, g:Int, b:Int, a:Int = 255):FlxColor {
		return FlxColor.fromRGB(r, g, b, a);
	}

	public static inline function fromRGBFloat(r:Float, g:Float, b:Float, a:Float = 1):FlxColor {
		return FlxColor.fromRGBFloat(r, g, b, a);
	}

	public static inline function fromCMYK(c:Float, m:Float, y:Float, b:Float, a:Float = 1):FlxColor {
		return FlxColor.fromCMYK(c, m, y, b, a);
	}

	public static function fromHSB(h:Float, s:Float, b:Float, a:Float = 1):FlxColor {
		return FlxColor.fromHSB(h, s, b, a);
	}

	public static inline function fromString(str:String):FlxColor {
		return FlxColor.fromString(str);
	}

	public static inline function fromHSL(h:Float, s:Float, l:Float, a:Float = 1):FlxColor {
		return FlxColor.fromHSL(h, s, l, a);
	}

	public static inline function interpolate(c1:Int, c2:Int, factor:Float = 0.5):FlxColor {
		return FlxColor.interpolate(c1, c2, factor);
	}

	public static inline function gradient(c1:Int, c2:Int, steps:Int, ?ease:Float->Float):Array<FlxColor> {
		return FlxColor.gradient(c1, c2, steps, ease);
	}
}
