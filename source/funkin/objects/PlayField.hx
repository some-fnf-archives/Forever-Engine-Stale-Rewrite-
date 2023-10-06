package funkin.objects;

import flixel.group.FlxGroup;
import funkin.components.ChartLoader.Chart;
import funkin.objects.notes.*;

/**
 * Play Field contains basic objects to handle gameplay
 * Notefeilds, Notes, etc.
**/
class PlayField extends FlxGroup {
	public var lanes:FlxTypedGroup<NoteField>;
	public var playerLane:NoteField;
	public var enemyLane:NoteField;

	public var noteSpawner:NoteSpawner;

	public function new():Void {
		super();

		var strumY:Float = Settings.downScroll ? FlxG.height - 150 : 50;

		add(lanes = new FlxTypedGroup<NoteField>());
		add(noteSpawner = new NoteSpawner(Chart.current.notes.length));

		lanes.add(enemyLane = new NoteField(98, strumY, "default"));
		lanes.add(playerLane = new NoteField(FlxG.width - 542, strumY, "default"));

		for (i in 0...Chart.current.notes.length)
			noteSpawner.noteList[i] = Chart.current.notes[i];
	}

	public override function update(elapsed:Float):Void {
		super.update(elapsed);

		if (noteSpawner.curNoteData != null) {
			var laneID:Int = noteSpawner.curNoteData?.lane ?? -1;
			if (laneID != -1)
				noteSpawner.spawnNotes(lanes.members[laneID]);
		}
	}
}
