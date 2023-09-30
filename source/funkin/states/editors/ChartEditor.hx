package funkin.states.editors;

import flixel.FlxCamera;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.display.FlxTiledSprite;
import flixel.graphics.FlxGraphic;
import flixel.group.FlxSpriteGroup;
import forever.ui.ForeverText;
import funkin.components.FNFState;
import openfl.geom.ColorTransform;
import openfl.geom.Rectangle;

class ChartEditor extends FNFState {
	public var backgroundLayer:FlxSpriteGroup;
	public var checkerboard:FlxTiledSprite;

	public var editorCamera:FlxCamera;
	public var uiCamera:FlxCamera;

	public var infoBar:ForeverText;

	var gridSize:Int = 50;

	var keyAmount:Int = 4;
	var noteFields:Int = 2;
	var stepLength:Int = 16;

	public function new():Void {
		super(true);
	}

	public override function create():Void {
		super.create();

		// show the mouse cursor
		FlxG.mouse.visible = true;

		// set up cameras
		editorCamera = FlxG.camera;
		uiCamera = new FlxCamera();
		uiCamera.bgColor = 0x00000000;
		FlxG.cameras.add(uiCamera, false);

		createBackground();
		createCharterElements();
		createCharterHUD();
	}

	function createBackground():Void {
		backgroundLayer = new FlxSpriteGroup();
		backgroundLayer.camera = editorCamera;
		add(backgroundLayer);

		var gridBG = new FlxTiledSprite(AssetHelper.getAsset('images/menus/chart/gridPurple', IMAGE), FlxG.width, FlxG.height);

		var bg1:FlxSprite = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
		bg1.setGraphicSize(Std.int(FlxG.width));
		bg1.screenCenter();
		bg1.alpha = 0.7;

		var coolBgPath:String = "images/menus/backgrounds/bgBlack";

		var bg2:FlxSprite = new FlxSprite().loadGraphic(AssetHelper.getAsset(coolBgPath, IMAGE));
		bg2.setGraphicSize(Std.int(FlxG.width));
		bg2.blend = DIFFERENCE;
		bg2.screenCenter();
		bg2.alpha = 0.07;

		backgroundLayer.add(gridBG);
		backgroundLayer.add(bg1);
		backgroundLayer.add(bg2);
	}

	function createCharterElements():Void {
		@:privateAccess
		var cbTexture:FlxGraphic = new FlxGraphic('board${gridSize}',
			FlxGridOverlay.createGrid(gridSize, gridSize, gridSize * 2, gridSize * 2, true, FlxColor.WHITE, FlxColor.BLACK), true);
		cbTexture.bitmap.colorTransform(new Rectangle(0, 0, gridSize * 2, gridSize * 2), new ColorTransform(1, 1, 1, 0.20));

		checkerboard = new FlxTiledSprite(cbTexture, gridSize * keyAmount * noteFields, gridSize * stepLength);
		checkerboard.camera = editorCamera;
		checkerboard.screenCenter(XY);
		add(checkerboard);
	}

	function createCharterHUD():Void {
		infoBar = new ForeverText(0, 0, 0, "", 24);
		infoBar.alignment = RIGHT;
		infoBar.camera = uiCamera;
		add(infoBar);

		updateHUDNodes();
	}

	function updateHUDNodes():Void {
		infoBar.text = 'Step: ${conductor.step} - Beat: ${conductor.beat}' + //
			' - Bar: ${conductor.bar}\nBPM: ${conductor.bpm}';
		infoBar.x = FlxG.width - infoBar.width - 5;
	}
}
