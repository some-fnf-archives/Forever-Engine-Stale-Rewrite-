package forever.ui.text;

import flixel.FlxObject;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;

private enum FormatChangeReason {
	NONE;
	FONT_CHANGE;
	SIZE_CHANGE;
	ALIGN_CHANGE;
}

enum ForeverTextBorder {
	NONE();
	SHADOW(offsetX:Null<Float>, offsetY:Null<Float>);
	OUTLINE(size:Null<Float>);
}

/**
 * Custom Text Field as an alternative to FlxText.
 * 
 * meant to have a cleaner codebase and more performent code.
**/
class ForeverTextField extends FlxObject {
	static final VERTICAL_GUTTER:Int = 8;
	static final HORIZONTAL_GUTTER:Int = 4;

	/** The text currently displayed. **/
	public var text(default, set):String = "";

	/** The font of the text displayed text. **/
	public var font(default, set):String = "_sans";

	/** The color of the displayed text. **/
	public var color(default, set):Null<FlxColor> = 0xFFFFFFFF;

	/** The opacity of the displayed text. **/
	public var alpha:Float = 1.0;

	/** The size of the displayed text **/
	public var size(default, set):Int = 10;

	/** The text's alignment, based on `width`. **/
	public var alignment(default, set):TextFormatAlign = LEFT;

	/** The text's border style. **/
	public var borderType(default, set):ForeverTextBorder = NONE;

	/** The text's border color. **/
	public var borderColor(default, set):Null<FlxColor> = 0xFF000000;

	/** The text's border size. **/
	public var borderSize(default, set):Float = 1.0;

	var _textF:TextField;
	var _behindRenders:Array<TextField>;
	var _textFormatStyle:TextFormat;
	var _rendererSprite:FlxSprite;
	var _canRender(get, never):Bool;

	/**
	 * Creates a new `ForeverTextField` object at the specified position.
	 * @param   X              The x position of the text.
	 * @param   Y              The y position of the text.
	 * @param   FieldWidth     The `width` of the text object. Enables `autoSize` if `<= 0`.
	 *                         (`height` is determined automatically).
	 * @param   Text           The actual text you would like to display initially.
	 * @param   Size           The font size for this text object.
	**/
	public function new(x:Float = 0, y:Float = 0, width:Float = 0, text:String, size:Int = 10):Void {
		super();

		moves = false;

		_behindRenders = []; // I feel like I'm gonna need this for borders.

		_textFormatStyle = new TextFormat(font, size, color);

		_textF = _makeField();
		_textF.height = (text.length == 0) ? 1 : 100;

		this.x = x;
		this.y = y;

		_refreshWidth(true);

		/*
			_rendererSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.TRANSPARENT);
			_rendererSprite.moves = false;
		 */

		_addTextToCam();
	}

	public function setFormat(font:String, size:Int, color:Null<FlxColor> = 0xFF000000, align:TextFormatAlign = LEFT, borderType:ForeverTextBorder = NONE,
			borderColor:Null<FlxColor> = 0xFF000000):Void {
		this.font = font;
		this.size = size;
		this.color = color;
		this.alignment = align;
		this.borderType = borderType;
		this.borderColor = borderColor;
	}

	public override function update(elapsed:Float):Void {
		super.update(elapsed);
		if (_rendererSprite != null)
			_rendererSprite.update(elapsed);
	}

	public override function destroy():Void {
		for (border in _behindRenders)
			border = null;
		_textF = null;
		_textFormatStyle = null;
		super.destroy();
	}

	// -- GETTERS & SETTERS, DO NOT MESS WITH THESE -- //

	@:dox(hide) @:noCompletion
	function set_borderType(newBorder:ForeverTextBorder):ForeverTextBorder {
		borderType = newBorder;
		switch (borderType) {
			case SHADOW(offsetX, offsetY):
				if (offsetX == null)
					offsetX = 0;
				if (offsetY == null)
					offsetY = 0;

				_behindRenders.push(inline _makeField());
				_updateTextFormat();

			case OUTLINE(size): // WIP
			default: // nuh uh
		}
		return borderType;
	}

