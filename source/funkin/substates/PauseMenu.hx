package funkin.substates;

import flixel.FlxSubState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.sound.FlxSound;
import flixel.tweens.FlxTween;
import forever.display.ForeverText;
import funkin.states.PlayState;
import funkin.states.menus.*;
import funkin.ui.Alphabet;
import lime.app.Future;
import lime.app.Promise;

using flixel.util.FlxStringUtil;

private enum PauseButton {
	PauseButton(name:String, call:Void->Void);
}

@:access(funkin.states.PlayState)
class PauseMenu extends FlxSubState {
	var pauseLists:Map<String, Array<PauseButton>> = [];
	var pauseGroup:FlxTypedGroup<Alphabet>;
	var pauseItems:Array<PauseButton> = [];

	var bg:FlxSprite;
	var curSel:Int = 0;
	var closing:Bool = true;

	public var pauseMusic:FlxSound;
	public var future:Future<FlxSound>;

	public function new():Void {
		super();

		pauseLists.set("default", [
			PauseButton('Resume', resumeSong),
			PauseButton('Restart Song', function():Void {
				closing = true;
				if (pauseMusic != null) pauseMusic.stop();
				FlxG.switchState(new PlayState(PlayState.current.songMeta));
			}),
			PauseButton('Change Options', function():Void {
				FlxG.switchState(new OptionsMenu(PlayState.current.songMeta));
			}),
			PauseButton('Exit to menu', function():Void {
				closing = true;
				if (pauseMusic != null) pauseMusic.stop();
				if (FlxG.sound.music != null) FlxG.sound.music.stop();
				FlxG.switchState(new FreeplayMenu());
			})
		]);

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

		final pauseInfoArray:Array<String> = [ // overengineering but i don't care. -Crow
			'Song: ${PlayState.current.songMeta.name}',
			'Difficulty: ${PlayState.current.songMeta.difficulty.toUpperCase()}',
			'Time: ${(FlxG.sound.music.time / 1000.0).formatTime()} / ${(FlxG.sound.music.length / 1000.0).formatTime()}'
			// 'Blueballed: ${PlayState.current.deathCount}'
		];

		for (i in 0...pauseInfoArray.length) {
			var infoText:ForeverText = new ForeverText(20, 15 + (30 * i), pauseInfoArray[i], 32);
			infoText.scrollFactor.set();
			infoText.updateHitbox();
			add(infoText);

			infoText.alpha = 0.0;
			infoText.x = FlxG.width - (infoText.width + 20);

			FlxTween.tween(infoText, {alpha: 1, y: infoText.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3 * i});
		}

		add(pauseGroup = new FlxTypedGroup<Alphabet>());
		reloadMenu(pauseLists.get("default"));
		updateSelection();

		// so in the original game the sound just plays when you trigger the menu so...
		FlxG.sound.play(AssetHelper.getAsset('audio/sfx/scrollMenu', SOUND));

		future = new Future<FlxSound>(function():FlxSound {
			pauseMusic = new FlxSound();
			@:privateAccess if (pauseMusic._sound == null)
				pauseMusic.loadEmbedded(Paths.music("breakfast"));

			pauseMusic.volume = 0;
			pauseMusic.play(true, FlxG.random.int(0, Std.int(pauseMusic.length * 0.5)));
			pauseMusic.looped = true;
			FlxG.sound.defaultMusicGroup.add(pauseMusic);

			return pauseMusic;
		}, true);
	}

	override function update(elapsed:Float):Void {
		super.update(elapsed);

		if (pauseMusic != null && pauseMusic.playing && pauseMusic.volume < 0.5)
			pauseMusic.volume += 0.01 * elapsed;

		if (!closing) {
			final callback = pauseItems[curSel].getParameters()[1];
			if (callback != null && Controls.ACCEPT)
				callback();

			if (Controls.BACK)
				resumeSong();

			if (pauseGroup.members.length > 1)
				if (Controls.UP_P || Controls.DOWN_P)
					updateSelection(Controls.UP_P ? -1 : 1);
		}
	}

	function resumeSong():Void {
		closing = true;
		if (pauseMusic != null) pauseMusic.stop();
		for (i in 0...pauseGroup.members.length)
			FlxTween.tween(pauseGroup.members[i], {alpha: 0}, 0.25, {ease: FlxEase.expoIn});

		forEachOfType(ForeverText, function(text:ForeverText):Void {
			FlxTween.tween(text, {alpha: 0}, 0.05, {ease: FlxEase.expoIn});
		});

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

	function reloadMenu(list:Array<PauseButton>):Void {
		while (pauseGroup.members.length != 0)
			pauseGroup.members.pop().destroy();

		for (i in 0...list.length) {
			final option:Alphabet = new Alphabet(-100, 100 + (60 * i), list[i].getParameters()[0]);
			option.isMenuItem = true;
			option.alpha = 0;
			option.targetY = i;
			FlxTween.tween(option, {x: 0.0}, 0.05, {ease: FlxEase.expoIn});
			pauseGroup.add(option);
		}
		
		pauseItems = list;
	}
}
