package funkin.objects.play;

import forever.display.ForeverSprite;
import funkin.ui.NoteSkin;

class NoteSplash extends ForeverSprite {
	var animations:Array<String> = [];

	public function new(skin:NoteSkin, id:Int):Void {
		super(0, 0);
        animation.finishCallback = function(name:String):Void kill();
    }

    public function resetProps(image:String, animations:Array<AnimationConfig>, size:Float = 1.0, id:Int):NoteSplash {
        this.ID = id;
        this.animations = [];
        revive();

		frames = Paths.getSparrowAtlas('notes/${image}');
		for (i in animations) {
			var dir:String = Tools.NOTE_DIRECTIONS[ID];
			var color:String = Tools.NOTE_COLORS[ID];

			addAtlasAnim(i.name, i.prefix.replace("{dir}", dir).replace("{color}", color), i.fps, i.looped);
			if (i.offsets != null) setOffset(i.name, i.offsets.x, i.offsets.y);
			this.animations.push(i.name);
		}

		scale.set(size, size);
		updateHitbox();
        return this;
	}

	public function pop(force:Bool = true):Void {
		playAnim(animations[FlxG.random.int(0, animations.length - 1)], force);
	}
}
