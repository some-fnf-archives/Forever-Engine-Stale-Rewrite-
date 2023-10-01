package forever;

import openfl.display.BitmapData;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.Assets as OpenFLAssets;
import openfl.media.Sound;
import openfl.utils.AssetType as FLAssetType;

class AssetHelper {
	static var loadedGraphics:Map<String, FlxGraphic> = [];
	static var loadedSounds:Map<String, Sound> = [];

	public static function getPath(?asset:String, ?type:ForeverAsset):String {
		var pathReturn:String = "assets";

		var pathFormatted:String = type.getExtension('${pathReturn}/${asset}');
		if (OpenFLAssets.exists(pathFormatted))
			pathReturn = pathFormatted;

		return pathReturn;
	}

	public static function getAsset(asset:String, ?type:ForeverAsset):Dynamic {
		var gottenAsset:String = getPath(asset, type);

		return switch (type) {
			case IMAGE: getGraphic('${gottenAsset}');
			case JSON: tjson.TJSON.parse(OpenFLAssets.getText(getPath('${asset}', JSON)));
			case FONT: getPath('fonts/${asset}', FONT);
			case ATLAS_SPARROW: FlxAtlasFrames.fromSparrow(getAsset(asset, IMAGE), getAsset(asset, XML));
			case ATLAS_PACKER: FlxAtlasFrames.fromSpriteSheetPacker(getAsset(asset, IMAGE), getAsset(asset, TEXT));
			default: gottenAsset;
		}
	}

	public static function getGraphic(file:String):FlxGraphic {
		try {
			var bd:BitmapData = OpenFLAssets.getBitmapData(file);

			if (bd != null) {
				var graphic:FlxGraphic = FlxGraphic.fromBitmapData(bd, false, file);
				loadedGraphics.set(file, graphic);
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
			return sound;
		}
		catch (e:haxe.Exception)
			trace('[AssetHelper:getSound]: Error! "${file}" returned "${e.message}"');

		return null;
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
