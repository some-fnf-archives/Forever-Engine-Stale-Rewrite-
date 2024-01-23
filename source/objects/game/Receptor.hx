package objects.game;

class Receptor extends FlxSprite {
	public var direction:Int;
	public var skin(default, set):String;

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
				
		}
		return skin = newSkin;
	}
}