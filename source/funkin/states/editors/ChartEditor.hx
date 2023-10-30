package funkin.states.editors;

import flixel.FlxSubState;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.display.FlxTiledSprite;
import flixel.graphics.FlxGraphic;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import funkin.states.editors.objects.CharterUI;
import openfl.geom.ColorTransform;
import openfl.geom.Rectangle;

@:access(funkin.states.PlayState)
class ChartEditor extends FlxSubState {
	public var checkerboard:FlxTiledSprite;
	public var statusBar:CharterStatusBar;

	var gridSize:Int = 50;

	var keyAmount:Int = 4;
	var noteFields:Int = 2;
	var stepLength:Int = 16;

	var charterZoom:Float = 1.0;

	public function new():Void {
		super(0xFF000000);
	}

	function createBackground():Void {
		var bg1:FlxSprite;
		var bg2:FlxSprite;

		add(bg1 = new FlxSprite().makeSolid(FlxG.width, FlxG.height, 0xFF000000));
		add(bg2 = new FlxSprite().loadGraphic(AssetHelper.getAsset("menus/bgBlack", IMAGE)));
		bg1.antialiasing = false;

		// bg2.blend = DIFFERENCE;
		bg1.alpha = 0.7;
		bg2.alpha = 0.07;

		for (i in [bg1, bg2]) 
			i.scrollFactor.set();
	}

	function createCharterElements():Void {
		@:privateAccess
		var cbTexture:FlxGraphic = new FlxGraphic('board${gridSize}',
			FlxGridOverlay.createGrid(gridSize, gridSize, gridSize * 2, gridSize * 2, true, FlxColor.WHITE, FlxColor.BLACK), true);
		cbTexture.bitmap.colorTransform(new Rectangle(0, 0, gridSize * 2, gridSize * 2), new ColorTransform(1, 1, 1, 0.20));

		checkerboard = new FlxTiledSprite(cbTexture, gridSize * keyAmount * noteFields, gridSize * stepLength);
		checkerboard.screenCenter(XY);
		add(checkerboard);
	}

	function createCharterHUD():Void {
		add(statusBar = new CharterStatusBar());
		statusBar.y = FlxG.height - 110;
		updateHUDNodes();
	}

	override function create():Void {
		super.create();

		// show the mouse cursor
		FlxG.mouse.visible = true;

		createBackground();
		createCharterElements();
		createCharterHUD();
	}

	override function update(elapsed:Float):Void {
		super.update(elapsed);

		/*
			checkerboard.scale.y = charterZoom;
			checkerboard.height = ((FlxG.sound.music.length / ((Conductor.bpm / 60.0) * 1000.0)) * gridSize) * charterZoom;
		 */

		if (FlxG.mouse.wheel != 0) {
			if (FlxG.keys.pressed.SHIFT) {
				charterZoom = FlxMath.roundDecimal(FlxMath.bound(charterZoom + FlxG.mouse.wheel * 0.1, 0.5, 3.0), 3);
				trace(checkerboard.scale.y);
			}
		}

		if (FlxG.keys.justPressed.SPACE) {
			if (FlxG.sound.music != null) {
				if (FlxG.sound.music.playing)
					FlxG.sound.music.pause();
				else
					FlxG.sound.music.resume();
			}
		}

		if (FlxG.keys.justPressed.ESCAPE) {
			FlxG.state.closeSubState();
			@:privateAccess AssetHelper.clearCacheEntirely();
		}

		if (FlxG.sound.music != null && FlxG.sound.music.playing) {
			updateHUDNodes();
		}
	}

	function updateHUDNodes():Void {
		statusBar.updateStatusText("" //
			+ '> Step: ${Conductor.step} • Beat: ${Conductor.beat}' //
			+ '\n> Bar: ${Conductor.bar} • BPM: ${Conductor.bpm}' //
		);
	}
}
