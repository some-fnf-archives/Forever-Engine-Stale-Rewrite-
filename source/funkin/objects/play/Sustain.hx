package funkin.objects.play;

import flixel.math.FlxAngle;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;

/**
 * ...
 * @author SrtHero278
 */
class Sustain extends flixel.FlxStrip {
    var _queueRedraw:Bool = true;
    public var sustainMult(default, set):Float = 0.0;

    public function new(size:Float):Void {
        super(-999, -999);

        scale = new FlxCallbackPoint(scaleSet);
        scale.set(size, size);
    }
    
    override public function update(elapsed:Float) {
        final oldFrame = animation.frameIndex;
        updateAnimation(elapsed);
        _queueRedraw = _queueRedraw || (oldFrame != animation.frameIndex);
    }

    function scaleSet(point:FlxPoint) {
        _queueRedraw = true; //I should prob make this smarter but.....
        height = sustainMult * point.y;
    }

    override function set_flipY(newFlip:Bool) {
        _queueRedraw = _queueRedraw || (flipY != newFlip);
        return flipY = newFlip;
    }

    override function set_angle(newAngle:Float) {
        _angleChanged = (angle != newAngle);
        _queueRedraw = _queueRedraw || _angleChanged;
        return angle = newAngle;
    }

    function set_sustainMult(newMult:Float) {
        height = frameHeight * newMult * scale.y;
        _queueRedraw = _queueRedraw || (sustainMult != newMult);
        return sustainMult = newMult;
    }

    override public function draw() {
        if (sustainMult <= 0) return; // dont render anything if theres ZERO OR NEGATIVE tiles.

        updateTrig(); //btw this function in FlxSprite already checks for _angleChanged.
        if (_queueRedraw)
            regenVerts();

		super.draw();
    }

    function regenVerts() {
        _queueRedraw = false;

        final ceilMult = Math.ceil(sustainMult);
        final heightChunk = frameHeight; // TEMP
        final offset = heightChunk * (sustainMult % 1);
        final yScale = (flipY) ? -scale.y : scale.y;

        vertices.splice(0, vertices.length);
        uvtData.splice(0, uvtData.length);
        indices.splice(0, indices.length);
        for (i in 0...ceilMult) {
            final halfWidth = frameWidth * 0.5 * scale.x;
            final topPos = (heightChunk * (i - 1) + offset) * Math.min(i, 1) * yScale;
            final bottomPos = (heightChunk * i + offset) * yScale;

            vertices[i * 8] = -halfWidth * _cosAngle + topPos * -_sinAngle;
            vertices[i * 8 + 1] = -halfWidth * _sinAngle + topPos * _cosAngle;

            vertices[i * 8 + 2] = halfWidth * _cosAngle + topPos * -_sinAngle;
            vertices[i * 8 + 3] = halfWidth * _sinAngle + topPos * _cosAngle;

            vertices[i * 8 + 4] = -halfWidth * _cosAngle + bottomPos * -_sinAngle;
            vertices[i * 8 + 5] = -halfWidth * _sinAngle + bottomPos * _cosAngle;

            vertices[i * 8 + 6] = halfWidth * _cosAngle + bottomPos * -_sinAngle;
            vertices[i * 8 + 7] = halfWidth * _sinAngle + bottomPos * _cosAngle;

            final top = ((ceilMult - i) % 2 == 0) ? frame.uv.height : frame.uv.y;
            final bottom = ((ceilMult - i) % 2 == 0) ? frame.uv.y : frame.uv.height;

            uvtData[i * 8] = frame.uv.x;
            uvtData[i * 8 + 1] = (i == 0) ? FlxMath.lerp(top, bottom, sustainMult % 1) : top;
            uvtData[i * 8 + 2] = frame.uv.width;
            uvtData[i * 8 + 3] = uvtData[i * 8 + 1];
            uvtData[i * 8 + 4] = frame.uv.x;
            uvtData[i * 8 + 5] = bottom;
            uvtData[i * 8 + 6] = frame.uv.width;
            uvtData[i * 8 + 7] = bottom;

            indices[i * 6] = i * 4;
            indices[i * 6 + 1] = i * 4 + 1;
            indices[i * 6 + 2] = i * 4 + 2;
            indices[i * 6 + 3] = i * 4 + 1;
            indices[i * 6 + 4] = i * 4 + 2;
            indices[i * 6 + 5] = i * 4 + 3;
        }
    }
}