	@:dox(hide) @:noCompletion
	function set_borderSize(newSize:Float):Float {
		borderSize = newSize;
		if (Std.isOfType(borderType, OUTLINE))
			borderType = OUTLINE(newSize);
		#if debug
		else
			trace('[ForeverText:set_borderSize]: Can\'t set borderSize with the current border type ("${borderType}"), please use the OUTLINE type text border.');
		#end
		return borderSize;
	}

	// lot of repeated code from this point onwards.

	@:dox(hide) @:noCompletion
	function set_text(newText:String):String {
		text = newText;
		if (_canRender) {
			if (_behindRenders.length != 0)
				for (i in _behindRenders)
					i.text = _textF.text;
			_textF.text = newText;
		}
		_refreshWidth(true);
		return text;
	}

	@:dox(hide) @:noCompletion
	function set_alignment(newAlign:TextFormatAlign):TextFormatAlign {
		alignment = newAlign;
		_textFormatStyle.align = newAlign;
		_updateTextFormat(ALIGN_CHANGE);
		return alignment;
	}

	@:dox(hide) @:noCompletion
	function set_font(newFont:String):String {
		font = newFont;
		_textFormatStyle.font = newFont;
		_updateTextFormat(FONT_CHANGE);
		return font;
	}

	@:dox(hide) @:noCompletion
	function set_color(newColor:Null<FlxColor>):Null<FlxColor> {
		color = newColor == null ? 0xFFFFFFFF : newColor;
		if (_textF != null)
			_textF.textColor = newColor;
		return color;
	}

	function set_borderColor(newBorderColor:Null<FlxColor>):Null<FlxColor> {
		borderColor = newBorderColor == null ? 0xFF000000 : newBorderColor;
		if (_canRender) {
			if (_behindRenders.length != 0)
				for (i in _behindRenders)
					i.textColor = newBorderColor;
		}
		return borderColor;
	}

	@:dox(hide) @:noCompletion
	function set_size(newSize:Int):Int {
		size = newSize < 1 ? 10 : newSize;
		_textFormatStyle.size = newSize;
		_updateTextFormat(SIZE_CHANGE);
		return size;
	}

	@:dox(hide) @:noCompletion
	override function set_x(newX:Float):Float {
		x = newX;
		if (_canRender) {
			if (_behindRenders.length != 0)
				for (i in _behindRenders) {
					var offsetX:Float = 0;
					if (Std.isOfType(borderType, SHADOW))
						offsetX = borderType.getParameters()[0];
					i.x = newX + offsetX;
				}
			_textF.x = newX;
		}
		return x;
	}

	@:dox(hide) @:noCompletion
	override function set_y(newY:Float):Float {
		y = newY;
		if (_canRender) {
			if (_behindRenders.length != 0)
				for (i in _behindRenders) {
					var offsetY:Float = 0;
					if (Std.isOfType(borderType, SHADOW))
						offsetY = borderType.getParameters()[1];
					i.y = newY + offsetY;
				}
			_textF.y = newY;
		}

		return y;
	}

	@:dox(hide) @:noCompletion
	override function set_width(value:Float):Float {
		#if FLX_DEBUG
		if (value < 0) {
			FlxG.log.warn("An object's width cannot be smaller than 0. Use offset for sprites to control the hitbox position!");
			return 0;
		}
		#end

		width = value;
		if (_canRender) {
			if (_behindRenders.length != 0)
				for (i in _behindRenders)
					i.width = value;
			_textF.width = value;
		}
		return value;
	}

	@:dox(hide) @:noCompletion
	function _onAddText():Void {
		for (i in cameras) {
			if (_behindRenders.length != 0) // add borders first
				for (j in 0..._behindRenders.length)
					i.canvas.addChild(_behindRenders[j]);
			i.canvas.addChild(_textF);
		}
	}

	@:dox(hide) @:noCompletion
	inline function alignToSize() {
		return switch alignment {
			case LEFT: TextFieldAutoSize.LEFT;
			case START | END | JUSTIFY: TextFieldAutoSize.NONE;
			case RIGHT: TextFieldAutoSize.RIGHT;
			case CENTER: TextFieldAutoSize.CENTER;
		}
	}

