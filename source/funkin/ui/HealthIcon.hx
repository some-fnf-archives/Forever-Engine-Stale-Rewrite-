package funkin.ui;

import flixel.graphics.FlxGraphic;
import flixel.math.FlxMath;
import forever.display.ForeverSprite;
import funkin.states.PlayState;
import haxe.ds.IntMap;

class HealthIcon extends ChildSprite {
	public var initialWidth:Float = 0.0;
	public var initialHeight:Float = 0.0;

	public var isPlayer:Bool = false;
	public var character(default, set):String;

	// -- CUSTOMIZATION -- //
	public var autoPosition:Bool = true;
	public var autoBop:Bool = true;

	public var healthSteps:IntMap<Int> = [
		// *
		0 => 0, // Default
		20 => 1, // Lose
		// *
	];

	public function new(character:String = "bf", isPlayer:Bool = false, parent:FlxSprite = null):Void {
		super();

		this.isPlayer = isPlayer;
		this.character = character;
		if (parent != null) {
			this.parent = parent;
			this.autoPosition = false;
		}
	}

	function set_character(newChar:String):String {
		var char:String = newChar;
		if (!Tools.fileExists(AssetHelper.getPath('images/icons/${char}', IMAGE)))
			char = "face";

		if (character != char) {
			var file:FlxGraphic = AssetHelper.getAsset('images/icons/${char}', IMAGE);
			var _width:Int = Std.int(file.width / 150);

			loadGraphic(file); // load graphic to get the width and height
			loadGraphic(file, true, Std.int(width / _width), Std.int(file.height));

			initialWidth = width;
			initialHeight = height;

			animation.add("icon", [for (i in 0...frames.frames.length) i], 24, false, isPlayer);
			animation.play("icon");

			antialiasing = !char.endsWith("-pixel");
			character = char;
		}

		return char;
	}

	override function update(elapsed:Float):Void {
		super.update(elapsed);

		var hp:HealthBar = PlayState.current != null ? PlayState.current.playField.healthBar : null;
		if (hp == null) return;

		if (autoPosition == true) {
			var iconOffset:Int = 25;
			if (!isPlayer) iconOffset = cast(width - iconOffset);
			x = (hp.x + (hp.bar.width * (1 - hp.bar.percent / 100))) - iconOffset;
		}

		if (autoBop == true && scale.x != 1.0) {
			final weight:Float = 1.0 - 1.0 / Math.exp(5.0 * elapsed);
			scale.set(FlxMath.lerp(scale.x, 1.0, weight), FlxMath.lerp(scale.y, 1.0, weight));
			// updateHitbox();
			offset.y = 0;
		}

		updateFrame(isPlayer ? hp.bar.percent : 100 - hp.bar.percent);
	}

	public dynamic function updateFrame(health:Float):Void {
		for (percent => frame in healthSteps)
			if (health >= percent)
				animation.curAnim.curFrame = frame;
	}

	public dynamic function doBump(beat:Int):Void {
		if (autoBop != true) return;
		scale.set(1.15, 1.15);
		// updateHitbox();
	}
}
