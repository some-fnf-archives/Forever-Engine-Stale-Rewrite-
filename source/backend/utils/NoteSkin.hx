package backend.utils;

class NoteSkin {
    // -- HELPER STUFF -- //

    public static var loadedSkins:Map<String, NoteSkin>;

    public static function preloadSkin(name:String) {
        if (loadedSkins == null) loadedSkins = new Map<String, NoteSkin>();
        if (AssetServer.exists(AssetServer.getRoot('data/noteskins/${name}.json')))
            loadedSkins.set(name, new NoteSkin(name));
        else
            trace("[NoteSkin:preloadSkin()]: attempt to load a skin that doesn't have a configuration file! | for: " + name);
    }

    // -- -- -- -- -- -- //

    public var skin:String = "???";

    public var data = null;
    // public var script:ForeverModule;

    public function new(skin:String) {
        this.skin = skin;

        try { // will do this later @crowplexus
            final leJason:Dynamic = haxe.Json.parse(AssetServer.getCont(AssetServer.getAsset('data/noteskins/$skin.json')));
            if (leJason != null) trace(leJason);
        } catch(e:haxe.Exception) trace('Error: ${e.message}');
    }
}