	@:dox(hide) @:noCompletion
	function _updateTextFormat(?reason:FormatChangeReason = NONE):Void {
		if (_canRender) {
			if (_behindRenders.length != 0) {
				for (i in _behindRenders) {
					i.defaultTextFormat = _textFormatStyle;
					i.setTextFormat(_textFormatStyle);
					i.textColor = borderColor;
				}
			}

			_textF.defaultTextFormat = _textFormatStyle;
			_textF.setTextFormat(_textFormatStyle);

			switch (reason) {
				case FONT_CHANGE | SIZE_CHANGE | ALIGN_CHANGE:
					if (reason == ALIGN_CHANGE) {
						for (i in _behindRenders)
							i.autoSize = alignToSize();
						_textF.autoSize = alignToSize();
					}
					_refreshWidth(true);
				default: // dont do anything
			}
		}
	}

	/*
		@:dox(hide) @:noCompletion
		function _queueDraw():Void {
			if (_rendererSprite != null && _rendererSprite.graphic != null && _rendererSprite.visible) {
				_rendererSprite.draw();

				if (_canRender) {
					@:privateAccess
					_rendererSprite.graphic.bitmap.fillRect(_rendererSprite._flashRect, FlxColor.TRANSPARENT);

					if (_behindRenders.length != 0)
						for (i in _behindRenders)
							_rendererSprite.graphic.bitmap.draw(i);
					_rendererSprite.graphic.bitmap.draw(_textF);
				}
			}
		}
	 */
	//

	@:dox(hide) @:noCompletion
	function _makeField():TextField {
		var newTextField = new TextField();
		newTextField.selectable = false;
		newTextField.mouseEnabled = false;
		newTextField.multiline = true;
		newTextField.wordWrap = true;

		newTextField.defaultTextFormat = _textFormatStyle;
		newTextField.autoSize = alignToSize();
		// newTextField.sharpness = 100;

		return newTextField;
	}

	@:dox(hide) @:noCompletion
	function _queueFree():Void {
		if (!_canRender)
			return;

		for (camellia in cameras) {
			var lastBorderIndex:Int = 0;
			for (i in _behindRenders) {
				camellia.canvas.removeChild(i);
				if (i == _behindRenders.last())
					lastBorderIndex = _behindRenders.indexOf(i);
			}
			camellia.canvas.removeChild(_textF);
		}
	}

	@:dox(hide) @:noCompletion
	function _queueRedraw():Void { // "redraw" lol
		if (!_canRender)
			return;

		_queueFree();
		_addTextToCam();
	}

	@:dox(hide) @:noCompletion
	function _addTextToCam():Void {
		if (!_canRender)
			return;

		for (camellia in cameras) {
			var lastBorderIndex:Int = 0;
			for (i in _behindRenders) {
				camellia.canvas.addChildAt(i, 0);
				if (i == _behindRenders.last())
					lastBorderIndex = _behindRenders.indexOf(i);
			}
			camellia.canvas.addChildAt(_textF, lastBorderIndex);
		}
	}

	@:dox(hide) @:noCompletion
	function _refreshWidth(andHeight:Bool = true):Void {
		final widthThing:Float = _textF.textWidth == 0 ? _textF.width : _textF.textWidth;
		final hGutter:Int = _textF.autoSize == NONE ? HORIZONTAL_GUTTER : 0;
		final vGutter:Int = _textF.autoSize == NONE ? VERTICAL_GUTTER : 0;

		final newWidth:Float = width <= 0 ? Math.ceil(widthThing * (size * 0.25)) + hGutter : Math.floor(width);

		if (andHeight)
			this.height = Math.ceil(_textF.height) + vGutter;

		if (_textF != null) {
			if (_behindRenders.length != 0)
				for (i in _behindRenders) {
					i.width = this.width;
					if (andHeight)
						i.height = newWidth;
				}
			_textF.width = newWidth;
			if (andHeight)
				_textF.height = this.height;
		}

		this.width = newWidth;
	}

	@:dox(hide) @:noCompletion
	function get__canRender():Bool
		return _textF != null;
}
