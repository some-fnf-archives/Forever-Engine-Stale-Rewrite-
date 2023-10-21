package forever.data;

#if MODS
import sys.FileSystem;
import sys.io.File;

typedef ForeverMod = {
	var title:String;
	var description:String;
	var authors:Array<ModCredit>;
	var definingColor:Null<FlxColor>;

	var modVersion:String;
	var apiVersion:String;

	var license:String;

	@:optional var folder:String;
}

enum ModCredit {
	ModCredit(name:String, icon:String, role:String, description:String);
}

/**
 * the Mod Manager Class allows you to easily refresh our Mods List,
 * along with helping to manage current enabled and disabled mods.
**/
class Mods {
	/** Default Mods Folder. **/
	public static final MODS_FOLDER:String = "mods";

	/** Mod API Version **/
	public static final API_VERSION:String = "1.0.0-PRE";

	/** List of Mods found. **/
	public static var mods:Array<ForeverMod> = [];

	/** Current Active Mod. **/
	public static var currentMod:ForeverMod;

	@:allow(Init)
	/** Initializes the Mod Manager. **/
	static function initialize():Void {
		trace('[Mods:initialize]: Initialized the Forever Engine mods system, Version: ${API_VERSION}');
		refreshMods();
	}

	/**
	 * Rescans the mods in the mods folder and activates the mods that should be enabled.
	**/
	public static function refreshMods():Void {
		mods = [];

		var rawModsList:Array<String> = Utils.listFolders('${MODS_FOLDER}');

		for (folder in rawModsList) {
			if (!sys.FileSystem.exists('${MODS_FOLDER}/${folder}/mod.json')) {
				trace('[${MODS_FOLDER}/${folder}]: "mod.json" file does not exist.');
				continue;
			}

			var modJson:ForeverMod = cast sys.io.File.getContent('./${MODS_FOLDER}/${folder}/mod.json');

			// did you know: you can make functions inside functions -Crow
			inline function makeModCredits():Array<ModCredit> {
				var credits:Array<ModCredit> = [];
				for (i in cast(modJson.authors, Array<Dynamic>)) {
					if (i == null)
						continue;
					credits.push(ModCredit(i.name ?? "???", i.icon ?? "face", i.role ?? "(No Role Given).", i.description ?? "(No Description Given)."));
				}
				return credits.length == 0 ? null : credits;
			};

			var mod:ForeverMod = {
				title: modJson.title ?? folder,
				folder: folder,
				description: modJson.description != null ? modJson.description : "(No Description Given.)",
				authors: makeModCredits() ?? [ModCredit("???", "face", "(No Role Given.)", "(No Description Given.)")],
				definingColor: modJson.definingColor ?? FlxColor.GRAY,
				modVersion: modJson.modVersion ?? "0.0.1",
				apiVersion: modJson.apiVersion ?? API_VERSION,
				license: modJson.license ?? "No license"
			};

			if (mods.contains(mod))
				continue;

			mods.push(mod);
		}
	}

	public static function loadMod(mod:String):Void {
		if (mod == "Friday Night Funkin'") {
			AssetHelper.searchLevel = "";
			currentMod = null;
			return;
		}

		var modStrings:Array<String> = mods.map(function(coolMod:ForeverMod):String return coolMod.title);

		if (modStrings.contains(mod)) {
			var folder:String = "";
			mods.map(function(coolMod:ForeverMod):ForeverMod {
				if (coolMod.title == mod) {
					currentMod = coolMod;
					folder = coolMod.folder;
				}
				return coolMod;
			});
			AssetHelper.searchLevel = folder;
		}
	}
}
#end
