package funkin.states.subStates;

import flixel.FlxSubState;
import funkin.objects.notes.Note;

class NoteConfigurator extends FlxSubState {
	public var notesShown:Array<Note> = [];
	public var skinsNamed:Array<String> = ["default"];

	public function new():Void {
		super();

		// -- CREATE BACKGROUND -- //
		var bg1:FlxSprite;
		var bg2:FlxSprite;

		add(bg1 = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK));
		add(bg2 = new FlxSprite().loadGraphic(AssetHelper.getAsset("images/menus/bgBlack", IMAGE)));

		bg2.blend = DIFFERENCE;
		bg1.alpha = 0.7;
		bg2.alpha = 0.07;
	}

	public override function update(elapsed:Float):Void {
		super.update(elapsed);

		if (FlxG.keys.justPressed.ESCAPE) {
			FlxG.state.persistentUpdate = true;
			close();
		}
	}
}
