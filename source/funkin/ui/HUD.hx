package funkin.ui;

import flixel.FlxG;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;

class HUD extends FlxSpriteGroup {
	public var scoreBar:FlxText;

	public var cornerMark:FlxText;
	public var centerMark:FlxText;

	public var healthBar:HealthBar;

	public function new():Void {
		super();

		var downscroll:Bool = true;
		var font:String = AssetHelper.getAsset("vcr", FONT);

		cornerMark = new FlxText(0, 0, 0, 'FOREVER ENGINE v${Main.version}');
		cornerMark.setFormat(font, 16, 0xFFFFFFFF).setBorderStyle(OUTLINE, 0xFF000000, 2);
		cornerMark.setPosition(FlxG.width - (cornerMark.width + 5), 5);
		cornerMark.borderSize = 2;
		add(cornerMark);

		centerMark = new FlxText(0, (downscroll ? FlxG.height - 40 : 10), 0, '- NO SONG [NO DIFFICULTY] -');
		centerMark.setFormat(font, 20, 0xFFFFFFFF).setBorderStyle(OUTLINE, 0xFF000000, 2);
		centerMark.screenCenter(X);
		centerMark.antialiasing = true;
		add(centerMark);

		scoreBar = new FlxText(0, 0, FlxG.width / 2, "");
		scoreBar.setFormat(font, 18, 0xFFFFFFFF, CENTER, OUTLINE, 0xFF000000);
		scoreBar.borderSize = 1.5;
		add(scoreBar);

		updateScore();
	}

	public var divider:String = " • ";

	public function updateScore():Void {
		var tempScore:String = "";
		var scoreBarStyle:String = "Focused";

		switch (scoreBarStyle) {
			case "Focused":
				tempScore = "S: 5000"; // PlayState.gameInfo.score;
				tempScore += divider + "A: 95.35%"; // PlayState.gameInfo.accuracy;
				tempScore += divider + "CBs: 0"; // PlayState.gameInfo.comboBreaks;
				tempScore += divider + "R: S"; // PlayState.gameInfo.rank;

			default:
				tempScore = "Score: 5000"; // PlayState.gameInfo.score;
				tempScore += divider + "Accuracy: 95.35%"; // PlayState.gameInfo.accuracy;
				tempScore += divider + "Combo Breaks: 0"; // PlayState.gameInfo.comboBreaks;
				tempScore += divider + "Rank: S"; // PlayState.gameInfo.rank;
		}

		scoreBar.text = tempScore;
	}
}
