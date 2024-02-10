package backend.system;

import openfl.display.Sprite;

/**
 * Implement this interface in any class so Conductor can automatically handle its events.
 * @author crowplexus
**/
interface BeatSynced {
    public function onBeat(beat: Int): Void;
    public function onStep(step: Int): Void;
    public function onBar (bar:  Int): Void;
}

class Conductor extends Sprite {
    public static var timePosition: Float = 0;
    public static var bpm(default, set): Float = 100;
    public static var rate: Float = 1;

    public static var active: Bool = false;

    public static var stepsPerBeat: Int = 4;
    public static var beatsPerBar : Int = 4;

    public static var stepf: Float = 0;
    public static var beatf: Float = 0;
    public static var barf:  Float = 0;

    public static var beat(get, never): Int;
    public static var step(get, never): Int;
    public static var bar (get, never): Int;

    public static var crochet: Float = 0;
    public static var stepCrochet: Float = 0;

    @:noCompletion private var _lastTime: Float = 0.0;

    public function new() {
        super();
        reset();
    }

    public static function reset(?_bpm: Float = -1, ?doActivate: Bool = false) {
        stepf = beatf = barf = 0;
        if (_bpm != -1) bpm = _bpm;
        active = doActivate;
    }

    public override function __enterFrame(deltaTime: Int) {
        if (!active) return;

        super.__enterFrame(deltaTime);

        final dt: Float = lime.system.System.getTimer()*0.001;
        timePosition += dt;

        if (FlxG.sound.music != null && FlxG.sound.music.playing) {
            final songTime: Float = FlxG.sound.music.time*0.001;
            if (Math.abs(timePosition - songTime) > 0.05) {
                timePosition = songTime;
            }
        }

        final beatdt: Float = (bpm/60) * (timePosition - _lastTime);
        if (beat != Math.floor(beatf += beatdt               ) ) stepHit(step);
        if (step != Math.floor(stepf += beatdt * stepsPerBeat) ) beatHit(beat);
        if (bar  != Math.floor(barf  += beatdt / beatsPerBar ) ) barHit (bar );
        _lastTime = timePosition;
    }

    // --------------------------------------------------------- //
	//                Music Sync Functions                       //
    // NOTE: if this is slower than emitting a signal, change it //
	// --------------------------------------------------------- //

    // sanity checks (because I'm sure as hell going insane) -Crow
    @:noCompletion private var _oldStep: Int = 0;
    @:noCompletion private var _oldBeat: Int = 0;
    @:noCompletion private var _oldBar: Int  = 0;

    private function stepHit(receivedStep: Int) {
        if (_oldStep == receivedStep) return;
        if (Std.isOfType(FlxG.state, BeatSynced))
            cast(FlxG.state, BeatSynced).onStep(receivedStep);
        _oldStep = receivedStep;
    }

    private function beatHit(receivedBeat: Int) {
        if (_oldBeat == receivedBeat) return;
        if (Std.isOfType(FlxG.state, BeatSynced))
            cast(FlxG.state, BeatSynced).onBeat(receivedBeat);
        _oldBeat = receivedBeat;
    }

    private function barHit (receivedBar: Int) {
        if (_oldBar == receivedBar) return;
        if (Std.isOfType(FlxG.state, BeatSynced)) {
            cast(FlxG.state, BeatSynced).onBar (receivedBar);
        }
        _oldBar = receivedBar;
    }

    // ----------------- //
	// Getters & Setters //
	// ----------------- //
    
    inline static function get_beat() { return Math.floor(beatf); }
    inline static function get_step() { return Math.floor(stepf); }
    inline static function get_bar () { return Math.floor(barf ); }

    inline static function set_bpm(newBpm: Float) {
        bpm = newBpm;
        crochet = (60 / bpm);
        stepCrochet = (crochet * 0.25);
        return bpm;
    }
}