package funkin.objects;

import funkin.states.PlayState;
import flixel.group.FlxGroup;
import funkin.components.ChartLoader.Chart;
import funkin.objects.notes.*;

/**
 * Play Field contains basic objects to handle gameplay
 * Note Fields, Notes, etc.
**/
class PlayField extends FlxGroup {
	public var noteFields:Array<NoteField> = [];
	public var playerField:NoteField;
	public var enemyField:NoteField;

	public var noteSpawner:NoteSpawner;

	public function new():Void {
		super();

		var strumY:Float = Settings.downScroll ? FlxG.height - 150 : 50;

		add(enemyField = new NoteField(this, 98, strumY, "default", true));
		add(playerField = new NoteField(this, FlxG.width - 542, strumY, "default", false));
		add(noteSpawner = new NoteSpawner(Chart.current.notes.length));

		// I know this is dumb as shit and I should just make a group but I don't wanna lol
		forEachOfType(NoteField, function(n:NoteField) noteFields.push(n));

		for (i in 0...Chart.current.notes.length)
			noteSpawner.noteList[i] = Chart.current.notes[i];
	}

	public override function destroy():Void {
		for (noteField in noteFields)
			noteField.destroy();
		noteSpawner.destroy();
		super.destroy();
	}

	public override function update(elapsed:Float):Void {
		super.update(elapsed);

		if (noteSpawner.curNoteData != null) {
			var nf:NoteField = noteFields[noteSpawner.curNoteData?.notefield ?? -1];
			if (nf != null)
				noteSpawner.spawnNotes(nf);
		}
	}
}
