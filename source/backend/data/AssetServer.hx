package backend.system;

import openfl.utils.Assets;
import openfl.utils.AssetCache;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxFramesCollection;
import flixel.graphics.frames.FlxAtlasFrames;

// TODO: modify openfl assets to make gpu rendered sprites work

class AssetServer {
	public static var cache:Map<String, Dynamic> = [];

	public static function clearCache() {
		for(asset in cache)
			destroyAsset(asset);

		@:privateAccess {
			final assCache = cast(Assets.cache, AssetCache); // lol
			for(key in FlxG.bitmap._cache.keys()) {
				final obj = FlxG.bitmap._cache.get(key);
				if(obj != null) {
					Assets.cache.removeBitmapData(key);
					FlxG.bitmap._cache.remove(key);
					obj.persist = false;
					obj.destroyOnNoUse = true;

					if(obj.bitmap.__texture != null)
						obj.bitmap.__texture.dispose();

					obj.dump();
					obj.destroy();
				}
			}
			for(id in assCache.bitmapData.keys()) {
				final bmp = assCache.bitmapData.get(id);
				if(bmp != null) {
					if(bmp.__texture != null)
						bmp.__texture.dispose();

					bmp.dispose();
					bmp.disposeImage();
				}
				assCache.removeBitmapData(id);
			}
			for(id in assCache.sound.keys())
				assCache.removeSound(id);
		}

		cache.clear();
	}

	public static function destroyAsset(asset:Dynamic) {
		switch(Type.typeof(asset)) {
			case TClass(FlxGraphic):
				final graph:FlxGraphic = cast asset;
				graph.persist = false;
				graph.destroyOnNoUse = true;

				@:privateAccess
				if(graph.bitmap.__texture != null)
					graph.bitmap.__texture.dispose();

				graph.dump();
				graph.destroy();

			case TClass(FlxFramesCollection), TClass(FlxAtlasFrames):
				final atlas:FlxFramesCollection = cast asset;
				if(atlas.parent != null)
					destroyAsset(atlas.parent);

				atlas.destroy();

			default:
		}
	}
}