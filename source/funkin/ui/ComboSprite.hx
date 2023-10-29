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

@:structInit class ComboPositionInfo {
	public var x:Float = 0;
	public var y:Float = 0;
	public var size:Float = 0.7;
}

class ComboSprite extends ForeverSprite {
	public var positionInfo:ComboPositionInfo = {x: 0, y: 0, size: 0.7};

	public function new(X:Float = 0, Y:Float = 0, ?Sprite:String) {
		super(X, Y);

		frames = Paths.getSparrowAtlas("ui/normal/combo");
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

	public function loadSprite(Sprite:String) {
		animation.addByPrefix(Sprite, Sprite, 0, false);
		animation.play(Sprite);
		updateHitbox();
		return this;
	}

	override function updateAnimation(elapsed:Float) {}
}

class ComboGroup extends FlxTypedGroup<ComboSprite> {
	public function new(MaxSize:Int = 25):Void {
		super(MaxSize);
	}

	public function addEnd(Object:ComboSprite):ComboSprite {
		if (Object == null) {
			FlxG.log.warn("Cannot add a `null` object to a FlxGroup.");
			return null;
		}

		// Don't bother adding an object twice.
		if (members.indexOf(Object) >= 0)
			return Object;

		// If the group is full, return the Object
		if (maxSize > 0 && length >= maxSize)
			return Object;

		// If we made it this far, we need to add the object to the group.
		members.push(Object);
		length++;

		if (_memberAdded != null)
			_memberAdded.dispatch(Object);

		return Object;
	}

	public function recycleLoop(?ObjectClass:Class<ComboSprite>, ?ObjectFactory:Void->ComboSprite, Force:Bool = false, Revive:Bool = true):ComboSprite {
		@:privateAccess {
			if (maxSize <= 0) {
				var spr = super.recycle(ObjectClass, ObjectFactory, Force, Revive);
				members.remove(spr);
				length--;
				return spr;
			}
			if (members.length < maxSize)
				return recycleCreateObject(ObjectClass, ObjectFactory);
			var spr = members.shift();
			length--;
			// members.push(spr);
			if (Revive)
				spr.revive();
			return spr;
		}
	}
}
