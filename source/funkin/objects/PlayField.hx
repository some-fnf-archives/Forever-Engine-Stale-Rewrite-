package funkin.objects;

import flixel.group.FlxGroup;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import funkin.components.ChartLoader.Chart;
import funkin.components.ChartLoader.NoteData;
import funkin.objects.notes.*;
import haxe.ds.Vector;

/**
 * Play Field contains basic objects to handle gameplay
 * Note Fields, Notes, etc.
**/
class PlayField extends FlxGroup {
	public var noteFields:Array<NoteField> = [];
	public var playerField:NoteField;
	public var enemyField:NoteField;

	public var noteGroup:FlxTypedSpriteGroup<Note>;

	public var noteList:Vector<NoteData>;
	public var curNote:Int = 0;

	public function new():Void {
		super();

		var strumY:Float = Settings.downScroll ? FlxG.height - 150 : 50;

		add(enemyField = new NoteField(this, 98, strumY, "default", true));
		add(playerField = new NoteField(this, FlxG.width - 542, strumY, "default", false));

		if(Settings.centerNotefield){
			for (i in 0...playerField.members.length){
				enemyField.visible = false;
				playerField.members[i].x = 420 + 112*i;
			}
		}

		add(noteGroup = new FlxTypedSpriteGroup<Note>());

		noteList = new Vector<NoteData>(Chart.current.notes.length);
		// allocate notes before beginning
		noteGroup.add(new Note());

		// I know this is dumb as shit and I should just make a group but I don't wanna lol
		forEachOfType(NoteField, function(n:NoteField) noteFields.push(n));
		// also arrays are just easier to iterate !!!

		for (i in 0...Chart.current.notes.length)
			noteList[i] = Chart.current.notes[i];
	}

	public override function destroy():Void {
		for (noteField in noteFields)
			noteField.destroy();
		noteGroup.destroy();
		super.destroy();
	}

	public override function update(elapsed:Float):Void {
		super.update(elapsed);

		while (noteGroup != null && noteList.length != 0 && curNote < noteList.length) {
			final target:NoteField = noteFields[noteList[curNote].notefield];
			final timeDifference:Float = noteList[curNote].time - Conductor.time;

			if (noteList[curNote] == null || target == null || timeDifference > 1.8) // 1800
				return;

			var epicNote:Note = noteGroup.recycle(Note).appendData(noteList[curNote]);
			epicNote.parent = target;
			epicNote.visible = target.visible;
			add(epicNote);

			curNote += 1;
		}
	}
}
