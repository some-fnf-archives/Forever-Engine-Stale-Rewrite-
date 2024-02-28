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

  public static inline function chart(name: String, difficulty: String = "normal", ?group: String) {
    var path: String = AssetServer.getRoot('game/charts/$name/$difficulty', JSON, group);
    if (!AssetServer.exists(path)) {
      var legacyPath: String = path.replace('/$difficulty', '$name-$difficulty');
      if (AssetServer.exists(legacyPath))
        path = legacyPath;
      else
        path = legacyPath.replace('-$difficulty', '');
    }
    return path;
  }
}
