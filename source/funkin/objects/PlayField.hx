package funkin.objects;

import flixel.group.FlxGroup;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import funkin.components.ChartLoader.Chart;
import funkin.components.parsers.ForeverChartData.NoteData;
import funkin.objects.notes.*;
import haxe.ds.Vector;

/**
 * Play Field contains basic objects to handle gameplay
 * Note Fields, Notes, etc.
**/
class PlayField extends FlxGroup {
	public var strumLines:Array<StrumLine> = [];
	public var plrStrums:StrumLine;
	public var enmStrums:StrumLine;

	public var noteGroup:FlxTypedSpriteGroup<Note>;

	public var paused:Bool = false;
	public var noteList:Vector<NoteData>;
	public var curNote:Int = 0;

	public function new():Void {
		super();

		final strumY:Float = Settings.downScroll ? FlxG.height - 150 : 50;

		add(enmStrums = new StrumLine(this, 100, strumY, "default", true));
		add(plrStrums = new StrumLine(this, FlxG.width - 550, strumY, "default", false));

		if (Settings.centerStrums) {
			enmStrums.visible = false;
			plrStrums.x = (FlxG.width - plrStrums.width) * 0.5;
		}

		add(noteGroup = new FlxTypedSpriteGroup<Note>());

		noteList = new Vector<NoteData>(Chart.current.notes.length);

		var allocateThisMany:Int = 5; // remind me to make this be higher depending on the note count of a song
		// allocate notes before beginning
		var i:Int = 0;
		while (i < allocateThisMany) {
			var oi = new Note();
			noteGroup.add(oi);
			oi.kill();
			i++;
		}

		// I know this is dumb as shit and I should just make a group but I don't wanna lol
		forEachOfType(StrumLine, function(n:StrumLine) strumLines.push(n));
		// also arrays are just easier to iterate !!!

		for (i in 0...Chart.current.notes.length)
			noteList[i] = Chart.current.notes[i];
	}

	override function destroy():Void {
		for (strumLine in strumLines)
			strumLine.destroy();
		noteGroup.destroy();
		super.destroy();
	}

	override function update(elapsed:Float):Void {
		super.update(elapsed);

		while (!paused && noteGroup != null && noteList.length != 0 && curNote != noteList.length) {
			var unspawnNote:NoteData = noteList[curNote];
			if (unspawnNote == null) {
				curNote++; // skip
				break;
			}
			var strum:StrumLine = strumLines[unspawnNote.lane];
			if (strum == null) {
				curNote++; // skip
				break;
			}
			final timeDifference:Float = unspawnNote.time - Conductor.time;

			if (timeDifference > 1.5 / (strum.members[unspawnNote.dir].speed / Conductor.rate)) // 1500 / (scrollSpeed / rate)
				break;

			var epicNote:Note = noteGroup.recycle(Note).appendData(unspawnNote);
			epicNote.parent = strumLines[unspawnNote.lane];
			add(epicNote);

			curNote++;
		}
	}
}
