package funkin.components.ui;

import flixel.group.FlxSpriteGroup;
import flixel.ui.FlxBar;
import forever.display.ForeverSprite;

/**
 * Health Bar class handles an alternative to FlxBar that can easily have its colors changed  and tweened
 * use this if you wish to create any additional bars on the Heads-Up Display
 * WIP
**/
class HealthBar extends FlxSpriteGroup {
	public var bg:ForeverSprite;
	public var bar:FlxBar;

	public function new(x:Float, y:Float, fillDirection:FlxBarFillDirection = RIGHT_TO_LEFT):Void {
		super(x, y);

		// doing custom stuff later, this should work for now.
		add(bg = new ForeverSprite(0, 0, "images/ui/normal/healthBar"));
		add(bar = new FlxBar(5, 5, fillDirection, Std.int(bg.width - 10), Std.int(bg.height - 9)));

		bar.createFilledBar(0xFFFF0000, 0xFF66FF33);

		width = bg.width;
		height = bg.height;
	}
}
