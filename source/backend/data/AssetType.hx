package backend.data;

import haxe.io.Path;

enum abstract AssetType(String) from String to String {
	var _ = "";

	var IMAGE = "image";
	var SOUND = "sound";
	var VIDEO = "video";
    var FONT  = "font" ;

    var SPARROW = "sparrow";
    var PACKER  = "packer" ;
    var ANIMATE = "animate";

    // * Text Files * //
    var TXT = "txt"  ;
    var XML = "xml"  ;
    var JSON = "json";

	public inline function getExtensions(path:String) {
		var ret:String = path;
		final extensions:Array<String> = switch (this) {
			case IMAGE: [".png"];
			case SOUND: [".ogg", ".wav"];
            case TXT  : [".txt", ".cfg", ".ini"];
            case FONT : [".ttf", ".otf"];
            case JSON : [".json"];
            case XML  : [".xml"];
			case VIDEO: [".mp4"];
            default: [];
		}
        if (Path.extension(path) == "") {
            if (extensions.length == 1) {
                if (sys.FileSystem.exists('${path}${extensions[0]}'))
                    ret = '${path}${extensions[0]}';
            } else {
                for (i in 0...extensions.length) {
                    if (sys.FileSystem.exists('${path}${extensions[i]}')) {
                        ret = '${path}${extensions[i]}';
                        break;
                    }
                }
            }
        }
		return ret;
	}
}
