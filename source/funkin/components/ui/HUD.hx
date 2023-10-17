package funkin.components.ui;

import flixel.FlxG;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import forever.ForeverSprite;
import forever.ui.ForeverText;
import funkin.states.PlayState;

class HUD extends FlxSpriteGroup {
	public var scoreBar:ForeverText;
	public var cornerMark:ForeverText;
	public var centerMark:ForeverText;

	public var healthBar:HealthBar;
	public var iconP1:ForeverSprite;
	public var iconP2:ForeverSprite;

	public function new():Void {
		super();

		this.moves = false;

		final engineText:String = 'FOREVER ENGINE v${Main.version}';
		final hbY:Float = Settings.downScroll ? FlxG.height * 0.1 : FlxG.height * 0.875;

		add(healthBar = new HealthBar(0, hbY));
		healthBar.screenCenter(X);

		add(iconP1 = new HealthIcon("bf", true));
		add(iconP2 = new HealthIcon("bf", false));
		for (i in [iconP1, iconP2])
			i.y = healthBar.y - (i.height / 2.0);

		cornerMark = new ForeverText(0, 0, 0, engineText, 16);
		cornerMark.setPosition(FlxG.width - (cornerMark.width + 5), 5);
		cornerMark.alignment = RIGHT;
		cornerMark.borderSize = 2.0;
		add(cornerMark);

		centerMark = new ForeverText(0, (Settings.downScroll ? FlxG.height - 40 : 10), 0, '- NO SONG [NO DIFFICULTY] -', 20);
		centerMark.alignment = CENTER;
		centerMark.borderSize = 2.0;
		centerMark.screenCenter(X);
		add(centerMark);

		scoreBar = new ForeverText(healthBar.x - healthBar.width - 190, healthBar.y + 40, Std.int(healthBar.width + 150), "", 18);
		scoreBar.alignment = CENTER;
		scoreBar.borderSize = 1.5;
		add(scoreBar);

		updateScore();
	}

	public override function update(elapsed:Float):Void {
		super.update(elapsed);

		healthBar.bar.percent = PlayState.current.playStats.health * 50;

		final iconOffset:Int = 26;
		iconP1.x = healthBar.x + (healthBar.bar.width * (1 - healthBar.bar.percent / 100)) - iconOffset;
		iconP2.x = healthBar.x + (healthBar.bar.width * (1 - healthBar.bar.percent / 100)) - (iconP2.width - iconOffset);
	}

	public var divider:String = " • ";

	public function updateScore():Void {
		final game:PlayState = PlayState.current;

		var tempScore:String = 'Score: ${game.playStats.score}' //
			+ divider
			+ 'Accuracy: ${FlxMath.roundDecimal(game.playStats.accuracy, 2)}%' //
			+ divider
			+ 'Combo Breaks: ${game.playStats.comboBreaks}' //
			+ divider
			+ 'Rank: ${game.playStats.rank}';

		scoreBar.text = '< ${tempScore} >\n';

		scoreBar.screenCenter(X);
		
		DiscordRPC.updatePresence('Playing: ${game.currentSong.display}', '${scoreBar.text}');
	}
}
