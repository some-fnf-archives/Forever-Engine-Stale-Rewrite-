package backend.system;

import backend.data.PlayerSettings;
import flixel.FlxGame;
import lime.app.Application as LimeApp;
import openfl.display.Sprite;

class Main extends Sprite {
  public static var version(get, set): String;

  inline static function get_version() { return LimeApp.current.meta["version"]; }
  private static function set_version(v: String) { return LimeApp.current.meta["version"] = v; }

  private static var oldState:Class<FlxState>;
  private static var newState:Class<FlxState>;

  public function new() {
    super();

    final framerate: Int = PlayerSettings.data.framerate.getParameters()[0];

    tinyWindowForTinyMonitor();
    addChild(new FlxGame(1280, 720, FlxState, framerate, framerate, true));
    FlxG.plugins.add(new Conductor());

    DiscordRPC.init();
    FlxG.signals.preStateSwitch.add(() -> {
      oldState = Type.getClass(FlxG.state);
    });
    FlxG.signals.preStateCreate.add((_) -> {
      if(oldState != newState)
      AssetServer.clearCache();
    });
    FlxG.signals.postStateSwitch.add(() -> {
      newState = Type.getClass(FlxG.state);
    });
    FlxG.fixedTimestep = false;

    @:privateAccess {
      FlxG.game._requestedState = new states.PlayState();
      FlxG.game.switchState();
    }
  }

  private function tinyWindowForTinyMonitor() {
    final window = FlxG.stage.window;
    if(window.width != FlxG.width || window.height != FlxG.height) // Don't run this "your monitor is too small" stuff if you're on a window manager like dwm
      return;

    final display = window.display.currentMode;
    if(display.height >= 850)
      return;

    Console.log(WARN, "Resizing window because your res of " + display.width + "x" + display.height + " is too small!");
    window.resize(Std.int(display.width * 0.8), Std.int(display.height * 0.8));
    window.x = Std.int((display.width - window.width) * 0.5);
    window.y = Std.int((display.height - window.height) * 0.5);

    FlxG.resizeGame(FlxG.stage.stageWidth, FlxG.stage.stageHeight);
  }
}
