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

	/** List of Found Mod Folders. **/
	public static var modFolders:Array<String> = [];

	/** List of Mod Folders. **/
	public static var modsMap:StringMap<Bool>;

	@:allow(Init)
	/** Initializes the Mod Manager. **/
	static function initialize():Void {
		if (!OpenFLAssets.exists(MODS_FOLDER))
			return;

		var polyInit = Polymod.init({
			modRoot: MODS_FOLDER,
			dirs: [],
			apiVersionRule: "*.*.*",
			errorCallback: onModError,
			ignoredFiles: Polymod.getDefaultIgnoreList(),
			framework: Framework.FLIXEL
		});
		modsMap = new StringMap<Bool>();

		var modIDs:Array<String> = polyInit.map(function(mod:ModMetadata) return mod.id);
		refreshMods();
	}

	/**
	 * Rescans the mods in the mods folder and activates the mods that should be enabled.
	**/
	public static function refreshMods():Void {
		if (!OpenFLAssets.exists(MODS_FOLDER))
			return;

		// activeMods = [];
		var scanner:Array<ModMetadata> = Polymod.scan({modRoot: MODS_FOLDER});
		for (i in scanner)
			modsMap.set(i.id, true);

		for (mod in modsMap.keys()) {
			if (modsMap.get(mod) == true) {
				modFolders.push(mod);
				Polymod.loadMod(mod);
			}
			else {
				if (Polymod.getLoadedModIds().contains(mod))
					Polymod.unloadMod(mod);
			}
		}
	}

	@:noCompletion @:noPrivateAccess @:dox(hide)
	private static function onModError(error:PolymodError) {
		trace('[${error.severity}] (${Std.string(error.code).toUpperCase()}): ${error.message}');
	}
}
#end
