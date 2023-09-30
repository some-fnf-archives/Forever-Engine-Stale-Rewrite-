package funkin.components;

import flixel.util.FlxSignal;

class Conductor {
	static var _timeDelta:Float = 0.0;
	static var _beatDelta(get, never):Float;
	static var _stepDelta(get, never):Float;

	static var _lastTime:Float = -1.0;
	static var _lastStep:Int = -1;
	static var _lastBeat:Int = -1;
	static var _lastBar:Int = -1;

	public static var bpm:Float = 100.0;
	public static var time:Float = 0.0;

	public static var stepTime:Float = 0.0;
	public static var beatTime:Float = 0.0;

	public static var step(get, never):Int;
	public static var beat(get, never):Int;
	public static var bar(get, never):Int;

	public static var onStep:FlxTypedSignal<Int->Void> = new FlxTypedSignal();
	public static var onBeat:FlxTypedSignal<Int->Void> = new FlxTypedSignal();
	public static var onBar:FlxTypedSignal<Int->Void> = new FlxTypedSignal();

	public static function reset():Void {
		time = stepTime = beatTime = _lastTime = 0.0;
		_lastStep = _lastBeat = _lastBar = -1;
		bpm = 100.0;

		onStep.removeAll();
		onBeat.removeAll();
		onBar.removeAll();
	}

	public static function update(elapsed:Float):Void {
		_timeDelta = time - _lastTime;

		if (time >= 0.0) {
			stepTime += _stepDelta;
			beatTime += _beatDelta;

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

	@:noCompletion static function get__beatDelta():Float {
		return (bpm / 60.0) * _timeDelta;
	}

	@:noCompletion static function get__stepDelta():Float
		return _beatDelta * 4.0;

	@:noCompletion static function get_step():Int
		return Math.floor(stepTime);

	@:noCompletion static function get_beat():Int
		return Math.floor(step / 4.0);

	@:noCompletion static function get_bar():Int
		return Math.floor(beat / 4.0);
}
