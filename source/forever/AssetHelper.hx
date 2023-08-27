package forever;

import flixel.graphics.frames.FlxAtlasFrames;
import openfl.Assets as OpenFLAssets;
import openfl.utils.AssetType;

class AssetHelper {
	public static function getPath(?asset:String, ?type:ForeverAsset):String {
		var base:String = "assets";
		return type.getExtension('${base}/${asset}');
	}

	public static function getAsset(asset:String, ?type:ForeverAsset):Dynamic {
		return switch (type) {
			case JSON: tjson.TJSON.parse(OpenFLAssets.getText(getPath('${asset}', JSON)));
			case FONT: getPath('fonts/${asset}', FONT);
			case ATLAS_SPARROW: FlxAtlasFrames.fromSparrow(getAsset(asset, IMAGE), getAsset(asset, XML));
			case ATLAS_PACKER: FlxAtlasFrames.fromSpriteSheetPacker(getAsset(asset, IMAGE), getAsset(asset, TEXT));
			default: getPath(asset, type);
		}
	}
}

enum abstract ForeverAsset(String) to String {
	var IMAGE = "image";
	var VIDEO = "video";
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
					if (OpenFLAssets.exists('${path}${i}'))
						return '${path}${i}';
			}
			else if (OpenFLAssets.exists('${path}${extensionLoader[0]}'))
				return '${path}${extensionLoader[0]}';
		}

		return Std.string(path);
	}

	public function toOpenFL():Dynamic {
		return switch (this) {
			case IMAGE: AssetType.IMAGE;
			case VIDEO: AssetType.MOVIE_CLIP;
			case JSON | YAML | XML | TEXT | HSCRIPT: AssetType.TEXT;
			default: AssetType.BINARY;
		}
	}
}
