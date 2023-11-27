package forever;

import openfl.filters.ColorMatrixFilter;
import haxe.ds.StringMap;
import openfl.filters.BitmapFilter;

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
	// -- GENERAL -- //

	/** Check this if you want the game not to pause when unfocusing the window. **/
	public static var autoPause:Bool = false;

	/** Check this if you want the game to use the gpu more often to render sprites (experimental). **/
	public static var vramSprites:Bool = false;

	/** Your game's master volume. **/
	public static var masterVolume:Int = 100;

	// -- GAMEPLAY -- //

	/** Check this if you want your notes to come from top to bottom. **/
	public static var downScroll:Bool = false;

	/**
	 * Check this to center your notes to the screen, and hide the Enemy's notes.
	 * 
	 * A.K.A Middlescroll
	**/
	public static var centerStrums:Bool = false;

	/** Check this if you want to be able to mash keys while there's no notes to hit. **/
	public static var ghostTapping:Bool = true;

	/** Defines the limit for your frames per second. **/
	public static var framerateCap:Int = 60;

	/** Whether to enable the reset (Quick Game Over) button during gameplay. **/
	public static var resetButton:Bool = true;

	/** Defines the (spawn) offset of the notes. **/
	public static var noteOffset:Float = 0.0;

	// -- VISUALS -- //

	/** How should judgemnt animations be displayed when popping up? **/
	public static var judgementDisplayType:JudgementPopupType = FUNKIN;

	/**
	 * Style of your scrolling notes
	 *
	 * [NOTE]: only applies to non-special notes, including the Enemy's notes if they have a different style.
	**/
	public static var noteSkin:String = "normal";

	/** If the (main) camera should zoom every four beats. **/
	public static var cameraZooms:Bool = true;
	/** If the HUD should bump every four beats. **/
	public static var hudZooms:Bool = true;

	/** Applies a Screen Filter to your game, to view the game as a colorblind person would. **/
	public static var screenFilter:String = "none";

	/** Defines the opacity of the background and characters, useful if you find them distracting from the main gameplay. **/
	public static var stageDim:Int = 0;

	/** Check this to attach judgements to the center of the screen, making them easier to read. **/
	public static var fixedJudgements:Bool = false;

	/** Defines if the antialiasing filter affects all graphics. **/
	public static var globalAntialias:Bool = true;

	// -- FUNCTIONS -- //

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
			Tools.changeMaxFramerate(Settings.framerateCap);
		FlxG.sound.volume = Tools.toFloatPercent(Settings.masterVolume);
		applyFilter(Settings.screenFilter);
	}

	/**
	 * Applies the current selected filter to the screen.
	**/
	public static function applyFilter(filter:String):Void {
		final filters:Array<BitmapFilter> = [];
		final filterList:StringMap<Array<Float>> = [
			"deuteranopia" => [
				0.43, 0.72, -.15, 0, 0,
				0.34, 0.57, 0.09, 0, 0,
				-.02, 0.03,    1, 0, 0,
				0,    0,    0, 1, 0,
			],
			"protanopia" => [
				0.20, 0.99, -.19, 0, 0,
				0.16, 0.79, 0.04, 0, 0,
				0.01, -.01,    1, 0, 0,
				0,    0,    0, 1, 0,
			],
			"tritanopia" => [
				0.97, 0.11, -.08, 0, 0,
				0.02, 0.82, 0.16, 0, 0,
				0.06, 0.88, 0.18, 0, 0,
				0,    0,    0, 1, 0,
			]
		];

		if (filterList.get(filter.toLowerCase()) != null) filters.push(new ColorMatrixFilter(filterList.get(filter.toLowerCase())));
		FlxG.game.setFilters(filters);
	}
}

@:build(forever.macros.EnumHelper.makeEnum(["FUNKIN=>Funkin (Base Game)", "Simply"]))
enum abstract JudgementPopupType(Int) from Int to Int {}

@:build(forever.macros.EnumHelper.makeEnum(["None", "Deuteranopia", "Protanopia", "Tritanopia"]))
enum abstract ScreenFilterType(Int) from Int to Int {}
