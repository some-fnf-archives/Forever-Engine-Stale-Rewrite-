package funkin.states.subStates;

import flixel.FlxSubState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.tweens.FlxTween;
import funkin.components.ui.Alphabet;
import funkin.states.menus.*;

private enum PauseButton {
	PauseButton(name:String, call:Void->Void);
}

@:access(funkin.states.PlayState)
class PauseMenu extends FlxSubState {
	var bg:FlxSprite;
	var pauseItems:Array<PauseButton> = [];
	var pauseGroup:FlxTypedGroup<Alphabet>;
	var curSel:Int = 0;

	var closing:Bool = true;

	public function new():Void {
		super();

		pauseItems = [
			PauseButton('Resume', resumeSong),
			PauseButton('Restart Song', function():Void {
				final curMusic = PlayState.current.currentSong;
				FlxG.switchState(new PlayState(curMusic));
			}),
			PauseButton('Options', null),
			PauseButton('Exit to menu', function():Void {
				FlxG.sound.music.stop();
				FlxG.switchState(new FreeplayMenu());
			})
		];

		bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);

		bg.alpha = 0;
		FlxTween.tween(bg, {alpha: 0.3}, 0.5, {
			ease: FlxEase.expoIn,
			onComplete: function(twn:FlxTween) {
				closing = false;
				updOptions(0);
			}
		});

		add(pauseGroup = new FlxTypedGroup<Alphabet>());

		for (i in 0...pauseItems.length) {
			var option:Alphabet = new Alphabet(0, 100 + (60 * i), pauseItems[i].getParameters()[0]);
			option.isMenuItem = true;
			option.alpha = 0;
			option.targetY = i;
			FlxTween.tween(option, {alpha: 0.6}, 0.5, {ease: FlxEase.expoIn});
			pauseGroup.add(option);
		}
	}

	public override function update(elapsed:Float):Void {
		super.update(elapsed);

		final callback = pauseItems[curSel].getParameters()[1];
		if (callback != null && (Controls.ACCEPT || Controls.BACK) && !closing)
			callback();

		if (Controls.UP_P || Controls.DOWN_P)
			updOptions(Controls.UP_P ? -1 : 1);
	}

	function resumeSong():Void {
		closing = true;
		for (i in 0...pauseGroup.members.length)
			FlxTween.tween(pauseGroup.members[i], {alpha: 0}, 0.25, {ease: FlxEase.expoIn});

		FlxTween.tween(bg, {alpha: 0}, 0.5, {
			ease: FlxEase.expoIn,
			onComplete: function(twn:FlxTween) {
				FlxG.state.closeSubState();
			}
		});
	}

	function updOptions(upd:Int = 0):Void {
		curSel = FlxMath.wrap(curSel + upd, 0, pauseGroup.members.length - 1);

		if (upd != 0)
			FlxG.sound.play(AssetHelper.getAsset('music/sfx/scrollMenu', SOUND));

		for (i in 0...pauseGroup.members.length) {
			final let:Alphabet = pauseGroup.members[i];
			let.targetY = let.targetY - upd;
			let.alpha = let.targetY == 0 ? 1.0 : 0.6;
		}
	}
}
