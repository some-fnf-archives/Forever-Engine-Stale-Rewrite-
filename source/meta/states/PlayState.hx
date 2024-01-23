package meta.states;

import openfl.display.BitmapData;
import sys.io.File;
import sys.FileSystem;
import haxe.io.Bytes;
import format.png.Reader;
import format.png.Tools;
import flixel.FlxState;

class PlayState extends FlxState {
	override function create() {
		super.create();

		final f = File.read(FileSystem.absolutePath("assets/game/noteskins/notes/base/sheet.png"));
		final png = new Reader(f).read();
		final header = Tools.getHeader(png);
		trace('${header.width}x${header.height}');
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
	}
}
