package funkin.objects.notes;

import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import funkin.components.ChartLoader.NoteData;
import haxe.ds.Vector;

class NoteSpawner extends FlxTypedSpriteGroup<Note> {
	public var noteList:Vector<NoteData>;
	public var curNoteData(get, never):NoteData;
	public var curNote:Int = 0;

	var _preventSpawning:Bool = false;

	public function new(totalNotes:Int):Void {
		super();

		noteList = new Vector<NoteData>(totalNotes);
		// allocate notes before beginning
		for (i in 0...16) {
			var alloc:Note = new Note();
			add(alloc);
		}
	}

	public override function destroy():Void {
		_preventSpawning = true;
		super.destroy();
	}

	public function spawnNotes(lane:NoteField):Void {
		if (noteList == null || noteList.length == 0)
			return;

		while (curNote < noteList.length && !_preventSpawning) {
			var timeDifference:Float = curNoteData.time - Conductor.time;
			if (curNoteData == null || timeDifference > 1.8) // 1800
				break;

			var epicNote:Note = this.recycle(Note).appendData(curNoteData);
			epicNote.parent = lane;
			add(epicNote);

			curNote += 1;
		}
	}

	function get_curNoteData():NoteData
		return noteList[curNote];
}
