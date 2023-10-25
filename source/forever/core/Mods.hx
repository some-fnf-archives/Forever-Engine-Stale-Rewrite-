package forever.core;

#if MODS
typedef ForeverMod = {
	var title:String;
	var description:String;
	var authors:Array<ModCredit>;
	var definingColor:Null<FlxColor>;
	var modVersion:String;

	@:optional var apiVersion:String;
	@:optional var license:String;
	@:optional var resetGame:Bool;
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
	public static final MODS_FOLDER:String = "assets";

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

		var rawModsList:Array<String> = Tools.listFolders('${MODS_FOLDER}');

		for (folder in rawModsList) {
			if (!sys.FileSystem.exists('${MODS_FOLDER}/${folder}/mod.yaml')) {
				trace('[${MODS_FOLDER}/${folder}]: "mod.yaml" file does not exist.');
				continue;
			}

			final modData:ForeverMod = cast yaml.Yaml.parse(sys.io.File.getContent('${MODS_FOLDER}/${folder}/mod.yaml'), yaml.Parser.options().useObjects());

			// did you know: you can make functions inside functions -Crow
			inline function makeModCredits():Array<ModCredit> {
				var credits:Array<ModCredit> = [];
				for (i in cast(modData.authors, Array<Dynamic>)) {
					if (i == null)
						continue;
					credits.push(ModCredit(i.name ?? "???", i.icon ?? "face", i.role ?? "(No Role Given).", i.description ?? "(No Description Given)."));
				}
				return credits.length == 0 ? null : credits;
			};

			final mod:ForeverMod = {
				title: modData.title ?? folder,
				folder: folder,
				description: modData.description != null ? modData.description : "(No Description Given.)",
				authors: makeModCredits() ?? [ModCredit("???", "face", "(No Role Given.)", "(No Description Given.)")],
				definingColor: modData.definingColor ?? FlxColor.GRAY,
				modVersion: modData.modVersion ?? "0.0.1",
				apiVersion: modData.apiVersion ?? API_VERSION,
				resetGame: modData.resetGame ?? false,
				license: modData.license ?? "No license"
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
		var willReset:Bool = false;

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

	public static function resetGame():Void {
		funkin.states.menus.TitleScreen.seenIntro = false;
		forever.Settings.flush();

		if (FlxG.sound.music != null && FlxG.sound.music.playing)
			FlxG.sound.music.fadeOut(0.5, 0.0);

		for (camera in FlxG.cameras.list)
			camera.fade(0xFF000000, 0.55, FlxG.resetGame);
	}

	public static function loadInitScript():Void {
		if (sys.FileSystem.exists(AssetHelper.getPath('init', HSCRIPT))) {
			var initScript:HScript = new HScript(AssetHelper.getAsset('init', HSCRIPT));
			initScript.call("init", []);
			initScript.destroy();
		}
		else
			Tools.defaultMenuMusic = "foreverMenu";
	}
}
#end
