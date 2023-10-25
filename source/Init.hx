package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.addons.transition.FlxTransitionSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.graphics.FlxGraphic;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import forever.Controls;

/**
 * This is the initialization class, it simply modifies and initializes a few important variables
 * add anything in here for the game to initialize before beginning
**/
class Init extends FlxState {
	public override function create():Void {
		super.create();

		FlxG.fixedTimestep = false;
		FlxG.mouse.useSystemCursor = true;
		FlxG.game.focusLostFramerate = 10;
		FlxG.mouse.visible = false;

		forever.Settings.load();

		// FlxGraphic.defaultPersist = true;
		flixel.FlxSprite.defaultAntialiasing = forever.Settings.globalAntialias;

		setupTransition();

		Controls.current = new BaseControls();
		#if DISCORD forever.core.DiscordWrapper.initialize("1157951594667708416"); #end
		#if MODS forever.core.Mods.initialize(); #end

		// make sure there is a note configuration set
		funkin.objects.notes.NoteConfig.reloadConfig();

		// precache and exclude some stuff from being cleared in cache.
		final cacheGraphics:haxe.ds.StringMap<flixel.graphics.FlxGraphic> = [
			"boldAlphabet" => AssetHelper.getGraphic(AssetHelper.getPath("images/ui/letters/bold", IMAGE), "boldAlphabet")
		];

		final cacheSounds:haxe.ds.StringMap<openfl.media.Sound> = [
			"scrollMenu" => AssetHelper.getSound("audio/sfx/scrollMenu", "scrollMenu"),
			"cancelMenu" => AssetHelper.getSound("audio/sfx/cancelMenu", "cancelMenu"),
			"confirmMenu" => AssetHelper.getSound("audio/sfx/confirmMenu", "confirmMenu")
		];

		for (k => v in cacheGraphics)
			AssetHelper.excludedGraphics.set(k, v);

		for (k => v in cacheSounds)
			AssetHelper.excludedSounds.set(k, v);

		FlxTransitionableState.skipNextTransIn = true;

		FlxG.switchState(Type.createInstance(Main.initialState, []));
	}

	function setupTransition():Void {
		var graphic:FlxGraphic = FlxGraphic.fromClass(GraphicTransTileDiamond);
		graphic.destroyOnNoUse = false;

		final transition:TransitionTileData = {
			asset: graphic,
			width: 32,
			height: 32,
			frameRate: 24
		};
		final transitionArea:FlxRect = FlxRect.get(-200, -200, FlxG.width * 2.0, FlxG.height * 2.0);

		FlxTransitionableState.defaultTransIn = new TransitionData(FADE, 0xFF000000, 0.4, FlxPoint.get(0, -1), transition, transitionArea);
		FlxTransitionableState.defaultTransOut = new TransitionData(FADE, 0xFF000000, 0.4, FlxPoint.get(0, 1), transition, transitionArea);
	}
}
