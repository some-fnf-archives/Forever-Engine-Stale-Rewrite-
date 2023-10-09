package forever;

import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.media.Sound;

/** Parity with Base Game Paths. **/
class Paths {
	public static inline function getPath(asset:String, ?type:ForeverAsset):String {
		return getPreloadPath(asset, type);
	}

	public static inline function getPreloadPath(asset:String, ?type:ForeverAsset):String {
		return AssetHelper.getPath(asset, type);
	}

	public static inline function image(image:String):FlxGraphic {
		return AssetHelper.getAsset('images/${image}', IMAGE);
	}

	public static inline function getSparrowAtlas(image:String):FlxAtlasFrames {
		return AssetHelper.getAsset('images/${image}', ATLAS_SPARROW);
	}

	public static inline function getPackerAtlas(image:String):FlxAtlasFrames {
		return AssetHelper.getAsset('images/${image}', ATLAS_PACKER);
	}

	public static inline function sound(sound:String):Sound {
		return AssetHelper.getAsset('sounds/${sound}', SOUND);
	}

	public static inline function music(music:String):Sound {
		return AssetHelper.getAsset('music/${music}', SOUND);
	}
}
