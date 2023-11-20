package forever.tools;

class ControlsFormatter {
	public static inline function format(key:String):String {
		key = strToNum(key).replace("NUMPAD", "KP#");

		key = switch (key) {
			case "SPACE": "SPC";
			case "BACKSPACE": "BACKSPC";
			case "CONTROL": "CTRL";
			case "WINDOWS": #if android "HOME" #elseif windows "WIN" #elseif mac "CMD" #else "SUPER" #end;
			case "SCROLL_LOCK": #if linux "F15" #else "SCROLL LOCK" #end;
			case "NUMPADMULTIPLY": "KP*";
			case "NUMPADPLUS": "KP+";
			case "NUMPADMINUS": "KP-";
			case "NUMPADSLASH": "KP/";
			case "NUMPADPERIOD": "KP.";
			case "COMMA": ",";
			case "PERIOD": ".";
			case "COLON": ":";
			case "SEMICOLON": ";";
			case "SLASH": "/";
			case "PAGEUP": "PGUP";
			case "PAGEDOWN": "PGDOWN";
			case "BACKSLASH": "\\";
            case null: "---";
            case _: key;
		}

		return key;
	}

	private static inline function strToNum(str:String):String {
        final numbers:Array<String> = "0123456789".split("");
    	final numStrings:Array<String> = "ZERO ONE TWO THREE FOUR FIVE SIX SEVEN EIGHT NINE".split(" ");
        for (i in numbers) str = str.replace(i, numStrings[str.indexOf(i)]);
		return str;
	}
}