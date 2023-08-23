package funkin.objects;

import flixel.group.FlxGroup.FlxTypedGroup;
import forever.ForeverSprite;

class Strum extends ForeverSprite {
	public function new(x:Float, y:Float, skin:String = "default", id:Int):Void {
		super(x, y);
		this.ID = id;

		frames = AssetHelper.getAsset('images/notes/${NoteConfig.config.strumImage}', ATLAS_SPARROW);
	}
}

class NoteField extends FlxTypedGroup<Strum> {
	public var size:Float = 0.7;
	public var spacing:Int = 160;

	// why not stop using the name swagWidth
	public var fieldWidth(get, never):Float;
	public var skin:String = "default";

	public function new(x:Float, y:Float, skin:String = "default"):Void {
		super();

		this.skin = skin;
	}

	public function regenStrums(x:Float = 0, y:Float = 0):Void {
		for (i in 0...4) {
			var strum:Strum = new Strum(x * (fieldWidth), y, skin, i);
		}
	}

	@:dox(hide) @:noCompletion function get_fieldWidth():Float
		return spacing * size;
}
