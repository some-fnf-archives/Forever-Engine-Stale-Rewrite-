package forever.config;

/**
 * Contains Default Values for Settings
 * if you wish to create one, here's how
 *
 * ```haxe
 * // T is Type of Setting, V is Value
 * public static var mySetting:T = V;
 * ```
 * Settings get automatically saved so it is not recommended to mess with this class
 * any further than just creating a new setting
**/
class Settings {
	/**
	 * Check this if you want your notes to come from top to bottom
	**/
	public static var downScroll:Bool = false;

	/**
	 * Check this to center your notes to the screen, and hide the AI's notes
	**/
	public static var centerNotefield:Bool = false;

	/**
	 * Style of the healthbar, score popups, etc.
	**/
	public static var uiStyle:String = "default";

	/**
	 * Style of your scrolling notes
	 *
	 * [NOTE]: only applies to non-special notes, including the AI's notes if they have a different style
	 */
	public static var noteSkin:String = "default";

	/**
	 * Applies a Screen Filter to your game, to view the game as a colorblind person would
	 */
	public static var screenFilter:String = "none"; // ['none', 'Deuteranopia', 'Protanopia', 'Tritanopia'];

	/**
	 * Where should the sustain clip?
	 */
	public static var sustainLayer:String = "above note"; // ["above note", "below note"]

	/**
	 * Defines if the antialiasing effect affects all graphics.
	 */
	public static var globalAntialias:Bool = true;

	/**
	 * Saves your set settings, managed by a macro at `forever.config.macros.ConfigHelper`
	 * [NOT RECOMMENDED TO MESS WITH TIS]
	**/
	public static function flush():Void {}

	/**
	 * Loads Settings from your save file, managed by a macro at `forever.config.macros.ConfigHelper`
	 * [NOT RECOMMENDED TO MESS WITH TIS]
	**/
	public static function load():Void {}
}
