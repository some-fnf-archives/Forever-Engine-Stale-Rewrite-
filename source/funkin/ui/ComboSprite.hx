package funkin.ui;

import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tweens.FlxTween;
import forever.display.ForeverSprite;

enum abstract ComboPopType(Int) from Int to Int {
	var PERFECT = 0;
	var NORMAL = 1;
	var MISS = -1;
}

class ComboSprite extends ForeverSprite {
	public function new(X:Float = 0, Y:Float = 0, ?Sprite:String) {
		super(X, Y);

		if (Sprite != null)
			loadSprite(Sprite);
	}

	public function resetProps() {
		FlxTween.cancelTweensOf(this);
		alpha = 1;
		acceleration.set();
		velocity.set();
		scale.set(1, 1);
		updateHitbox();
		visible = true;
		active = true;
		return this;
	}

	public function loadSprite(Sprite:String, Skin:String = "normal") {
		if (frames == null) frames = Paths.getSparrowAtlas('ui/${Skin}/combo');
		animation.addByPrefix(Sprite, Sprite, 0, false);
		animation.play(Sprite);
		updateHitbox();
		return this;
	}

	override function updateAnimation(elapsed:Float) {}
}

