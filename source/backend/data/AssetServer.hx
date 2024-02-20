package backend.data;

import backend.data.AssetType;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxFramesCollection;
import openfl.utils.AssetCache;
import openfl.utils.Assets;

// TODO: modify openfl assets to make gpu rendered sprites work

class AssetServer {
  public static var cache:Map<String, Dynamic> = [];

  public static inline function getRoot(?asset: String, ?type: AssetType, ?group: String) {
    var directory: String = "assets/";
    if (group != null && group.length != 0) directory += '$group/';
    if (asset != null && asset.length != 0) directory += '$asset';
    return type.getExtensions(directory);
  }

  public static inline function getAsset(asset: String, ?type: AssetType, ?group: String): Dynamic {
    final root: String = getRoot(asset, type, group);

    return switch (type) {
      // case IMAGE: AssetServer.generateImage();
      case SPARROW: FlxAtlasFrames.fromSparrow(getAsset(asset, IMAGE), getRoot(asset, XML));
      case PACKER : FlxAtlasFrames.fromSpriteSheetPacker(getAsset(asset, IMAGE), getRoot(asset, TXT));
      default: root;
    }
  }

  public static function exists(asset: String) {
    final existanceCheck:String->Bool = #if sys sys.FileSystem.exists #else openfl.utils.Assets.exists #end;
    return existanceCheck(asset);
  }

  public static function getCont(asset: String) {
    final contentGetter:String->String = #if sys sys.io.File.getContent #else openfl.utils.Assets.getText #end;
    return contentGetter(asset);
  }

  public static function clearCache() {
    for(asset in cache) destroyAsset(asset);

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
