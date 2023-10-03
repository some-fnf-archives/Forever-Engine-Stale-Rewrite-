package funkin.components.ui;

import flixel.FlxG;
import flixel.group.FlxSpriteGroup;
import forever.ui.ForeverText;

class HUD extends FlxSpriteGroup {
	public var scoreBar:ForeverText;

	public var cornerMark:ForeverText;
	public var centerMark:ForeverText;

	public var healthBar:HealthBar;

	public function new():Void {
		super();

		var engineText:String = 'FOREVER ENGINE v${Main.version}' + //
			'\nEverything here is\npretty much unfinished!';

		cornerMark = new ForeverText(0, 0, 0, engineText, 16);
		cornerMark.setPosition(FlxG.width - (cornerMark.width + 5), 5);
		cornerMark.alignment = RIGHT;
		cornerMark.borderSize = 2.0;
		add(cornerMark);

		centerMark = new ForeverText(0, (Settings.downScroll ? FlxG.height - 40 : 10), 0, '- NO SONG [NO DIFFICULTY] -', 20);
		centerMark.alignment = CENTER;
		centerMark.borderSize = 2.0;
		centerMark.screenCenter(X);
		centerMark.antialiasing = true;
		add(centerMark);

		scoreBar = new ForeverText(0, 0, 700, "", 18);
		scoreBar.alignment = CENTER;
		scoreBar.borderSize = 1.5;
		add(scoreBar);

		updateScore();
	}

	public var divider:String = " • ";

	public function updateScore():Void {
		var tempScore:String = "";

		tempScore = "Score: 5000"; // PlayState.gameInfo.score;
		tempScore += divider + "Accuracy: 95.35%"; // PlayState.gameInfo.accuracy;
		tempScore += divider + "Combo Breaks: 0"; // PlayState.gameInfo.comboBreaks;
		tempScore += divider + "Rank: S"; // PlayState.gameInfo.rank;

		scoreBar.text = '< ${tempScore} >\n';

		scoreBar.screenCenter(X);
	}
}
