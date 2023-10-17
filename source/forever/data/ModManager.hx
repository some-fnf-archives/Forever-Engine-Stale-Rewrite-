package forever.data;

#if MODS
import haxe.ds.StringMap;
import openfl.utils.Assets as OpenFLAssets;
import polymod.Polymod;

/**
 * the Mod Manager Class allows you to easily refresh our Mods List,
 * along with helping to manage current enabled and disabled mods.
**/
class ModManager {
	/** Default Mods Folder. **/
	public static final MODS_FOLDER:String = "mods";

	/** List of Mods found. **/
	public static var mods:Array<ModMetadata> = [];

	/** Current Active Mod. **/
	public static var currentMod:ModMetadata;

	@:allow(Init)
	/** Initializes the Mod Manager. **/
	static function initialize():Void {
		var polyInit = Polymod.init({
			modRoot: MODS_FOLDER,
			dirs: [],
			apiVersionRule: "*.*.*",
			errorCallback: onModError,
			ignoredFiles: Polymod.getDefaultIgnoreList(),
			framework: Framework.FLIXEL
		});

		mods = polyInit.map(function(mod:ModMetadata) return mod);
	}

	/**
	 * Rescans the mods in the mods folder and activates the mods that should be enabled.
	**/
	public static function refreshMods():Void {
		mods = Polymod.scan({modRoot: MODS_FOLDER});
	}

	public static function loadMod(mod:String):Void {
		if (mod == "Friday Night Funkin'") {
			Polymod.unloadAllMods();
			return;
		}

		var modStrings:Array<String> = mods.map(function(coolMod:ModMetadata) return coolMod.id);
		if (modStrings.contains(mod))
			Polymod.loadMod(mod);
	}

	@:noCompletion @:noPrivateAccess @:dox(hide)
	private static function onModError(error:PolymodError) {
		trace('[${error.severity}] (${Std.string(error.code).toUpperCase()}): ${error.message}');
	}
}
#end
