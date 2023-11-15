package funkin.ui;

import haxe.ds.StringMap;

/** Generic Skin Config Model. **/
typedef GenericSkin = {
	var image:String;
	var animations:Array<AnimationConfig>;
	var size:Null<Float>;
}

/** Configuration Typedef for Animations. **/
typedef AnimationConfig = {
	var name:String;
	var prefix:String;
	var fps:Null<Int>;
	var looped:Bool;
	var ?offsets:{x:Null<Float>, y:Null<Float>};
}

/** Handler for Note Skins. **/
class NoteSkin {
	/** String Map that stores already loaded noteskins, used for precaching. **/
	public static var skinsLoaded:StringMap<NoteSkin>;

	public var name:String;

	public var strums:{spacing:Null<Int>} & GenericSkin;
	public var splashes:{alpha:Null<Float>} & GenericSkin;
	public var notes:{?sustain:String} & GenericSkin;

	public function new(name:String):Void {
		skinsLoaded = new StringMap<NoteSkin>();
		loadSkin(name);
	}

	public function loadSkin(v:String):Void {
		this.name = v;

		if (skinsLoaded.exists(v) && skinsLoaded.get(v) != null) {
			strums = skinsLoaded.get(v).strums;
			notes = skinsLoaded.get(v).notes;
			splashes = skinsLoaded.get(v).splashes;
			return;
		}

		var dum:Dynamic = dummy();
		var yamlData = AssetHelper.parseAsset('data/ui/${name}', YAML);

		if (yamlData == null) {
			trace("[FunkinSkin:new()]: Unexpected error when loading skin data -> Null Object Reference");
			trace("[FunkinSkin:new()]: Loading Default Skin...");
			name = "normal";

			strums = dum.strums;
			notes = dum.notes;
			splashes = dum.splashes;
			skinsLoaded.set(name, this);
		}
		else {
			strums = yamlData.noteConfig.strums ?? dum.strums;
			notes = yamlData.noteConfig.notes ?? dum.notes;
			splashes = yamlData.noteConfig.splashes ?? dum.splashes;
			skinsLoaded.set(v, this);
		}
	}

	public static function dummy():Dynamic {
		return {
			strums: {
				image: "default/receptors",
				animations: [
					{name: "static", prefix: "${dir} static", fps: 24, looped: false},
					{name: "pressed", prefix: "${dir} press", fps: 24, looped: false},
					{name: "confirm", prefix: "${dir} confirm", fps: 24, looped: false}
				],
				spacing: 160,
				size: 0.7
			},
			notes: {
				image: "default/notes",
				animations: [
					{name: "scroll", prefix: "${dir}0", fps: 24, looped: false},
					{name: "hold", prefix: "${dir} hold piece", fps: 24, looped: false},
					{name: "end", prefix: "${dir} hold end", fps: 24, looped: false}
				],
				size: 0.7
			},
			splashes: {
				image: "default/splashes",
				animations: [
					{name: "1", prefix: "${dir}1", fps: 24, looped: false},
					{name: "2", prefix: "${dir}2", fps: 24, looped: false}
				],
				alpha: 0.6,
				size: 1.0
			}
		}
	}
}
