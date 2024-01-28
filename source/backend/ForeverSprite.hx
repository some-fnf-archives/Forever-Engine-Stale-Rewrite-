package backend;

import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.util.FlxColor;

class ForeverSprite extends FlxSprite {
    public var timeScale: Float = 1.0;
    public var animOffsets:Map<String, Array<Float>>;

    public function new(x: Float = 0, y: Float = 0, ?image: FlxGraphicAsset, ?modifiers: Dynamic) {
        super(x, y, image);
        animOffsets = new Map<String, Array<Float>>();
        if (modifiers != null) _applyMods(modifiers);
    }

    private function _applyMods(mods: Dynamic) {
        if (mods == null) return;

        if (mods.color != null && (Std.isOfType(mods.scale, Int) || Std.isOfType(mods, FlxColor)))
            color = mods.color;

        if (mods.scale != null) {
            final oldScale: FlxPoint = scale;
            if (Std.isOfType(mods.scale, Int) || Std.isOfType(mods.scale, Float))
                scale.set(mods.scale, mods.scale);
            else
                scale.set(mods.scale.x, mods.scale.y);
            if (oldScale != scale)
                updateHitbox();
        }
        if (mods.alpha != null && Std.isOfType(mods.alpha, Float))
            alpha = mods.alpha;
    }
    
    override function update(elapsed: Float) {
        super.update(elapsed * timeScale);
    }

    public function playAnim(animName: String, forced: Bool = false, reversed: Bool = false, frame: Int = 0) {
        animation.play(animName, forced, reversed, frame);

        final newOffset: Array<Float> = animOffsets.get(animName);
        if (newOffset != null && newOffset.length == 2)
            offset.set(newOffset[0], newOffset[1]);
        else
            offset.set(0, 0);
    }

    public function setOffset(animName: String, x: Float = 0, y: Float = 0) {
        animOffsets[animName] = [x, y];
    }

    public function resizeOffsets(?newScale: Float) {
        if (newScale == null) newScale = scale.x;
        for (i in animOffsets.keys())
            animOffsets[i] = [animOffsets[i][0] * newScale, animOffsets[i][1] * newScale];
    }
}
