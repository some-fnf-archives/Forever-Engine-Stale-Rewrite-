package funkin.objects.notes;

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
	// ANIMATIONS
	var noteAnims:Array<AnimationConfig>;
	var splashAnims:Array<AnimationConfig>;
	var strumAnims:Array<AnimationConfig>;
}

/**
 * Configuration Typedef for Animations
**/
typedef AnimationConfig = {
	var name:String;
	var prefix:String;
	var fps:Int;
	var looped:Bool;
	var ?offsets:{x:Float, y:Float};
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
				file = AssetHelper.getAsset('data/notes/${skin}', JSON);
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
					// ANIMATIONS
					Utils.safeSet(config.noteAnims, file.noteAnims);
					Utils.safeSet(config.splashAnims, file.splashAnims);
					Utils.safeSet(config.strumAnims, file.strumAnims);
				}
			}
			catch (e:haxe.Exception)
				trace('Unexpected Error when setting up note skinning, error: ${e.message}');
		}
	}

	public static function getDummyConfig():NoteConfigFile {
		return {
			splashImage: "default/splashes",
			strumImage: "default/receptors",
			noteImage: "default/notes",

			strumSize: 0.7,
			strumSpacing: 160,

			noteSize: 0.7,
			splashSize: 1.0,
			splashAlpha: 0.6,

			strumAnims: [
				{
					name: "static",
					prefix: "${dir} static",
					fps: 24,
					looped: false
				},
				{
					name: "pressed",
					prefix: "${dir} press",
					fps: 24,
					looped: false
				},
				{
					name: "confirm",
					prefix: "${dir} confirm",
					fps: 24,
					looped: false
				}
			],

			noteAnims: [
				{
					name: "scroll",
					prefix: "${dir}0",
					fps: 24,
					looped: false
				},
				{
					name: "hold",
					prefix: "${dir} hold piece",
					fps: 24,
					looped: false
				},
				{
					name: "end",
					prefix: "${dir} hold end",
					fps: 24,
					looped: false
				}
			],

			splashAnims: [
				{
					name: "1",
					prefix: "${dir}1",
					fps: 24,
					looped: false
				},
				{
					name: "2",
					prefix: "${dir}2",
					fps: 24,
					looped: false
				}
			],
		}
	}
}
