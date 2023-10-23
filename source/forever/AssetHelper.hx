package forever;

import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import forever.data.Mods;
import haxe.io.Path;
import openfl.display.BitmapData;
import openfl.media.Sound;
import openfl.utils.AssetType as FLAssetType;
import openfl.utils.Assets as OpenFLAssets;

/**
 * Helper Enum for Engine Names, used for conversion methods
 * in order to provide greater compatibility with other FNF Engines.
**/
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

/** Asset Helper Class, handles asset loading and caching. **/
class AssetHelper {
	@:noPrivateAccess static var loadedGraphics:Map<String, FlxGraphic> = [];
	@:noPrivateAccess static var loadedSounds:Map<String, Sound> = [];
	@:noPrivateAccess static var currentUsedAssets:Array<String> = [];

	public static var excludedGraphics:Map<String, FlxGraphic> = [];
	public static var excludedSounds:Map<String, Sound> = [];

	public static var searchLevel:String = "";

	/**
	 * Creates a formatted asset path with an extension if needed
	 * use this in case you do not wish to cache your assets and instead just grab their base path.
	 * @param asset 			Asset name/folder name you want to format.
	 * @param type 				Type of asset, is unspecified, file extensions won't be added to the formatted path.
	 * @return String
	**/
	public static function getPath(?asset:String, ?type:ForeverAsset):String {
		var gottenPath:String = type.getExtension('assets/${asset}');
		#if MODS
		if (searchLevel != null && searchLevel != "") {
			final modPath:String = type.getExtension('${Mods.MODS_FOLDER}/${searchLevel}/${asset}');
			if (Utils.fileExists(modPath))
				gottenPath = modPath;
		}
		#end
		return gottenPath;
	}

	/**
	 * As the name implies, this allows you to grab specifically assets with their specified type,
	 * unlike `getPath`, this returns the actual object of an asset and also caches it.
	 * Example:
	 * ```haxe
	 * var myGraphic = AssetHelper.getAsset('images/myImage', IMAGE); // flixel.graphics.FlxGraphic
	 * var mySound = AssetHelper.getAsset('sounds/mySound', SOUND); // openfl.media.Sound
	 * ```
	 * @param asset 			Asset name you want to grab.
	 * @param type 				Type of asset, to append extensions and get the asset you want.
	 * @return Dynamic
	**/
	public static function getAsset(asset:String, ?type:ForeverAsset):Dynamic {
		var gottenAsset:String = getPath(asset, type);

		return switch (type) {
			case IMAGE: getGraphic(gottenAsset);
			case FONT: return getPath('fonts/${asset}', FONT);
			case JSON:
				var json:String = Utils.getText(gottenAsset).trim();
				while (!json.endsWith("}")) // ensure its not broken.
					json = json.substr(0, json.length - 1);
				tjson.TJSON.parse(json);
			case ATLAS:
				var txtPath:String = getPath('${asset}.txt', TEXT);
				if (Utils.fileExists(txtPath, TEXT)) return getAsset(asset, ATLAS_PACKER); else return getAsset(asset, ATLAS_SPARROW);
			case ATLAS_SPARROW: FlxAtlasFrames.fromSparrow(getAsset(asset, IMAGE), getPath(asset + ".xml"));
			case ATLAS_PACKER: FlxAtlasFrames.fromSpriteSheetPacker(getAsset(asset, IMAGE), getPath(asset + ".txt"));
			default: gottenAsset;
		}
	}

	/**
	 * Internal Usage and Caching, use this only when absolutely necessary
	 * @param file 				File to extract the graphic from
	 * @param customKey 		What to save this file in the cache as
	**/
	public static function getGraphic(file:String, ?customKey:String = null):FlxGraphic {
		try {
			final keyName:String = customKey != null ? customKey : file;
			// prevent remapping
			if (loadedGraphics.get(keyName) != null)
				return loadedGraphics.get(keyName);

			final bd:BitmapData = #if sys BitmapData.fromFile(file) #else OpenFLAssets.getBitmapData(file) #end;

			if (bd != null) {
				final graphic:FlxGraphic = FlxGraphic.fromBitmapData(bd, false, file);
				loadedGraphics.set(keyName, graphic);
				currentUsedAssets.push(keyName);
				return graphic;
			}
		}
		catch (e:haxe.Exception)
			trace('[AssetHelper:getGraphic]: Error! "${file}" returned "${e.message}"');

		return null;
	}

	/**
	 * Internal Usage and Caching, use this only when absolutely necessary
	 * @param file 				File to extract the sound from
	 * @param customKey 		What to save this file in the cache as
	**/
	public static function getSound(file:String, ?customKey:String = null):Sound {
		try {
			final keyName:String = customKey != null ? customKey : file;
			// prevent remapping
			if (loadedSounds.get(keyName) != null)
				return loadedSounds.get(keyName);

			final snd:String = getAsset(file, SOUND);
			final sound:Sound = #if sys Sound.fromFile(snd) #else OpenFLAssets.getSound(snd) #end;
			loadedSounds.set(keyName, sound);
			currentUsedAssets.push(keyName);
			return sound;
		}
		catch (e:haxe.Exception)
			trace('[AssetHelper:getSound]: Error! "${file}" returned "${e.message}"');

		return null;
	}

	@:dox(hide) static function clearCacheEntirely(major:Bool = false):Void {
		clearCachedGraphics(major);
		clearCachedSounds(major);
		if (major)
			_clearCacheMajor();
	}

	@:dox(hide) static function clearCachedGraphics(force:Bool = false):Void {
		var graphicCounter:Int = 0;

		for (keyGraphic in loadedGraphics.keys()) {
			if (excludedGraphics.get(keyGraphic) != null)
				continue;

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

	@:dox(hide) static function clearCachedSounds(force:Bool = false):Void {
		var soundCounter:Int = 0;

		for (keySound in loadedSounds.keys()) {
			if (excludedSounds.get(keySound) != null)
				continue;

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

/**
 * Abstract that defines asset types with functions to get the extensions
 * for a given asset type.
**/
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
	var ATLAS = "atlas";
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

		if (extensionLoader != null && Path.extension(path) == "") {
			if (extensionLoader.length > 1) {
				for (i in extensionLoader) {
					if (Utils.fileExists('${path}${i}', toOpenFL()))
						path = '${path}${i}';
				}
			}
			else {
				var thing:String = '${path}${extensionLoader[0]}';
				if (Utils.fileExists(thing, toOpenFL()))
					path = thing;
			}
		}

		return path;
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
