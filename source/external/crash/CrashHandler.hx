package external.crash;

import forever.core.DiscordWrapper;
import openfl.geom.Matrix;
import openfl.display.Sprite;
import openfl.display.Stage;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.media.Sound;
import openfl.media.SoundTransform;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;
import openfl.text.TextFormat;
import openfl.ui.Keyboard;

/**
 * In-game crash handler state.
 * 
 * made for Forever Engine
 * @see https://github.com/crowplexus/Forever-Engine
 * 
 * @author crowplexus
**/
class CrashHandler extends Sprite {
	final font:String = Paths.font("vcr");

	var errorTitle:RotatableTextField;
	var loggedError:TextField;
	var _modReset:Bool = false;

	private static var _active:Bool = false;

	var _stage:Stage;
	var random = new flixel.math.FlxRandom();

	final imagineBeingFunny:Array<String> = [
		// crowplexus
		"Fatal Error!",
		"!rorrE lataF",
		"Enough of your puns SANS.",
		"Forever riddled with bugs.",
		"Welcome to game development!",
		"Anything wrong with your script buddy?",
		"Take a break and listen to something nice -> watch?v=Zqa2mgjbOIM",
		// Keoiki
		"I wish i was funny so i could come up with a funny",
		"Let me guess, Null Object Reference?",
		// Totally Wizard
		"Gay gay gay gay gay gay gay gay gay gay gay",
		// Ne_Eo
		"U fucking messed up, i can't believe you",
		"What are you??? A idiot program -Godot RAMsey",
		'I told you, ${DiscordWrapper.username ?? "the human"} was gonna crash the engine',
		// SrtHero278
		"GET IN THE CAR I FUCKED UP",
		"...Oh dear. Your brain       is... a                  underwhelming. ",
		// Zyfix
		"IT WAS A MISS INPUT, MISS INPUT CALM DOWN, YOU CALM THE FUCK DOWN",
		// RapperGF
		"Thats not very forever engine fnf of you.",
	];

	public function new(stack:String):Void {
		super();

		this._stage = openfl.Lib.application.window.stage;

		if (!_active)
			_active = true;

		final _matrix = new flixel.math.FlxMatrix().rotateByPositive90();

		// draw a background
		// [0.8, 0.6]
		// 0xFFA95454
		graphics.beginGradientFill(LINEAR, [0xFF000000, 0xFFA84444], [0.5, 1], [75, 255], _matrix);
		graphics.drawRect(0, 0, _stage.stageWidth, _stage.stageHeight);
		graphics.endFill();

		// -- TEXT CREATING PHASE -- //

		final tf = new TextFormat(font, 24, 0xFFFFFF);
		final tf2 = new TextFormat(font, 48, 0xDADADA);

		errorTitle = new RotatableTextField();
		loggedError = new TextField();

		// create the error title!
		errorTitle.defaultTextFormat = tf2;

		random.shuffle(imagineBeingFunny);
		// imagineBeingFunny = ["IT WAS A MISS INPUT, MISS INPUT CALM DOWN, YOU CALM THE FUCK DOWN"]; // testing long
		var quote:String = random.getObject(imagineBeingFunny);
		errorTitle.text = '${quote}\n';

		for (i in 0...quote.length)
			errorTitle.appendText('-');

		errorTitle.width = _stage.stageWidth * 0.5;
		errorTitle.x = centerX(errorTitle.width);
		errorTitle.y = _stage.stageHeight * 0.1;

		errorTitle.autoSize = CENTER;
		errorTitle.multiline = true;

		// create the error text
		loggedError.defaultTextFormat = tf;
		loggedError.text = '\n\n${stack}\n'
			+ "\nPress R to Unload your mods if needed, Press ESCAPE to Reset"
			+ "\nIf you feel like this error shouldn't have happened,"
			+ "\nPlease report it to our GitHub Page by pressing SPACE";

		// and position it properly
		loggedError.autoSize = errorTitle.autoSize;
		// loggedError.width = _stage.stageWidth;
		loggedError.y = errorTitle.y + (errorTitle.height) + 50;
		loggedError.autoSize = CENTER;

		addChild(errorTitle);
		addChild(loggedError);

		// Autosizing
		if (loggedError.width > _stage.stageWidth) {
			loggedError.scaleX = loggedError.scaleY = _stage.stageWidth / (loggedError.width + 100);
		}
		loggedError.x = centerX(loggedError.width);

		if (errorTitle.width > _stage.stageWidth) {
			errorTitle.scaleX = errorTitle.scaleY = _stage.stageWidth / (errorTitle.width + 100);
		}
		errorTitle.x = centerX(errorTitle.width);

		// Sound from codename
		final sound:Sound = AssetHelper.getAsset('audio/sfx/errorReceived', SOUND);
		final volume:Float = Tools.toFloatPercent(Settings.masterVolume);

		sound.play(new SoundTransform(volume)).addEventListener(Event.SOUND_COMPLETE, (_) -> {
			sound.close();
		});

		_stage.addEventListener(KeyboardEvent.KEY_DOWN, keyActions);
		addEventListener(Event.ENTER_FRAME, (e) -> {
			var time = openfl.Lib.getTimer() / 1000;
			if (time - lastTime > 1 / 5) {
				if (!setupOrigin) {
					errorTitle.originX = errorTitle.width * 0.5;
					errorTitle.originY = errorTitle.height * 0.5;
					setupOrigin = true;
				}
				errorTitle.rotation = random.float(-1, 1);
				lastTime = time;
			}
		});
	}

