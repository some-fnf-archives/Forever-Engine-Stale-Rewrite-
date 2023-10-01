package funkin.states;

import flixel.FlxCamera;
import flixel.addons.transition.FlxTransitionableState;
import forever.ForeverSprite;
import funkin.components.ChartLoader;
import funkin.components.FNFState;
import funkin.objects.*;
import funkin.states.editors.*;
import funkin.components.ui.HUD;

class PlayState extends FNFState {
	public var bg:ForeverSprite;
	public var playField:PlayField;
	public var hud:HUD;

	public var gameCamera:FlxCamera;
	public var hudCamera:FlxCamera;
	public var altCamera:FlxCamera;

	public var songName:String = "Test";

	public override function create():Void {
		super.create();

		FlxG.mouse.visible = true;

		gameCamera = FlxG.camera;
		hudCamera = new FlxCamera();
		altCamera = new FlxCamera();

		hudCamera.bgColor = altCamera.bgColor = 0x00000000;
		FlxG.cameras.add(hudCamera, false);
		FlxG.cameras.add(altCamera, false);

		Conductor.reset();
		ChartLoader.load("test", "hard");

		Conductor.bpm = Chart.current.metadata.bpmChanges[0].bpm;

		trace(Chart.current.notes);
		trace(Chart.current.metadata);

		add(bg = new ForeverSprite(0, 0, 'bg', {alpha: 0.3, color: FlxColor.BLUE}));
		add(playField = new PlayField());
		add(hud = new HUD());

		DiscordRPC.updatePresence('Playing: ${songName}', '${hud.scoreBar.text}');

		playField.camera = hud.camera = hudCamera;

		Conductor.onBeat.add(function(beat:Int):Void {
			processEvent(PlaySound("metronome.wav", 1.0));
		});

		FlxG.sound.playMusic(AssetHelper.getSound("songs/test/audio/Inst.ogg"));
	}

	public override function update(elapsed:Float):Void {
		Conductor.time += elapsed;
		// interpolation.
		if (Math.abs(Conductor.time - FlxG.sound.music.time / 1000.0) >= 0.05) {
			Conductor.time = FlxG.sound.music.time / 1000.0;
		}

		super.update(elapsed);
		checkKeys();
	}

	private function checkKeys():Void {
		if (FlxG.keys.justPressed.ESCAPE) {
			FlxG.sound.music.stop();
			FlxG.switchState(new funkin.states.menus.FreeplayMenu());
		}

		if (FlxG.keys.justPressed.SEVEN) {
			FlxG.sound.music.pause();
			DiscordRPC.updatePresence('Charting: ${songName}?', '${hud.scoreBar.text}');

			var charter:Charter = new Charter();
			charter.camera = altCamera;
			charter.ID = 1;
			openSubState(charter);
		}

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

	public override function closeSubState():Void {
		switch (FlxG.state.subState.ID) {
			case 1:
				DiscordRPC.updatePresence('Playing: ${songName}?', '${hud.scoreBar.text}');
		}

		super.closeSubState();
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
