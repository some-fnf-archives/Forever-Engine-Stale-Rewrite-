package funkin.components.ui;

import flixel.math.FlxPoint;
import forever.display.ForeverSprite;

class AlphabetGlyph extends ForeverSprite {
	public static final Y_PER_ROW:Float = 60;

	public static final letters:Array<String> = "abcdefghijklmnopqrstuvwxyz".split("");
	public static final allGlyphs:Array<String> = "abcdefghijklmnopqrstuvwxyz0123456789#$%&()[]|~<>←↓↑→-_!'.+?*^\\/\",=×♥".split("");

	public var type(default, set):AlphabetGlyphType;
	public var char(default, set):String;

	public var row:Int = 0;
	public var spawnPos:FlxPoint = FlxPoint.get();

	public function new(x:Float = 0, y:Float = 0, char:String = "", ?type:AlphabetGlyphType = BOLD):Void {
		super(x, y);
		@:bypassAccessor this.type = type;
		this.char = char;
	}

	public static inline function convert(letter:String):String {
		return switch (letter) {
			case "\\": "backslash";
			case "/": "forward slash";
			case ",": "comma";
			case "!": "exclamation mark";
			case "←": "left arrow";
			case "↓": "down arrow";
			case "↑": "up arrow";
			case "→": "right arrow";
			case "×": "multiply x";
			case "♥": "heart";
			case "\"": "start parentheses";
			case "%": "percent";
			case "$": "dollar";
			case "&": "and";
			case "#": "hashtag";
			default: letter;
		}
	}

	// -- DON'T TOUCH THESE VARS AND FUNCS -- //

	@:noCompletion
	private inline function updateBoldOffset():Void {
		final offset:FlxPoint = FlxPoint.get(0, (110 - frameHeight) - 33);

		// initial offseting
		switch (char) {
			case "$", "%", "&", "(", ")", "[", "]", "<", ">":
				offset.y += frameHeight * 0.1;
			case "#", "←", "↓", "↑", "→", "+", "=", "×", "♥":
				offset.y += frameHeight * 0.2;
			case ",", ".":
				offset.y += frameHeight * 0.65;
			case "~":
				offset.y += frameHeight * 0.3;
			case "-":
				offset.y += frameHeight * 0.32;
			case "_":
				offset.y += frameHeight * 0.6;
		}

		setOffset("idle", -offset.x, -offset.y);
		playAnim("idle", true);
		updateHitbox();

		offset?.put();
	}

	@:noCompletion
	private inline function updateOffset():Void {
		final offset:FlxPoint = FlxPoint.get(0, (110 - frameHeight));

		// initial offseting
		switch (char) {
			case "a", "c", "e", "g", "m", "n", "o", "r", "u", "v", "w", "x", "z", "s":
				offset.y += frameHeight * 0.25;
			case "$", "%", "&", "(", ")", "[", "]", "<", ">":
				offset.y += frameHeight * 0.1;
			case "#", "←", "↓", "↑", "→", "+", "=", "×", "♥":
				offset.y += frameHeight * 0.2;
			case ",", ".":
				offset.y += frameHeight * 0.7;
			case "~":
				offset.y += frameHeight * 0.3;
			case "-":
				offset.y += frameHeight * 0.32;
			case "_":
				offset.y += frameHeight * 0.65;
			case "p", "q", "y":
				offset.y += frameHeight * 0.22;
		}

		setOffset("idle", -offset.x, -offset.y);
		playAnim("idle", true);
		updateHitbox();

		offset?.put();
	}

	@:noCompletion
	private inline function set_type(newType:String):String {
		set_char(char);
		return type = newType;
	}

	@:noCompletion
	private inline function set_char(newChar:String):String {
		var asset:String = type == BOLD ? "bold" : "normal";
		frames = AssetHelper.getAsset('images/ui/letters/${asset}', ATLAS_SPARROW);

		final isLetter:Bool = letters.contains(newChar.toLowerCase());
		var converted:String = convert(newChar);

		if (type != BOLD && isLetter) {
			final letterCase:String = (newChar.toLowerCase() != newChar) ? "capital" : "lowercase";
			converted = (converted.toUpperCase()) + ' $letterCase';
		}
		animation.addByPrefix("idle", converted.toUpperCase() + "0", 24);

		if (!animation.exists("idle"))
			animation.addByPrefix("idle", converted + "0", 24);

		if (!animation.exists("idle")) {
			FlxG.log.warn('Letter in $type alphabet: $converted doesn\'t exist!');
			animation.addByPrefix("idle", "?0", 24);
		}

		char = newChar;

		if (type == BOLD)
			updateBoldOffset();
		else
			updateOffset();

		return newChar;
	}

	override function destroy():Void {
		spawnPos?.put();
		super.destroy();
	}
}

enum abstract AlphabetGlyphType(String) from String to String {
	var BOLD = "bold";
	var NORMAL = "normal";
}
