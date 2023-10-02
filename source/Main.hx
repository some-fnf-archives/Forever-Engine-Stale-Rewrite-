package;

import flixel.FlxGame;
import flixel.FlxState;
import forever.ui.ForeverOverlay;
import openfl.display.Sprite;
import openfl.utils.Assets as OpenFLAssets;

class Main extends Sprite {
	public static var framerate:Int = 120;

	public static var overlay:ForeverOverlay;

	public static final initialState = funkin.states.menus.FreeplayMenu;
	public static final version:String = "1.0.0";

	public function new():Void {
		super();

		FlxG.signals.gameResized.add(onResizeGame);
		FlxG.signals.preStateCreate.add(onStateCreate);

		#if linux
		var icon = lime.graphics.Image.fromFile("icon.png");
		openfl.Lib.current.stage.window.setIcon(icon);
		#end

		addChild(new FlxGame(1280, 720, Init, framerate, framerate, true));
		addChild(overlay = new ForeverOverlay(0, 0, 0xFFFFFFFF));
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
		AssetHelper.clearCacheEntirely(true);
	}

	public static function setFPSCap(newFramerate:Int):Void {
		if (newFramerate > FlxG.drawFramerate) {
			FlxG.updateFramerate = newFramerate;
			FlxG.drawFramerate = newFramerate;
		}
		else {
			FlxG.drawFramerate = newFramerate;
			FlxG.updateFramerate = newFramerate;
		}
	}
}
