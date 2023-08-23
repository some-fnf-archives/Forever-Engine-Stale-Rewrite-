package funkin.objects;

import openfl.Assets as OpenFLAssets;

/**
 * Configuration Typedef for Note Skins
**/
typedef NoteConfigFile = {
	var ?strumSize:Float;
	var ?strumSpacing:Int;
	var ?strumImage:String;
	// NOTES
	var ?noteSize:Float;
	var ?noteImage:String;
	// SPLASHES
	var ?splashSize:Float;
	var ?splashAlpha:Float;
	var ?splashImage:String;
}

/**
 * Configuration Typedef for Animations
**/
typedef AnimationConfig = {
	var name:String;
	var prefix:String;
	var fps:Int;
	var looped:Bool;
}

/**
 * Sets up configuration for Note Skins
**/
class NoteConfig {
	/**
	 * Current Loaded Configuration File
	**/
	public static var config:NoteConfigFile;

	public static function reloadConfig(skin:String = "default"):Void {
		config = getDummyConfig();

		var file:Null<NoteConfigFile> = null;

		if (OpenFLAssets.exists(AssetHelper.getPath('data/notes/${skin}', JSON))) {
			try {
				file = AssetHelper.getAsset('data/notes/${skin}.json', JSON);
				if (file != null) {
					// IMAGES
					Utils.safeSet(config.strumImage, file.strumImage);
					Utils.safeSet(config.noteImage, file.noteImage);
					Utils.safeSet(config.splashImage, file.splashImage);
					// STRUM PARAMETERS
					Utils.safeSet(config.strumSize, file.strumSize);
					Utils.safeSet(config.strumSpacing, file.strumSpacing);
					// NOTE PARAMETERS
					Utils.safeSet(config.noteSize, file.noteSize);
					Utils.safeSet(config.splashSize, file.splashSize);
					Utils.safeSet(config.splashAlpha, file.splashAlpha);
				}
			}
			catch (e:haxe.Exception)
				trace('Unexpected Error when setting up note skinning, error: ${e.details()}');
		}
	}

	public static function getDummyConfig():NoteConfigFile {
		return {
			// NOTE FIELD STRUMS
			strumSize: 0.7,
			strumSpacing: 160,
			strumImage: "receptors",
			// NORMAL NOTES
			noteSize: 0.7,
			noteImage: "notes",
			// NOTE SPLASHES
			splashSize: 1.0,
			splashAlpha: 0.6,
			splashImage: "splashes",
		}
	}
}
