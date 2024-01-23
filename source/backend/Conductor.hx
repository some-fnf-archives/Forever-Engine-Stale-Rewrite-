package backend;

import openfl.display.Sprite;

/**
 * Implement this interface in any class so Conductor can automatically handle its events.
 * @author crowplexus
**/
interface IBeatEligable {
    public function onBeat(beat: Int): Void;
    public function onStep(step: Int): Void;
    public function onBar (bar:  Int): Void;
}

class Conductor extends Sprite {}