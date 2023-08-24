package funkin.states;

import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxColor;
import funkin.objects.NoteField;
import funkin.ui.HUD;

class PlayState extends FlxState {
	public var hud:HUD;

	public var strums:FlxTypedGroup<NoteField>;

	var test:FlxSprite;

	public override function create():Void {
		super.create();

		add(hud = new HUD());

		// speaking of, should I switch to codename flixel?
		// your choice
		test = new FlxSprite().makeGraphic(100, 100);
		test.screenCenter();
		add(test);
	}

	public override function update(elapsed:Float):Void {
		super.update(elapsed);

		test.color = 0;
		// ohh current isnt set
		if (Controls.DOWN)
			test.color = FlxColor.BLUE;
		if (Controls.UP)
			test.color = FlxColor.GREEN;
		if (Controls.RIGHT)
			test.color = FlxColor.RED;
		if (Controls.LEFT)
			test.color = FlxColor.PURPLE;
	}
}
