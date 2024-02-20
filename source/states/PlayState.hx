package states;

import flixel.FlxState;

class PlayState extends FlxState implements BeatSynced {
  override function create() {
    super.create();
    Conductor.reset(102, true);
  }

  public function onBeat(beat: Int) {
    FlxG.sound.play("assets/sfx/menu/scroll.ogg");
  }

  public function onStep(step: Int) {}

  public function onBar (bar:  Int) {}
}
