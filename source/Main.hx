package;

import flixel.FlxState;

import forever.ui.ForeverConsole;
import forever.ui.ForeverOverlay;

import openfl.display.Sprite;

typedef GameClient = #if CRASH_HANDLER external.crash.FNFGame #else flixel.FlxGame #end;

class Main extends Sprite {
	public static final initialFramerate:Int = 120;
	public static final initialState = funkin.states.menus.TitleScreen;
	public static final version:String = "1.0.0-ALPHA";

	public static var self:Main;
	public static var noGpuBitmaps:Bool = false;

	private var gameClient:GameClient;
	public var overlay:OverlayContainer;
	// public var console:ForeverConsole;

	public function new():Void {
		super();

		self = this;

		FlxG.signals.gameResized.add(onResizeGame);
		FlxG.signals.preStateCreate.add(onStateCreate);

		#if (linux || mac)
		var icon = lime.graphics.Image.fromFile("icon.png");
		openfl.Lib.current.stage.window.setIcon(icon);
		#end

		addChild(gameClient = new GameClient(1280, 720, Init, initialFramerate, initialFramerate, true));
		addChild(overlay = new OverlayContainer());
		// addChild(console = new ForeverConsole());
	}

	private function onResizeGame(width:Int, height:Int):Void {
		if (FlxG.cameras == null)
			return;

		for (cam in FlxG.cameras.list) {
			@:privateAccess
			if (cam != null && (cam._filters != null && cam._filters.length > 0)) {
				var sprite:Sprite = cam.flashSprite; // @Ne_Eo
				if (sprite != null) {
					sprite.__cacheBitmap = null;
					sprite.__cacheBitmapData = null;
					sprite.__cacheBitmapData2 = null;
					sprite.__cacheBitmapData3 = null;
					sprite.__cacheBitmapColorTransform = null;
				}
			}
		}
	}

	private function onStateCreate(state:FlxState):Void {
		@:privateAccess AssetHelper.clearCacheEntirely(true);
	}
}
