package backend.system;

import haxe.PosInfos;

enum abstract ConsoleLogType(Int) from Int to Int {
  var INFO = 0;
  var WARN;
  var ERROR;
}

enum abstract ConsoleColor(Int) from Int to Int {
  var BLACK = 0;
  var DARKBLUE = 1;
  var DARKGREEN = 2;
  var DARKCYAN = 3;
  var DARKRED = 4;
  var DARKMAGENTA = 5;
  var DARKYELLOW = 6;
  var LIGHTGRAY = 7;
  var GRAY = 8;
  var BLUE = 9;
  var GREEN = 10;
  var CYAN = 11;
  var RED = 12;
  var MAGENTA = 13;
  var YELLOW = 14;
  var WHITE = 15;

  var NONE = -1;
}

class Console {
  /**
   * Whether or not ANSI coloring is enabled.
   */
  public static var ansiColoring:Bool = true;

  /**
   * Sets the foreground and background ANSI console colors
   * to any colors specified.
   * 
   * Does nothing if `ansiColoring` is disabled.
   */
  public static function setColors(foregroundColor:ConsoleColor = NONE, ?backgroundColor:ConsoleColor = NONE) {
#if sys
    if(!ansiColoring) return;
    Sys.print("\x1b[0m");
    if (foregroundColor != NONE)
      Sys.print("\x1b[" + (colorToANSI(foregroundColor)) + "m");
    if (backgroundColor != NONE)
      Sys.print("\x1b[" + (colorToANSI(backgroundColor) + 10) + "m");
#end
  }

  public static function log(type:ConsoleLogType, contents:Dynamic, ?pos:PosInfos) {
    switch(type) {
      case WARN:
        setColors(YELLOW);
        Sys.print("[ WARN ] ");

      case ERROR:
        setColors(RED);
        Sys.print("[ ERROR ] ");

      default:
        setColors();
        Sys.print("[ INFO ] ");
    }
    setColors(MAGENTA);
    Sys.print('[ ${pos.className}:${pos.lineNumber} ] ');
    setColors();
    Sys.print(Std.string(contents)+"\r\n");
  }

  public static function colorToANSI(color:ConsoleColor) {
    return switch (color) {
      case BLACK: 30;
      case DARKBLUE: 34;
      case DARKGREEN: 32;
      case DARKCYAN: 36;
      case DARKRED: 31;
      case DARKMAGENTA: 35;
      case DARKYELLOW: 33;
      case LIGHTGRAY: 37;
      case GRAY: 90;
      case BLUE: 94;
      case GREEN: 92;
      case CYAN: 96;
      case RED: 91;
      case MAGENTA: 95;
      case YELLOW: 93;
      case WHITE | _: 97;
    }
  }

  public static function colorToInt(color:ConsoleColor) {
    return switch (color) {
      case BLACK: 0xFF000000;
      case DARKBLUE: 0xFF000088;
      case DARKGREEN: 0xFF008800;
      case DARKCYAN: 0xFF008888;
      case DARKRED: 0xFF880000;
      case DARKMAGENTA: 0xFF880000;
      case DARKYELLOW: 0xFF888800;
      case LIGHTGRAY: 0xFFBBBBBB;
      case GRAY: 0xFF888888;
      case BLUE: 0xFF0000FF;
      case GREEN: 0xFF00FF00;
      case CYAN: 0xFF00FFFF;
      case RED: 0xFFFF0000;
      case MAGENTA: 0xFFFF00FF;
      case YELLOW: 0xFFFFFF00;
      case WHITE | _: 0xFFFFFFFF;
    }
  }
}
