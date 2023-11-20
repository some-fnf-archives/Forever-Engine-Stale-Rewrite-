package funkin.ui;

import flixel.group.FlxSpriteGroup;
import flixel.math.FlxPoint;
import funkin.ui.AlphabetGlyph;
import openfl.text.TextFormatAlign;

using StringTools;

typedef GlyphGroup = FlxTypedSpriteGroup<AlphabetGlyph>;

/**
 * A class for rendering text in a special funky font!
 * Includes left, center, and right sided aligning!
 *
 * @author swordcube
 */
class Alphabet extends FlxTypedSpriteGroup<GlyphGroup> {
	/** Type of the Texture used for the letters, usually `BOLD`. **/
	public var type(default, set):AlphabetGlyphType;

	/** The currently set alignment type for the text. **/
	public var alignment(default, set):TextFormatAlign;

	/** The currently set text. **/
	public var text(default, set):String;

	/**
	 * The size multiplier of the text.
	 *
	 * It is recommended to use this instead of `scale`
	 * as it auto-adjusts the position of each glyph/letter.
	**/
	public var size(default, set):Float = 1.0;

	/** The index of this text when displayed in a list. **/
	public var targetY:Int = 0;

	/** Whether this object displays in a list like format. **/
	public var isMenuItem:Bool = false;

	/** Forced custom lerp values. **/
	public var forceLerp:FlxPoint = FlxPoint.get(-1, -1);

	/** The spacing between items in menus like freeplay or options. **/
	public var menuSpacing:FlxPoint = FlxPoint.get(20, 120);

	public function new(x:Float = 0, y:Float = 0, text:String = "", ?type:AlphabetGlyphType = BOLD, ?alignment:TextFormatAlign = LEFT, ?size:Float = 1.0) {
		super(x, y);
		@:bypassAccessor this.type = type;
		@:bypassAccessor this.alignment = alignment;
		this.text = text;
		this.size = size;
	}

	override function update(elapsed:Float) {
		if (isMenuItem) {
			final scaledY:Float = targetY * 1.3;
			x = forceLerp.x != -1 ? forceLerp.x : Tools.fpsLerp(x, (targetY * menuSpacing.x) + 90, 0.16);
			y = forceLerp.y != -1 ? forceLerp.y : Tools.fpsLerp(y, (scaledY * menuSpacing.y) + (FlxG.height * 0.48), 0.16);
		}
		super.update(elapsed);
	}

	// -- DON'T TOUCH THESE VARS AND FUNCS -- //

	@:noCompletion
	private function updateText(newText:String, ?force:Bool = false) {
		if (text == newText && !force) // what's the point of regenerating
			return;

		var i:Int = 0;
		while (i != members.length) {
			members[i].destroy();
			i++;
		}
		clear();

		final glyphPos:FlxPoint = FlxPoint.get();

		var rows:Int = 0;
		var line:GlyphGroup = new GlyphGroup(); // this.recycle(GlyphGroup);

		for (i in 0...newText.length) {
			final char:String = newText.charAt(i);
			if (char == "\n") {
				glyphPos.x = 0;
				glyphPos.y = ++rows * AlphabetGlyph.Y_PER_ROW;
				add(line);
				line = new GlyphGroup(); // this.recycle(GlyphGroup);
				continue;
			}

			final spaceChar:Bool = (char == " ");
			if (spaceChar) {
				glyphPos.x += 28;
				continue;
			}

			if (!AlphabetGlyph.allGlyphs.contains(char.toLowerCase()))
				continue;

			final glyph:AlphabetGlyph = new AlphabetGlyph(glyphPos.x, glyphPos.y, char, type);
			glyph.row = rows;
			glyph.color = color;
			glyph.spawnPos.copyFrom(glyphPos);
			line.add(glyph);

			glyphPos.x += glyph.width;
		}
		if (members.indexOf(line) == -1)
			add(line);
		glyphPos?.put();
	}

	@:noCompletion
	private function updateAlignment(align:TextFormatAlign) {
		final totalWidth:Float = width;
		for (line in members) {
			switch (align) {
				default:
					line.x = x;
				case CENTER:
					line.x = x + ((totalWidth - line.width) * 0.5);
				case RIGHT:
					line.x = x + (totalWidth - line.width);
			}
		}
	}

	@:noCompletion
	private function updateSize(size:Float) {
		for (line in members) {
			for (glyph in line) {
				glyph.scale.set(size, size);
				glyph.updateHitbox();
				glyph.setPosition(line.x + (glyph.spawnPos.x * size), line.y + (glyph.spawnPos.y * size));
			}
		}
		updateAlignment(alignment);
	}

	@:noCompletion
	private inline function set_type(newType:AlphabetGlyphType):AlphabetGlyphType {
		type = newType;
		updateText(text, true);
		updateSize(size);
		return newType;
	}

	@:noCompletion
	private inline function set_text(newText:String):String {
		newText = newText.replace('\\n', '\n');
		updateText(newText);
		updateSize(size);
		return text = newText;
	}

	@:noCompletion
	private inline function set_alignment(newAlign:TextFormatAlign):TextFormatAlign {
		alignment = newAlign;
		updateSize(size);
		return newAlign;
	}

	@:noCompletion
	private inline function set_size(newSize:Float):Float {
		size = newSize;
		updateSize(newSize);
		return newSize;
	}

	@:noCompletion
	override function set_color(value:Int) {
		for (letter in members)
			letter.color = value;
		return super.set_color(value);
	}

	override function destroy() {
		menuSpacing?.put();
		forceLerp?.put();
		super.destroy();
	}
}

class ChildAlphabet extends Alphabet {
	public var parent:Alphabet;
	public var increment:FlxPoint = FlxPoint.get(0, 0);

	public function new(text:String = "", ?type:AlphabetGlyphType = BOLD, ?alignment:TextFormatAlign = LEFT, ?size:Float = 1.0):Void {
		super(0, 0, text, type, alignment, size);
	}

	override function update(elapsed:Float):Void {
		super.update(elapsed);

		if (parent != null) {
			this.x = switch (alignment) {
				case CENTER: parent.x + ((width - parent.width) * 0.5) + increment.x;
				case RIGHT: parent.x + (parent.width + 30) + increment.x;
				default: parent.x + increment.x;
			}
			this.y = parent.y + increment.y;
		}
	}

	override function destroy():Void {
		increment?.put();
		super.destroy();
	}
}
