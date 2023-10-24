package forever;

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
	// -- GAMEPLAY -- //

	/** Check this if you want the game not to pause when unfocusing the window. **/
	public static var autoPause:Bool = false;

	/** Your game's master volume **/
	public static var masterVolume:Int = 100;

	/** Your game's music volume **/
	public static var musicVolume:Int = 100;

	/** Your game's sfx volume **/
	public static var soundVolume:Int = 100;

	/** Check this if you want your notes to come from top to bottom. **/
	public static var downScroll:Bool = false;

	/** Check this to center your notes to the screen, and hide the Enemy's notes. **/
	public static var centerNotefield:Bool = false;

	/** Check this if you want to be able to mash keys while there's no notes to hit. **/
	public static var ghostTapping:Bool = true;

	/** Defines the limit for your frames per second **/
	public static var framerateCap:Int = 60;

	// -- VISUALS -- //

	/** Style of the healthbar, score popups, etc. **/
	public static var uiStyle:String = "default";

	/**
	 * Style of your scrolling notes
	 *
	 * [NOTE]: only applies to non-special notes, including the Enemy's notes if they have a different style.
	**/
	public static var noteSkin:String = "default";

	/** Applies a Screen Filter to your game, to view the game as a colorblind person would. **/
	public static var screenFilter:String = "none";

	/** Where should the sustain clip to? either above the note (fnf) or below it (stepmania) **/
	public static var sustainLayer:String = "stepmania";

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
		if (FlxG.drawFramerate != Settings.framerateCap)
			Main.setFPSCap(Settings.framerateCap);
		FlxG.sound.volume = Settings.masterVolume / 100.0;
	}
}
