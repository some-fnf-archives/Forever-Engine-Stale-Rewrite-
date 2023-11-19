package funkin.ui;

import flixel.FlxCamera;
import flixel.graphics.frames.FlxFrame;
import flixel.math.FlxPoint;
import forever.display.ForeverSprite;
import haxe.ds.Vector;

/*
 * Custom made Progress Bar that allows for more customization and control.
 *
 * "Like FlxBar but less cringe" -MaybeMaru
 *
 * @author MaybeMaru
**/
class ProgressBar extends ForeverSprite {
    /** Vector containing the foreground and background colors of the bar. **/
    public var colors:Vector<Int>;
    /** Current Percentage of the bar. **/
    public var percent:Float = 50.0;
    /** Maximum Possible Percentage that can be reached. **/
    var max:Float;

    // Adds a rectangle on top of the graphic instead of coloring the graphic
    public var legacyMode:{active:Bool, outline:Float, inFront:Bool, sprite:FlxSprite} = null;

    /**
     * Creates a new Progress Bar, in the specified coordinates and with the specified image.
     *
     * @param X             X Coordinate of which the bar should appear at.
     * @param Y             Y Coordinate of which the bar should appear at.
     * @param imagePath     Image that should be used for the bar.
    **/
    public function new(X:Float, Y:Float, imagePath:String, max:Float = 2.0) {
        super(X, Y, imagePath);
        scrollFactor.set();
        this.max = max;
        colors = new Vector(2);
        createFilledBar(0xFFFF0000, 0xFF66FF33);
        updateBar(1.0);

        // Turned off but with the default funkin healthbar variables
        legacyMode = {
            active: false,
            outline: 4.0,
            inFront: true,
            sprite: new FlxSprite().makeGraphic(cast width, cast height)
        }
    }

    override function destroy() {
        super.destroy();
        barPoint.put();
        legacyMode.sprite.destroy();
        colors = null;
        legacyMode = null;
    }

    /**
     * Appends a color to the background of the Bar
     *
     * @param color             Color to append at the background of the bar.
    **/
    public inline function createColoredEmptyBar(color:Int):Void {
        colors[0] = color;
    }

    /**
     * Appends a color to the foreground of the Bar
     *
     * @param color             Color to append at the foreground of the bar.\
    **/
    public inline function createColoredFilledBar(color:Int):Void {
        colors[1] = color;
    }

    /**
     * Fills the background and foreground colors of the bar
     *
     * @param color1            Color to append at the background of the bar.
     * @param color2            Color to append at the foreground of the bar.
    **/
    public inline function createFilledBar(color1:Int, color2:Int) {
        createColoredEmptyBar(color1);
        createColoredFilledBar(color2);
    }

    /**
     * Updates the percentage of the Progress Bar while also taking `max`imum percentage into account.
    **/
    public inline function updateBar(value:Float) {
        percent = value / max * 100.0;
    }

    /**
     * "How can i describe this hmmm" -Crow
    **/
    public final barPoint:FlxPoint = FlxPoint.get();

    override function drawComplex(camera:FlxCamera) {
        _frame.prepareMatrix(_matrix, FlxFrameAngle.ANGLE_0, checkFlipX(), checkFlipY());
		_matrix.translate(-origin.x, -origin.y);
		_matrix.scale(scale.x, scale.y);

		if (bakedRotationAngle <= 0) {
			updateTrig();
			if (angle != 0) _matrix.rotateWithTrig(_cosAngle, _sinAngle);
		}

		getScreenPosition(_point, camera).subtractPoint(offset);
		_point.add(origin.x, origin.y);
		_matrix.translate(_point.x, _point.y);

		if (isPixelPerfectRender(camera)) {
			_matrix.tx = Math.floor(_matrix.tx);
			_matrix.ty = Math.floor(_matrix.ty);
		}

        /*
         * This isn't pretty too look at but shhhhhh it works
        **/

        // TODO add the angle fixes n barPoint shit to legacy mode
        final _pos = width * percent * 0.01;
        final _sub = width - _pos;
        
        if (legacyMode.active) {
            final _mX = _matrix.tx;
            final _mY = _matrix.ty;
            if (legacyMode.inFront) camera.drawPixels(_frame, framePixels, _matrix, colorTransform, blend, antialiasing, shader);
            
            final _spr = legacyMode.sprite;
            final __frame = _spr.frame;
            final _out = legacyMode.outline * 2;

            _matrix.translate(legacyMode.outline * (_cosAngle - _sinAngle), legacyMode.outline * (_cosAngle + _sinAngle));
            __frame.frame.height = height - _out;

            if (percent != 100) {
                _spr.color = colors[0];
                __frame.frame.width = width - _out;
                camera.drawPixels(__frame, _spr.framePixels, _matrix, _spr.colorTransform, blend, antialiasing, shader);
            }

            _matrix.translate(_sub * _cosAngle, _sub * _sinAngle);

            if (percent != 0) {
                _spr.color = colors[1];
                __frame.frame.width = _pos - _out;
                camera.drawPixels(__frame, _spr.framePixels, _matrix, _spr.colorTransform, blend, antialiasing, shader);
            }

            final _center = height * 0.5;
            barPoint.set(_matrix.tx + (_center * -_sinAngle), _matrix.ty + (_center * _cosAngle));

            if (!legacyMode.inFront) {
                _matrix.tx = _mX;
                _matrix.ty = _mY;
                camera.drawPixels(_frame, framePixels, _matrix, colorTransform, blend, antialiasing, shader);
            }
        }
        else {
            if (percent != 100) {
                color = colors[0];
                _frame.frame.x = 0;
                _frame.frame.width = _sub;
                camera.drawPixels(_frame, framePixels, _matrix, colorTransform, blend, antialiasing, shader);
            }
    
            _matrix.translate(_sub * _cosAngle, _sub * _sinAngle);

            if (percent != 0) {
                color = colors[1];
                _frame.frame.x = _sub;
                _frame.frame.width = _pos;
                camera.drawPixels(_frame, framePixels, _matrix, colorTransform, blend, antialiasing, shader);
            }

            final _center = height * 0.5;
            barPoint.set(_matrix.tx + (_center * -_sinAngle), _matrix.ty + (_center * _cosAngle));
        }
    }
}