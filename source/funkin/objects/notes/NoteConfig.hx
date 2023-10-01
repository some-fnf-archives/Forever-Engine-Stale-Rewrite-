package funkin.objects.notes;

import openfl.Assets as OpenFLAssets;

/**
 * Configuration Typedef for Note Skins
**/
typedef NoteConfigFile = {
	var strums:{
		image:String,
		anims:Array<AnimationConfig>,
		spacing:Null<Int>,
		size:Null<Float>
	};
	var splashes:{
		image:String,
		anims:Array<AnimationConfig>,
		alpha:Null<Float>,
		size:Null<Float>
	};
	var notes:{image:String, anims:Array<AnimationConfig>, size:Null<Float>};
}

/**
 * Configuration Typedef for Animations
**/
typedef AnimationConfig = {
	var name:String;
	var prefix:String;
	var fps:Null<Int>;
	var looped:Bool;
	var ?offsets:{x:Null<Float>, y:Null<Float>};
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
					#if macro
					// IMAGES
					Utils.safeSet(config.notes.image, file.notes.image);
					Utils.safeSet(config.splashes.image, file.splashes.image);
					Utils.safeSet(config.strums.image, file.strums.image);
					// STRUM PARAMETERS
					Utils.safeSet(config.strums.size, file.strums.size);
					Utils.safeSet(config.strums.spacing, file.strums.spacing);
					// NOTE PARAMETERS
					Utils.safeSet(config.notes.size, file.notes.size);
					Utils.safeSet(config.splashes.size, file.splashes.size);
					Utils.safeSet(config.splashes.alpha, file.splashes.alpha);
					Utils.safeSet(config.strums.size, file.strums.size);
					// ANIMATIONS
					Utils.safeSet(config.notes.anims, file.notes.anims);
					Utils.safeSet(config.splashes.anims, file.splashes.anims);
					Utils.safeSet(config.strums.anims, file.strums.anims);
					#end
				}
			}
			catch (e:haxe.Exception)
				trace('[NoteConfig:reloadConfig]: Error! ${e.message}');
		}
	}

	public static function getDummyConfig():NoteConfigFile {
		return {
			strums: {
				image: "default/receptors",
				anims: [
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
				spacing: 160,
				size: 0.7
			},
			notes: {
				image: "default/notes",
				anims: [
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
				size: 0.7
			},
			splashes: {
				image: "default/splashes",
				anims: [
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
				alpha: 0.6,
				size: 1.0
			}
		}
	}
}
