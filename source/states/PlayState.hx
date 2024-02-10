package states;

import backend.Conductor;
import flixel.FlxState;

class PlayState extends FlxState implements BeatSynced {
	override function create() {
		super.create();
		Conductor.reset(102, true);
	}

	override function onFocus() {
		Conductor.active = true;
	}

	override function onFocusLost() {
		Conductor.active = false;
	}

	public function onBeat(beat: Int) {
		//trace(beat);
		FlxG.sound.play("assets/sfx/menu/scroll.ogg");
	}

	public function onStep(step: Int) {}

	public function onBar (bar:  Int) {}
}
