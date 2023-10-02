package funkin.components;

import flixel.FlxBasic;
import flixel.util.FlxSignal;

class Conductor extends FlxBasic {
	var _timeDelta:Float = 0.0;
	var _lastTime:Float = -1.0;
	var _lastStep:Int = -1;
	var _lastBeat:Int = -1;
	var _lastBar:Int = -1;

	/* -- GLOBAL VARIABLES -- */
	public static var bpm:Float = 100.0;
	public static var time:Float = 0.0;

	public static var step:Int;
	public static var beat(get, never):Int;
	public static var bar(get, never):Int;

	/* -- INSTANCE VARIABLES -- */
	public var beatDelta(get, never):Float;
	public var stepDelta(get, never):Float;

	public var stepTime:Float = 0.0;
	public var beatTime:Float = 0.0;

	public var onStep:FlxTypedSignal<Int->Void> = new FlxTypedSignal();
	public var onBeat:FlxTypedSignal<Int->Void> = new FlxTypedSignal();
	public var onBar:FlxTypedSignal<Int->Void> = new FlxTypedSignal();

	public function new():Void {
		super();
		time = 0.0;
		step = 0;
	}

	public override function update(elapsed:Float):Void {
		super.update(elapsed);

		_timeDelta = time - _lastTime;

		time += elapsed;
		if (FlxG.sound.music != null && FlxG.sound.music.playing) {
			if (Math.abs(time - FlxG.sound.music.time / 1000.0) >= 0.05) // interpolation.
				time = FlxG.sound.music.time / 1000.0;
		}
		step = Math.floor(timeToStep(time, bpm));

		if (time >= 0.0) {
			stepTime += stepDelta;
			beatTime += beatDelta;

			if (step > _lastStep) {
				onStep.dispatch(step);
				_lastStep = step;
			}

			if (beat > _lastBeat) {
				onBeat.dispatch(beat);
				_lastBeat = beat;
			}

			if (bar > _lastBar) {
				onBar.dispatch(bar);
				_lastBar = bar;
			}

			_lastTime = time;
		}
	}

	/////////////////////////////////
	// HELPER CONVERSION FUNCTIONS //
	/////////////////////////////////

	public static inline function timeToBeat(time:Float, _bpm:Float):Float {
		return (time * _bpm) / 60.0;
	}

	public static inline function timeToStep(time:Float, _bpm:Float):Float {
		return timeToBeat(time, _bpm) * 4.0;
	}

	public static inline function timeToBar(time:Float, _bpm:Float):Float {
		return timeToBeat(time, _bpm) / 4.0;
	}

	public static inline function beatToTime(beatTime:Float, _bpm:Float):Float {
		return (beatTime * 60.0) / _bpm;
	}

	public static inline function stepToTime(time:Float, _bpm:Float):Float {
		return beatToTime(time, _bpm) * 4.0;
	}

	public static inline function barToTime(time:Float, _bpm:Float):Float {
		return beatToTime(time, _bpm) / 4.0;
	}

	///////////////////////////////////////////////
	// GETTERS & SETTERS, DO NOT MESS WITH THESE //
	///////////////////////////////////////////////

	@:noCompletion function get_beatDelta():Float {
		return (bpm / 60.0) * _timeDelta;
	}

	@:noCompletion function get_stepDelta():Float
		return beatDelta * 4.0;

	@:noCompletion static function get_beat():Int
		return Math.floor(step / 4.0);

	@:noCompletion static function get_bar():Int
		return Math.floor(beat / 4.0);
}
