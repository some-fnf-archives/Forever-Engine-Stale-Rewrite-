package funkin.states;

import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxColor;
import funkin.objects.*;
import funkin.ui.HUD;

class PlayState extends FlxState {
	public var hud:HUD;
	public var playField:PlayField;

	public override function create():Void {
		super.create();

		add(hud = new HUD());
		add(playField = new PlayField());
	}

	public override function update(elapsed:Float):Void {
		super.update(elapsed);

		if (flixel.FlxG.keys.justPressed.R) {
			trace("reset");
			flixel.FlxG.resetState();
		}
	}
}
