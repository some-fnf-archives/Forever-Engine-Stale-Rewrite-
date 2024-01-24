package states;

import backend.Conductor;
import flixel.FlxState;
import format.png.Reader;
import format.png.Tools;
import sys.FileSystem;
import sys.io.File;

class PlayState extends FlxState implements BeatSynced {
	override function create() {
		super.create();

		Conductor.reset(102, true);
		FlxG.sound.playMusic("assets/music/menu.ogg");

		final f = File.read(FileSystem.absolutePath("assets/game/noteskins/notes/base/sheet.png"));
		final png = new Reader(f).read();
		final header = Tools.getHeader(png);
		trace('${header.width}x${header.height}');
	}

	override function onFocus() {
		Conductor.active = true;
	}

	override function onFocusLost() {
		Conductor.active = false;
	}

	public function onBeat(beat: Int) {
		trace(beat);
		FlxG.sound.play("assets/sfx/menu/scroll.ogg");
	}

	public function onStep(step: Int) {}

	public function onBar (bar:  Int) {}
}
