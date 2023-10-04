package forever.data;

#if MODS
import haxe.ds.StringMap;
import polymod.Polymod;

class ForeverModManager {
	/** Default Mods Folder. **/
	public static final MODS_FOLDER:String = "mods";

	/** List of Found Mod Folders. **/
	public static var modFolders:Array<String> = [];

	/** List of Mod Folders. **/
	public static var modsMap:StringMap<Bool>;

	@:allow(Init)
	static function initialize():Void {
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

	public static function refreshMods():Void {
		// activeMods = [];
		var scanner:Array<ModMetadata> = Polymod.scan({modRoot: MODS_FOLDER});
		for (i in scanner) modsMap.set(i.id, true);

		for (mod in modsMap.keys()) {
			var state:Bool = modsMap.get(mod);
			if (state == true) {
				modFolders.push(mod);
				Polymod.loadMod(mod);
			}
			else {
				if (Polymod.getLoadedModIds().contains(mod))
					Polymod.unloadMod(mod);
			}
		}
	}

	@:noCompletion @:noPrivateAccess
	private static function onModError(error:PolymodError) {
		trace('[${error.severity}] (${Std.string(error.code).toUpperCase()}): ${error.message}');
	}
}
#end
