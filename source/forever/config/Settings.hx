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
@:build(forever.macros.ConfigHelper.buildSaveMacro())
class Settings {
	/** Check this if you want the game not to pause when unfocusing the window. **/
	public static var autoPause:Bool = false;

	/** Check this if you want your notes to come from top to bottom. **/
	public static var downScroll:Bool = false;

	/** Check this to center your notes to the screen, and hide the Enemy's notes. **/
	public static var centerNotefield:Bool = false;

	/** Check this if you want to be able to mash keys while there's no notes to hit. **/
	public static var ghostTapping:Bool = true;

	/** Style of the healthbar, score popups, etc. **/
	public static var uiStyle:String = "default";

	/**
	 * Style of your scrolling notes
	 *
	 * [NOTE]: only applies to non-special notes, including the Enemy's notes if they have a different style.
	**/
	public static var noteSkin:String = "default";

	/** Applies a Screen Filter to your game, to view the game as a colorblind person would. **/
	public static var screenFilter:String = "none"; // ['none', 'Deuteranopia', 'Protanopia', 'Tritanopia'];

	/** Where should the sustain clip to? **/
	public static var sustainLayer:String = "above note"; // ["above note", "below note"]

	/** Defines if the antialiasing filter affects all graphics. **/
	public static var globalAntialias:Bool = true;

	/**
	 * Saves your set settings, managed by a macro at `forever.macros.ConfigHelper`.
	 * [IT IS NOT RECOMMENDED TO MESS WITH THIS]
	**/
	public static function flush():Void {}

	/**
	 * Loads Settings from your save file, managed by a macro at `forever.macros.ConfigHelper`.
	 * [IT IS NOT RECOMMENDED TO MESS WITH THIS]
	**/
	public static function load():Void {}

	/**
	 * Updates the game's settings to match your current set preferences.
	**/
	public static function update():Void {
		FlxG.autoPause = Settings.autoPause;
	}
}
