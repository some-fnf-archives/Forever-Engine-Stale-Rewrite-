package funkin.states.editors.objects;

import flixel.group.FlxSpriteGroup;
import forever.display.ForeverText;

class CharterStatusBar extends FlxSpriteGroup {
	public var bar:FlxSprite;
	public var info:ForeverText;

	public function new(?x:Float = 0, ?y:Float = 0):Void {
		super(x, y);

		bar = new FlxSprite().makeSolid(350, 100, 0xFF303030);
		bar.alpha = 0.8;
		add(bar);

		info = new ForeverText(bar.x + 5, bar.y, bar.width - 5, '- Status Bar Text -', 24);
		info.alignment = LEFT;
		info.centerToObject(bar);
		add(cast(info, FlxSprite));
	}

	/**
	 * Updates the Text of the Status Bar
	**/
	public function updateStatusText(newText:String):Void {
		info.text = newText;
		info.centerToObject(bar);
	}
}
