package objects;

import backend.utils.ForeverSprite;

class Receptor extends ForeverSprite {
	public var direction:Int;
	public var skin(default, set):String;

	public var directionStr(get, never):String;
	public var colorStr    (get, never):String;

	public function new(x:Float = 0, y:Float = 0, direction:Int, ?skin:String = "base") {
		super(x, y);
		this.direction = direction;
		this.skin = skin;
	}

	// ----------------- //
	// Getters & Setters //
	// ----------------- //

	@:noCompletion
	private inline function set_skin(newSkin:String):String {
		switch(newSkin) {
			case "base":
				frames = AssetServer.getAsset("game/noteskins/notes/base/sheet", SPARROW);
				animation.addByPrefix("static", 'arrow static instance ${direction}', 0, false);
				animation.addByPrefix("press" , '${directionStr} press instance ${direction}', 24, false);
				animation.addByPrefix("hit"   , '${directionStr} confirm instance ${direction}', 24, false);
				playAnim("static", true);
		}
		return skin = newSkin;
	}

	@:noCompletion
	private inline function get_directionStr() {
		return ["left", "down", "up", "right"][direction % 4];
	}

	@:noCompletion
	private inline function get_colorStr() {
		return ["purple", "blue", "green", "red"][direction % 4];
	}
}