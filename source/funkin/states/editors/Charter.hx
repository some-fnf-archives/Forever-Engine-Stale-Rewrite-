package funkin.states.editors;

import flixel.addons.display.FlxGridOverlay;
import flixel.addons.display.FlxTiledSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.FlxGraphic;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import forever.ui.ForeverText;
import funkin.components.FNFSubState;
import openfl.geom.ColorTransform;
import openfl.geom.Rectangle;

class Charter extends FNFSubState {
	public var backgroundLayer:FlxSpriteGroup;
	public var checkerboard:FlxTiledSprite;

	public var infoBar:ForeverText;

	var gridSize:Int = 50;

	var keyAmount:Int = 4;
	var noteFields:Int = 2;
	var stepLength:Int = 16;

	var charterZoom:Float = 1.0;

	public function new():Void {
		super(0xFF000000);
	}

	function createBackground():Void {
		backgroundLayer = new FlxSpriteGroup();
		add(backgroundLayer);

		// var gridBG = new FlxTiledSprite(AssetHelper.getAsset('images/menus/charter/gridPurple', IMAGE), FlxG.width, FlxG.height);

		var bg1:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		var bg2:FlxSprite = new FlxSprite().loadGraphic(AssetHelper.getAsset("images/menus/backgrounds/bgBlack", IMAGE));

		bg2.blend = DIFFERENCE;
		bg1.alpha = 0.7;
		bg2.alpha = 0.07;

		// backgroundLayer.add(gridBG);
		backgroundLayer.add(bg1);
		backgroundLayer.add(bg2);
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
		infoBar = new ForeverText(0, 0, 0, "", 24);
		infoBar.alignment = RIGHT;
		add(infoBar);

		updateHUDNodes();
	}

	public override function create():Void {
		super.create();

		// show the mouse cursor
		FlxG.mouse.visible = true;

		createBackground();
		createCharterElements();
		createCharterHUD();
	}

	public override function update(elapsed:Float):Void {
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

		if (FlxG.keys.justPressed.ESCAPE)
			FlxG.switchState(new PlayState());

		super.update(elapsed);
	}

	function updateHUDNodes():Void {
		infoBar.text = 'Step: ${Conductor.step} - Beat: ${Conductor.beat}' + //
			' - Bar: ${Conductor.bar}\nBPM: ${Conductor.bpm}';
		infoBar.x = FlxG.width - infoBar.width - 5;
	}
}
