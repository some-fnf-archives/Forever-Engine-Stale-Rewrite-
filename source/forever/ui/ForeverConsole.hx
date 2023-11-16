package forever.ui;

import haxe.PosInfos;
import openfl.display.Stage;
import openfl.display.Sprite;
import openfl.events.KeyboardEvent;
import openfl.ui.Keyboard;

/**
 * Console Window that shows systme logs,
 * mainly used for scripts.
 * 
 * @author crowplexus
**/
class ForeverConsole extends Sprite {
	var _stage:Stage;

	public function new():Void {
		super();

		this._stage = openfl.Lib.application.window.stage;

		haxe.Log.trace = function(v, ?infos) {
			var str = formatOutput(v, infos);
			#if js
			if (js.Syntax.typeof(untyped console) != "undefined" && (untyped console).log != null)
				(untyped console).log(str);
			#elseif lua
			untyped __define_feature__("use._hx_print", _hx_print(str));
			#elseif sys
			Sys.println(str);
			#else
			throw new haxe.exceptions.NotImplementedException()
			#end

			this.x = -openfl.Lib.application.window.stage.stageWidth;
			this.y = 0;

			showOrHide(true);
		}

		_stage.addEventListener(KeyboardEvent.KEY_DOWN, function(e:KeyboardEvent):Void {
            switch (e.keyCode) {
                case Keyboard.F1:
                    showOrHide();
            }
        });
	}

	var showTween:FlxTween;

	/**
	 * Displays the Console on-screen
	 * @param force 			true means it will force hide it no matter if its already hidden or not,
	 * 							false means it will force show it,
	 * 							null means it won't force at all.
	**/
	function showOrHide(force:Bool = null):Void {
		final beingShown:Bool = this.x == 0;
		final outside:Float = _stage.stageWidth;
		visible = beingShown;

		if (showTween != null) showTween.cancel();
		showTween = FlxTween.num(this.x, (beingShown || force == false) ? 0 : outside, 0.5, {ease: FlxEase.expoOut});
	}

	override function __enterFrame(deltaTime:Int) {
		super.__enterFrame(deltaTime);

		if (visible) {
			graphics.beginFill(0xFF000000, 1.0);
			graphics.drawRect(0, 0, 100, _stage.stageHeight);
			graphics.endFill();
		}
	}

	/**
	 * Formats the output of `trace` before printing it.
	**/
	function formatOutput(v:Dynamic, infos:PosInfos):String {
		var str:String = Std.string(v);
		if (infos == null)
			return str;
		var pstr:String = '[ LOG - ${infos.fileName}:${infos.lineNumber} ]';
		if (infos.customParams != null)
			for (customStr in infos.customParams)
				str += ", " + Std.string(customStr);
		return pstr + ": " + str;
	}
}
