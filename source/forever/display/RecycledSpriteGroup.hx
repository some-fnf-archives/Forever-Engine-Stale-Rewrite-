package forever.display;

import flixel.group.FlxGroup.FlxTypedGroup;

class RecycledSpriteGroup<T:ForeverSprite> extends FlxTypedGroup<T> {
	public function new(MaxSize:Int = 25):Void {
		super(MaxSize);
	}

	public function addEnd(Object:T):T {
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

	public function recycleLoop(?ObjectClass:Class<T>, ?ObjectFactory:Void->T, Force:Bool = false, Revive:Bool = true):T {
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