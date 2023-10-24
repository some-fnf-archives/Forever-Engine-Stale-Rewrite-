package funkin.objects.notes;

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
	@:optional var type:Int;
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

		if (Tools.fileExists(AssetHelper.getPath('data/notes/${skin}', TEXT))) {
			try {
				file = AssetHelper.parseAsset('data/notes/${skin}', JSON);
				if (file != null) {
					#if macro
					// IMAGES
					Tools.safeSet(config.notes.image, file.notes.image);
					Tools.safeSet(config.splashes.image, file.splashes.image);
					Tools.safeSet(config.strums.image, file.strums.image);
					// STRUM PARAMETERS
					Tools.safeSet(config.strums.size, file.strums.size);
					Tools.safeSet(config.strums.spacing, file.strums.spacing);
					// NOTE PARAMETERS
					Tools.safeSet(config.notes.size, file.notes.size);
					Tools.safeSet(config.splashes.size, file.splashes.size);
					Tools.safeSet(config.splashes.alpha, file.splashes.alpha);
					Tools.safeSet(config.strums.size, file.strums.size);
					// ANIMATIONS
					Tools.safeSet(config.notes.anims, file.notes.anims);
					Tools.safeSet(config.splashes.anims, file.splashes.anims);
					Tools.safeSet(config.strums.anims, file.strums.anims);
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
						type: 0,
						looped: false
					},
					{
						name: "pressed",
						prefix: "${dir} press",
						fps: 24,
						type: 1,
						looped: false
					},
					{
						name: "confirm",
						prefix: "${dir} confirm",
						fps: 24,
						type: 2,
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
						type: 0,
						looped: false
					},
					{
						name: "hold",
						prefix: "${dir} hold piece",
						fps: 24,
						type: 1,
						looped: false
					},
					{
						name: "end",
						prefix: "${dir} hold end",
						fps: 24,
						type: 2,
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
