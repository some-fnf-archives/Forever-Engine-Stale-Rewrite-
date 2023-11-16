package funkin.states.menus;

import forever.display.ForeverText;
import funkin.states.base.BaseMenuState;
import funkin.states.menus.FreeplayMenu.FreeplaySong;

class StoryMenu extends BaseMenuState {
	public static var weeks:Array<StoryWeek> = [];

	var weekName:ForeverText;
	var weekScore:ForeverText;

	override function create() {
		super.create();

		// -- USER INTERFACE -- //

		final yellowBG:FlxSprite = new FlxSprite(0, 50).makeSolid(FlxG.width, FlxG.height - 100, FlxColor.fromRGB(255, 226, 127));

		weekScore = new ForeverText(10, 5, FlxG.width * 0.5, "WEEK SCORE: 1000000", 40);
		weekName = new ForeverText((FlxG.width/2) - 10, 5, FlxG.width/2, "WEEK NAME", 40);  // agr sim o calculo ta certo :D 
		weekScore.borderSize = weekName.borderSize = 0.0;
		weekName.alignment = RIGHT;

		add(yellowBG);
		add(weekScore);
		add(weekName);
	}

	override function update(elapsed:Float):Void {
		super.update(elapsed);

		if (Controls.BACK)
			FlxG.switchState(new MainMenu());
	}
}

// faz um negocio de selecionar week aqui?
// tipo updateSelection sei la 

@:structInit class StoryWeek {
	public var tagline:String = "My Week";
	public var songs:Array<FreeplaySong> = null;
	public var image:String = "week1";

	public var characters:String = null;
	public var difficulties:Array<String> = null;

	public var startsLocked:Bool = false;
}
