package backend.data;

/**
 * Retrocompatibility with Base Game (sort of).
 **/
class Paths {
  // --- for convenience --- //
  public static inline function getPath(asset: String, ?group: String) {
    return AssetServer.getRoot(asset, null, group);
  }

  public static inline function getPreloadPath(asset: String, ?group: String) {
    return AssetServer.getRoot(asset, null, group);
  }

  public static inline function getSharedPath(asset: String, ?group: String) {
    return AssetServer.getRoot(asset, null, group);
  }
  // --- --- --- --- --- --- //

  public static inline function font(asset: String, ?group: String) {
    return AssetServer.getAsset(asset, FONT, group);
  }

  public static inline function image(asset: String, ?group: String) {
    return AssetServer.getAsset(asset, IMAGE, group);
  }

  // mostly for convenience.
  public static function getAtlas(asset: String, ?group: String) {
    if (sys.FileSystem.exists(AssetServer.getRoot('${asset}.txt', null, group)))
      return AssetServer.getAsset(asset, PACKER, group);
    return AssetServer.getAsset(asset, SPARROW, group);
  }

  public static inline function getSparrowAtlas(asset: String, ?group: String) {
    return AssetServer.getAsset(asset, SPARROW, group);
  }

  public static inline function getPackerAtlas(asset: String, ?group: String) {
    return AssetServer.getAsset(asset, PACKER, group);
  }

  public static inline function music(asset: String, ?group: String) {
    return AssetServer.getAsset(asset, SOUND, group);
  }

  public static inline function sound(asset: String, ?group: String) {
    return AssetServer.getAsset(asset, SOUND, group);
  }

  public static inline function soundRandom(asset: String, min: Int = 0, ?max: Int = 1, ?group: String) {
    return AssetServer.getAsset(asset + FlxG.random.int(min, max), SOUND, group);
  }
}
