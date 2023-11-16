package funkin.states.menus;

import forever.display.ForeverText;
import funkin.states.base.BaseMenuState;
import funkin.states.menus.FreeplayMenu.FreeplaySong;

class StoryMenu extends BaseMenuState {
	public static var weeks:Array<StoryWeek> = [];

	var weekName:ForeverText;
	var weekScore:ForeverText;

	var arrowLeft:FlxSprite;
	var arrowRight:FlxSprite;

	override function create() {
		super.create();

		this.canChangeAlternative = true;
		this.canChangeMods        = true;

		// -- USER INTERFACE -- //

		final yellowBG:FlxSprite = new FlxSprite(0, 50).makeSolid(FlxG.width, FlxG.height - 100, FlxColor.fromRGB(255, 226, 127));

		weekScore = new ForeverText(10, 5, FlxG.width * 0.5, "WEEK SCORE: 1000000", 40);
		weekName = new ForeverText((FlxG.width * 0.5) - 10, 5, FlxG.width * 0.5, "WEEK NAME", 40);
		weekScore.borderSize = weekName.borderSize = 0.0;
		weekName.alignment = RIGHT;

		var arrowUI = AssetHelper.getAsset("menus/story/arrows", ATLAS_SPARROW);

		arrowLeft = new FlxSprite(FlxG.width * 0.5 - 175, 3.2 * FlxG.height * 0.25);
		arrowLeft.frames = arrowUI;
		arrowLeft.animation.addByPrefix("idle", "arrow push left");
		arrowLeft.animation.addByPrefix("pressed", "arrow left");
		arrowLeft.animation.play("idle");

		arrowRight = new FlxSprite(FlxG.width * 0.5 + 175, 3.2 * FlxG.height * 0.25);
		arrowRight.frames = arrowUI;
		arrowRight.animation.addByPrefix("idle", "arrow push right");
		arrowRight.animation.addByPrefix("pressed", "arrow right");
		arrowRight.animation.play("idle");

		add(yellowBG);

		add(arrowLeft);
		add(arrowRight);

		add(weekScore);
		add(weekName);
	}

	override function update(elapsed:Float):Void {
		super.update(elapsed);

		if (Controls.BACK)
			FlxG.switchState(new MainMenu());
	}

	/*
	override function updateSelection(newSel:Int = 0):Void {
		super.updateSelection(newSel);
	}

	override function updateSelectionAlt(newSelAlt:Int = 0):Void {
		super.updateSelectionAlt(newSelAlt);
	}
	*/
}

@:structInit class StoryWeek {
	public var tagline:String = "My Week";
	public var songs:Array<FreeplaySong> = null;
	public var image:String = "week1";

	public var characters:String = null;
	public var difficulties:Array<String> = null;

	public var startsLocked:Bool = false;
}
