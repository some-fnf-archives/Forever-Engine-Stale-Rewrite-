package funkin.ui;

import flixel.FlxG;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import forever.display.ForeverText;
import funkin.components.Timings;
import funkin.states.PlayState;

class HUD extends FlxSpriteGroup {
	public var scoreBar:ForeverText;
	public var centerMark:ForeverText;

	public var healthBar:HealthBar;
	public var iconP1:HealthIcon;
	public var iconP2:HealthIcon;

	public function new():Void {
		super();

		final hbY:Float = Settings.downScroll ? FlxG.height * 0.1 : FlxG.height * 0.875;

		add(healthBar = new HealthBar(0, hbY));
		healthBar.screenCenter(X);

		add(iconP1 = new HealthIcon(PlayState.current?.player?.icon ?? "face", true));
		add(iconP2 = new HealthIcon(PlayState.current?.enemy?.icon ?? "face", false));
		for (i in [iconP1, iconP2])
			i.y = healthBar.y - (i.height * 0.5);

		centerMark = new ForeverText(0, (Settings.downScroll ? FlxG.height - 40 : 15), 0, '- NO SONG [NO DIFFICULTY] -', 20);
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

		healthBar.bar.percent = Timings.health * 50;

		final iconOffset:Int = 25;
		iconP1.x = healthBar.x + (healthBar.bar.width * (1 - healthBar.bar.percent / 100)) - iconOffset;
		iconP2.x = healthBar.x + (healthBar.bar.width * (1 - healthBar.bar.percent / 100)) - (iconP2.width - iconOffset);

		for (icon in [iconP1, iconP2]) {
			final weight:Float = 1.0 - 1.0 / Math.exp(5.0 * elapsed);
			icon.scale.set(FlxMath.lerp(icon.scale.x, 1.0, weight), FlxMath.lerp(icon.scale.y, 1.0, weight));
			// icon.updateHitbox();
		}
	}

	public var divider:String = " • ";

	public function updateScore():Void {
		if (scoreBar == null)
			return;

		final game:PlayState = PlayState.current;

		var tempScore:String = 'Score: ${Timings.score}' //
			+ divider
			+ 'Accuracy: ${FlxMath.roundDecimal(Timings.accuracy, 2)}%' //
			+ divider
			+ 'Combo Breaks: ${Timings.comboBreaks}' //
			+ divider
			+ 'Rank: ${Timings.rank}';

		scoreBar.text = '< ${tempScore} >\n';
		scoreBar.screenCenter(X);

		DiscordRPC.updatePresence('Playing: ${game.currentSong.display}', '${scoreBar.text}');
	}

	public function onBeat(beat:Int):Void {
		for (icon in [iconP1, iconP2])
			icon.scale.set(1.15, 1.15);
		// icon.updateHitbox();
	}
}
