package funkin.states;

import forever.ForeverSprite;
import forever.config.Settings;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import funkin.components.ChartLoader;
import funkin.objects.*;
import funkin.ui.HUD;

class PlayState extends FlxState {
	public var bg:ForeverSprite;
	public var hud:HUD;
	public var playField:PlayField;

	public override function create():Void {
		super.create();

		Conductor.reset();
		Conductor.bpm = 150.0;

		FlxG.sound.playMusic(AssetHelper.getSound("songs/test/audio/Inst.ogg"));

		add(bg = new ForeverSprite().addGraphic('bg'/*, {alpha: 0.3}*/));
		bg.alpha = 0.3;

		add(hud = new HUD());
		add(playField = new PlayField());

		Conductor.onBeat.add(function(beat:Int):Void {
			processEvent(PlaySound("metronome.wav", 1.0));
		});
	}

	public override function update(elapsed:Float):Void {
		super.update(elapsed);

		Conductor.update(elapsed);
		Conductor.time += elapsed;

		checkKeys();
	}

	private function checkKeys():Void
	{
		if (FlxG.keys.justPressed.R) {
			trace("reset");
			FlxG.resetState();
		}

		// what the fuck am I doing

		/*if (FlxG.keys.justPressed.SPACE) {
			Settings.downScroll = !Settings.downScroll;
			Settings.flush();

			if (!Settings.downScroll) {
				trace('uhhhhhh');
				bg.tween({y: FlxG.height}, 1, {ease: FlxEase.expoOut});
			} else {
				trace('peekaboo');
				bg.tween({y: 0}, 1, {ease: FlxEase.expoOut});
			}
		}*/
	}

	public function preloadEvent(which:ForeverEvents):Void {
		switch (which) {
			case ChangeCharacter(who, toCharacter):
			/*
				// character preloader here, so like
				var newChar:Character = new Character(0, 0);
				newChar.loadCharacter(toCharacter);
				newChar.alpha = 0.000001;
				characterGroup.add(newChar);
			 */
			default:
				// do nothing
		}
	}

	public function processEvent(which:ForeverEvents):Void {
		switch (which) {
			case FocusCamera(who, noEasing):
			//
			case ChangeCharacter(who, toCharacter):
			//
			case PlaySound(soundName, volume):
				FlxG.sound.play(AssetHelper.getSound('sounds/${soundName}'), volume);
			default:
				// do nothing
		}
	}
}