	var lastTime = 0.0;
	var setupOrigin = false;

	public function keyActions(e:KeyboardEvent):Void {
		switch e.keyCode {
			case Keyboard.R:
				forever.core.Mods.loadMod(null);
				_modReset = true;
			case Keyboard.SPACE:
				FlxG.openURL("https://github.com/crowplexus/Forever-Engine/issues");
			case Keyboard.ESCAPE:
				_stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyActions);

				_active = false;
				@:privateAccess Main.self.gameClient._viewingCrash = false;
				// now that the crash handler should be no longer active, remove it from the game container.
				if (Main.self != null && Main.self.contains(this))
					Main.self.removeChild(this);
				forever.core.Mods.resetGame();
		}
	}

	inline function centerX(w:Float):Float {
		return (0.5 * (_stage.stageWidth - w));
	}
}

class RotatableTextField extends TextField {
	public var originX(default, set):Float = 0;
	public var originY(default, set):Float = 0;

	private override function set_rotation(value:Float):Float {
		if (value != __rotation) {
			__rotation = value;
			var radians = __rotation * (Math.PI / 180);
			__rotationSine = Math.sin(radians);
			__rotationCosine = Math.cos(radians);
			updateRotation();
		}

		return value;
	}

	private function set_originX(value:Float):Float {
		if (value != originX) {
			originX = value;
			updateRotation();
		}

		return value;
	}

	private function set_originY(value:Float):Float {
		if (value != originY) {
			originY = value;
			updateRotation();
		}

		return value;
	}

	private var __x:Float = 0;
	private var __y:Float = 0;

	@:keep @:noCompletion override private function set_x(value:Float):Float {
		if (value != __x) {
			__x = value;
			updateRotation();
		}
		return value;
	}

	@:keep @:noCompletion override private function get_x():Float {
		return __x;
	}

	@:keep @:noCompletion override private function set_y(value:Float):Float {
		if (value != __y) {
			__y = value;
			updateRotation();
		}

		return value;
	}

	@:keep @:noCompletion override private function get_y():Float {
		return __y;
	}

	public function updateRotation() {
		__transform.tx = 0;
		__transform.ty = 0;
		__transform.translate(-originX, -originY);

		__transform.a = __rotationCosine * __scaleX;
		__transform.b = __rotationSine * __scaleX;
		__transform.c = -__rotationSine * __scaleY;
		__transform.d = __rotationCosine * __scaleY;

		var tx1 = __transform.tx * __rotationCosine - __transform.ty * __rotationSine;
		__transform.ty = __transform.tx * __rotationSine + __transform.ty * __rotationCosine;
		__transform.tx = tx1;

		__transform.translate(originX, originY);
		__transform.translate(__x, __y);

		__setTransformDirty();
	}

	public inline function rotateWithTrig(cos:Float, sin:Float):Matrix {
		var a1:Float = __transform.a * cos - __transform.b * sin;
		__transform.b = __transform.a * sin + __transform.b * cos;
		__transform.a = a1;

		var c1:Float = __transform.c * cos - __transform.d * sin;
		__transform.d = __transform.c * sin + __transform.d * cos;
		__transform.c = c1;

		var tx1:Float = __transform.tx * cos - __transform.ty * sin;
		__transform.ty = __transform.tx * sin + __transform.ty * cos;
		__transform.tx = tx1;

		return __transform;
	}
}
