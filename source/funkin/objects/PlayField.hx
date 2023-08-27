package funkin.objects;

import flixel.group.FlxGroup;
import funkin.objects.notes.*;

/**
 * Play Field contains basic objects to handle gameplay
 * including notefields and a Heads-Up Display
**/
class PlayField extends FlxGroup {
	public var strums:FlxTypedGroup<NoteField>;

	public function new():Void {
		super();

		add(strums = new FlxTypedGroup<NoteField>());
		strums.add(new NoteField(100, 100, "default"));
	}
}
