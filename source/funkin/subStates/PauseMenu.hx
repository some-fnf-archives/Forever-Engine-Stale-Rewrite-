package funkin.subStates;

import flixel.FlxSubState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.tweens.FlxTween;
import funkin.ui.Alphabet;
import funkin.states.PlayState;
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
				closing = true;
				final curMusic = PlayState.current.currentSong;
				FlxG.switchState(new PlayState(curMusic));
			}),
			PauseButton('Change Options', null),
			PauseButton('Exit to menu', function():Void {
				closing = true;
				FlxG.sound.music.stop();
				FlxG.switchState(new FreeplayMenu());
			})
		];

		bg = new FlxSprite().makeSolid(FlxG.width, FlxG.height, 0xFF000000);
		bg.antialiasing = false;
		bg.alpha = 0;
		add(bg);

		FlxTween.tween(bg, {alpha: 0.6}, 0.5, {
			ease: FlxEase.expoIn,
			onComplete: function(twn:FlxTween) {
				closing = false;
				updateSelection(0);
			}
		});

		add(pauseGroup = new FlxTypedGroup<Alphabet>());

		for (i in 0...pauseItems.length) {
			final option:Alphabet = new Alphabet(0, 100 + (60 * i), pauseItems[i].getParameters()[0]);
			option.isMenuItem = true;
			option.alpha = 0;
			option.targetY = i;
			FlxTween.tween(option, {alpha: 0.6}, 0.5, {ease: FlxEase.expoIn});
			pauseGroup.add(option);
		}

		updateSelection();
	}

	override function update(elapsed:Float):Void {
		super.update(elapsed);

		if (!closing) {
			final callback = pauseItems[curSel].getParameters()[1];
			if (callback != null && (Controls.ACCEPT || Controls.BACK))
				callback();

			if (pauseGroup.members.length > 1)
				if (Controls.UP_P || Controls.DOWN_P)
					updateSelection(Controls.UP_P ? -1 : 1);
		}
	}

	function resumeSong():Void {
		closing = true;
		for (i in 0...pauseGroup.members.length)
			FlxTween.tween(pauseGroup.members[i], {alpha: 0}, 0.25, {ease: FlxEase.expoIn});

		FlxTween.tween(bg, {alpha: 0}, 0.5, {
			ease: FlxEase.expoIn,
			onComplete: function(twn:FlxTween) FlxG.state.closeSubState()
		});
	}

	function updateSelection(newSel:Int = 0):Void {
		curSel = FlxMath.wrap(curSel + newSel, 0, pauseGroup.members.length - 1);

		if (newSel != 0)
			FlxG.sound.play(AssetHelper.getAsset('audio/sfx/scrollMenu', SOUND));

		for (i in 0...pauseGroup.members.length) {
			final let:Alphabet = pauseGroup.members[i];
			let.targetY = i - curSel;
			let.alpha = let.targetY == 0 ? 1.0 : 0.6;
		}
	}
}
