package forever;

import openfl.display.BitmapData;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.utils.Assets as OpenFLAssets;
import openfl.media.Sound;
import openfl.utils.AssetType as FLAssetType;

enum abstract EngineImpl(String) to String {
	/** Forever Engine Implementation Style. **/
	var FOREVER = "forever";

	/** Base Game (pre-0.3) Implementation Style. **/
	var VANILLA_V1 = "vanilla_v1";

	/** Psych Engine Implementation Style. **/
	var PSYCH = "psych";

	/** Codename Engine Implementation Style. **/
	var CODENAME = "codename";

	/** Crow Engine Implementation Style. **/
	var CROW = "crow"; // the engine, not the user. -CrowPlexus

}

class AssetHelper {
	@:noPrivateAccess static var loadedGraphics:Map<String, FlxGraphic> = [];
	@:noPrivateAccess static var loadedSounds:Map<String, Sound> = [];
	@:noPrivateAccess static var currentUsedAssets:Array<String> = [];

	public static function getPath(?asset:String, ?type:ForeverAsset):String {
		return type.getExtension('assets/${asset}');
	}

	public static function getAsset(asset:String, ?type:ForeverAsset):Dynamic {
		var gottenAsset:String = getPath(asset, type);

		return switch (type) {
			case IMAGE: getGraphic('${gottenAsset}');
			case JSON: tjson.TJSON.parse(OpenFLAssets.getText(gottenAsset));
			case FONT: getPath('fonts/${asset}', FONT);
			case ATLAS_SPARROW: FlxAtlasFrames.fromSparrow(getAsset(asset, IMAGE), getPath(asset, XML));
			case ATLAS_PACKER: FlxAtlasFrames.fromSpriteSheetPacker(getAsset(asset, IMAGE), getPath(asset, TEXT));
			default: gottenAsset;
		}
	}

	public static function getGraphic(file:String):FlxGraphic {
		try {
			var bd:BitmapData = OpenFLAssets.getBitmapData(file);

			if (bd != null) {
				var graphic:FlxGraphic = FlxGraphic.fromBitmapData(bd, false, file);
				loadedGraphics.set(file, graphic);
				currentUsedAssets.push(file);
				return graphic;
			}
		}
		catch (e:haxe.Exception)
			trace('[AssetHelper:getGraphic]: Error! "${file}" returned "${e.message}"');

		return null;
	}

	public static function getSound(file:String):Sound {
		try {
			var sound:Sound = OpenFLAssets.getSound(getAsset(file, SOUND));
			loadedSounds.set(file, sound);
			currentUsedAssets.push(file);
			return sound;
		}
		catch (e:haxe.Exception)
			trace('[AssetHelper:getSound]: Error! "${file}" returned "${e.message}"');

		return null;
	}

	public static function clearCacheEntirely(major:Bool = false):Void {
		AssetHelper.clearCachedGraphics(major);
		AssetHelper.clearCachedSounds(major);
		if (major)
			@:privateAccess AssetHelper._clearCacheMajor();
	}

	public static function clearCachedGraphics(force:Bool = false):Void {
		var graphicCounter:Int = 0;

		for (keyGraphic in loadedGraphics.keys()) {
			if (!currentUsedAssets.contains(keyGraphic) || force) {
				var actualGraphic:FlxGraphic = loadedGraphics.get(keyGraphic);

				if (FlxG.bitmap.checkCache(keyGraphic))
					FlxG.bitmap.remove(actualGraphic);

				if (OpenFLAssets.cache.hasBitmapData(keyGraphic))
					OpenFLAssets.cache.removeBitmapData(keyGraphic);

				actualGraphic.destroy();
				loadedGraphics.remove(keyGraphic);
				graphicCounter++;
			}
		}

		trace('cleared ${graphicCounter} graphics from cache.');
	}

	public static function clearCachedSounds(force:Bool = false):Void {
		var soundCounter:Int = 0;

		for (keySound in loadedSounds.keys()) {
			if (!currentUsedAssets.contains(keySound) || force) {
				var actualSound:Sound = loadedSounds.get(keySound);
				actualSound.close();

				if (OpenFLAssets.cache.hasSound(keySound))
					OpenFLAssets.cache.removeSound(keySound);

				loadedSounds.remove(keySound);
				soundCounter++;
			}
		}

		trace('cleared ${soundCounter} sounds from cache.');
	}

	private static function _clearCacheMajor():Void {
		currentUsedAssets = [];
		// Clear the loaded songs as they use the most memory.
		OpenFLAssets.cache.clear('assets/songs');
		// Run the garbage colector.
		openfl.system.System.gc();
	}
}

enum abstract ForeverAsset(String) to String {
	var IMAGE = "image";
	var VIDEO = "video";
	var SOUND = "sound";
	// TEXT
	var XML = "xml";
	var YAML = "yaml";
	var JSON = "json";
	var TEXT = "text";
	var FONT = "font";
	var HSCRIPT = "hscript";
	// ATLASES
	var ATLAS_SPARROW = "atlas-sparrow";
	var ATLAS_PACKER = "atlas-packer";

	public function getExtension(path:String):String {
		var extensionLoader:Array<String> = switch (this) {
			case IMAGE: [".png", ".jpg"];
			case SOUND: [".ogg", ".wav"];
			case VIDEO: [".mp4"];
			case XML: [".xml"];
			case JSON: [".json"];
			case TEXT: [".txt", ".ini", ".cfg"];
			case FONT: [".ttf", ".otf"];
			case HSCRIPT: [".hx", ".hxs", ".hxc", ".hsc", ".hscript", ".hxclass"];
			default: null;
		}

		if (extensionLoader != null) {
			if (extensionLoader.length > 1) {
				for (i in extensionLoader)
					if (OpenFLAssets.exists('${path}${i}', toOpenFL()))
						return '${path}${i}';
			}
			else if (OpenFLAssets.exists('${path}${extensionLoader[0]}', toOpenFL()))
				return '${path}${extensionLoader[0]}';
		}

		return Std.string(path);
	}

	public function toOpenFL():Dynamic {
		return switch (this) {
			case IMAGE: FLAssetType.IMAGE;
			case VIDEO: FLAssetType.MOVIE_CLIP;
			case JSON | YAML | XML | TEXT | HSCRIPT: FLAssetType.TEXT;
			default: FLAssetType.BINARY;
		}
	}
}
