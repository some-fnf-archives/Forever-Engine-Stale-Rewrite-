package external.crash;

import flixel.FlxState;
import flixel.FlxG;
import flixel.text.FlxText;

/**
 * In-game crash handler state.
 * 
 * @author crowplexus
**/
class CrashHandler extends FlxState {
	var statesStringArray:Array<String> = ["Main Menu", /*"Story Menu",*/ "Freeplay Menu", "Options Menu", /*"Gameplay"*/];
	var curSelected:Int = 0;

	var stateSelector:FlxText;
	var errorText:FlxText;

	public function new(errorMsg:String, details:String) {
		super();

		if (FlxG.sound.music != null) {
			FlxG.sound.music.stop();
		}

		errorText = new FlxText(0, 0, 0, 'Exception Occured:\n[${errorMsg}]\n\nDetails:\n${details}\n').setFormat(Paths.font('vcr.ttf'), 24);
		errorText.text += '\nPress ESCAPE or ENTER to go to the selected destination';
		errorText.alignment = CENTER;
		errorText.screenCenter(X);
		add(errorText);

		stateSelector = new FlxText(0, 0, 0, "< State State State >").setFormat(Paths.font('vcr.ttf'), 40);
		stateSelector.y = FlxG.height - stateSelector.height - 100;
		add(stateSelector);

		FlxG.collide(errorText, stateSelector, function(a, b) stateSelector.y = errorText.y + errorText.height);
		errorText.antialiasing = stateSelector.antialiasing = true;

		changeSelection();
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (FlxG.keys.anyJustPressed([LEFT, RIGHT]))
			changeSelection(FlxG.keys.justPressed.LEFT ? -1 : 1);

		if (FlxG.keys.justPressed.ESCAPE || FlxG.keys.justPressed.ENTER) {
			var newState:FlxState = switch (statesStringArray[curSelected].toLowerCase()) {
				case "main menu": new funkin.states.menus.MainMenu();
				// case "story menu": new funkin.states.menus.StoryMenu();
				case "freeplay menu": new funkin.states.menus.FreeplayMenu();
				case "options menu": new funkin.states.menus.OptionsMenu();
				// case "gameplay": new funkin.states.PlayState();
				default: new funkin.states.menus.TitleScreen();
			};

			if (statesStringArray[curSelected].toLowerCase() != 'playstate')
				FlxG.sound.playMusic(Paths.music('freakyMenu'), 0.7);
			FlxG.switchState(newState);
		}
	}

	private function changeSelection(change:Int = 0) {
		curSelected = flixel.math.FlxMath.wrap(curSelected + change, 0, statesStringArray.length - 1);
		stateSelector.text = '< ${statesStringArray[curSelected]} >';
		stateSelector.screenCenter(X);
	}
}
