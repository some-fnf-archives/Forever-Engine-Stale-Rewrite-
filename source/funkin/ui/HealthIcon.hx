package funkin.ui;

import flixel.graphics.FlxGraphic;
import forever.display.ForeverSprite;
import funkin.states.PlayState;
import haxe.ds.IntMap;
import openfl.utils.Assets as OpenFLAssets;

class HealthIcon extends ChildSprite {
	public var initialWidth:Float = 0.0;
	public var initialHeight:Float = 0.0;

	public var isPlayer:Bool = false;

	public var character(default, set):String;

	public function new(character:String = "bf", isPlayer:Bool = false, parent:FlxSprite = null):Void {
		super();

		this.isPlayer = isPlayer;
		this.character = character;
		if (parent != null)
			this.parent = parent;
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

	public override function update(elapsed:Float):Void {
		super.update(elapsed);

		var hp:HealthBar = PlayState.current != null ? PlayState.current.hud.healthBar : null;
		if (hp != null) {
			updateFrame(isPlayer ? hp.bar.percent : 100 - hp.bar.percent);
			offset.y = 0;
		}
	}

	public var healthSteps:IntMap<Int> = [
		// *
		0 => 0, // Default
		20 => 1, // Lose
		// *
	];

	public dynamic function updateFrame(health:Float):Void {
		for (percent => frame in healthSteps)
			if (health >= percent)
				animation.curAnim.curFrame = frame;
	}
}
