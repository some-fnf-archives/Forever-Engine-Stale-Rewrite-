package funkin.states;

import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import forever.ForeverSprite;
import funkin.components.FNFState;
import funkin.components.ChartLoader;
import funkin.objects.*;
import funkin.ui.HUD;

class PlayState extends FNFState {
	public var bg:ForeverSprite;
	public var hud:HUD;
	public var playField:PlayField;

	public function new():Void {
		super(true); // initialize conductor when creating playstate
	}

	public override function create():Void {
		super.create();

		conductor.bpm = 150.0;

		ChartLoader.load("test", "hard");

		FlxG.sound.playMusic(AssetHelper.getSound("songs/test/audio/Inst.ogg"));

		bg = new ForeverSprite(0, 0, 'bg', {alpha: 0.3, color: FlxColor.BLUE});
		add(bg);

		playField = new PlayField();
		add(playField);

		hud = new HUD();
		add(hud);

		conductor.onBeat.add(function(beat:Int):Void {
			processEvent(PlaySound("metronome.wav", 1.0));
		});
	}

	public override function update(elapsed:Float):Void {
		conductor.time += elapsed;
		// interpolation.
		if (Math.abs(conductor.time - FlxG.sound.music.time / 1000.0) >= 0.05) {
			conductor.time = FlxG.sound.music.time / 1000.0;
		}

		super.update(elapsed);
		checkKeys();
	}

	private function checkKeys():Void {
		if (FlxG.keys.justPressed.R)
			FlxG.resetState();

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
