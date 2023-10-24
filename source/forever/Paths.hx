package forever;

import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.media.Sound;

/** Parity with Base Game Paths. **/
class Paths {
	public static inline function getPath(asset:String, ?type:ForeverAsset):String
		return getPreloadPath(asset, type);

	public static inline function getPreloadPath(asset:String, ?type:ForeverAsset):String
		return AssetHelper.getPath(asset, type);

	public static inline function image(image:String):FlxGraphic
		return AssetHelper.getAsset('images/${image}', IMAGE);

	public static inline function getAtlas(image:String):FlxAtlasFrames
		return AssetHelper.getAsset('images/${image}', ATLAS);

	public static inline function getSparrowAtlas(image:String):FlxAtlasFrames
		return AssetHelper.getAsset('images/${image}', ATLAS_SPARROW);

	public static inline function getPackerAtlas(image:String):FlxAtlasFrames
		return AssetHelper.getAsset('images/${image}', ATLAS_PACKER);

	public static inline function font(font:String):String
		return AssetHelper.getAsset('${font}', FONT);

	public static inline function sound(sound:String):Sound
		return AssetHelper.getAsset('audio/sfx/${sound}', SOUND);

	public static inline function music(music:String):Sound
		return AssetHelper.getAsset('audio/bgm/${music}', SOUND);
}

class LocalPaths {
	public var directory:String = "";

	public function new(directory:String):Void {
		this.directory = directory;
	}

	public function getPath(asset:String, ?type:ForeverAsset):String
		return Paths.getPreloadPath(asset, type);

	public function getPreloadPath(asset:String, ?type:ForeverAsset):String
		return Paths.getPreloadPath('${directory}/${asset}', type);

	public function image(image:String):FlxGraphic
		return AssetHelper.getAsset('${directory}/images/${image}', IMAGE);

	public function getAtlas(image:String):FlxAtlasFrames
		return AssetHelper.getAsset('${directory}/images/${image}', ATLAS);

	public function getSparrowAtlas(image:String):FlxAtlasFrames
		return AssetHelper.getAsset('${directory}/images/${image}', ATLAS_SPARROW);

	public function getPackerAtlas(image:String):FlxAtlasFrames
		return AssetHelper.getAsset('${directory}/images/${image}', ATLAS_PACKER);

	public function font(font:String):String
		return AssetHelper.getPath('${directory}/fonts/${font}', FONT);

	public function sound(sound:String):Sound
		return AssetHelper.getAsset('${directory}/audio/sfx/${sound}', SOUND);

	public function music(music:String):Sound
		return AssetHelper.getAsset('${directory}/audio/bgm/${music}', SOUND);
}
