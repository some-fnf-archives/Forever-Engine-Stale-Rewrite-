package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.addons.transition.FlxTransitionSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.graphics.FlxGraphic;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import forever.config.Controls;

/**
 * This is the initialization class, it simply modifies and initializes a few important variables
 * add anything in here for the game to initialize before beginning
**/
class Init extends FlxState {
	public override function create():Void {
		super.create();

		FlxG.fixedTimestep = false;
		FlxG.mouse.useSystemCursor = true;
		FlxG.mouse.visible = false;

		FlxGraphic.defaultPersist = true;
		flixel.FlxSprite.defaultAntialiasing = forever.config.Settings.globalAntialias;

		setupTransition();

		Controls.current = new BaseControls();
		new forever.data.DiscordWrapper("1157951594667708416");

		// make sure there is a note configuration set
		funkin.objects.notes.NoteConfig.reloadConfig();

		FlxG.switchState(Type.createInstance(Main.initialState, []));
	}

	function setupTransition():Void {
		var graphic:FlxGraphic = FlxGraphic.fromClass(GraphicTransTileDiamond);
		graphic.destroyOnNoUse = false;

		var transition:TransitionTileData = {
			asset: graphic,
			width: 32,
			height: 32,
			frameRate: 24
		};
		var transitionArea:FlxRect = FlxRect.get(-200, -200, FlxG.width * 2.0, FlxG.height * 2.0);

		FlxTransitionableState.defaultTransIn = new TransitionData(FADE, 0xFF000000, 0.4, FlxPoint.get(-1, 0), transition, transitionArea);
		FlxTransitionableState.defaultTransOut = new TransitionData(FADE, 0xFF000000, 0.4, FlxPoint.get(1, 0), transition, transitionArea);
	}
}
