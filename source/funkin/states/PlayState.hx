package funkin.states;

import flixel.FlxCamera;
import flixel.sound.FlxSound;
import forever.ForeverSprite;
import funkin.components.ChartLoader;
import funkin.states.base.FNFState;
import funkin.objects.*;
import funkin.states.editors.*;
import funkin.states.menus.*;
import funkin.components.ui.HUD;

enum abstract GameplayMode(Int) to Int {
	var STORY = 0;
	var FREEPLAY = 1;
	var CHARTER = 2;
}

class PlayState extends FNFState {
	public var songName:String = "lost-cause";
	public var playMode:Int = FREEPLAY;

	public var bg:ForeverSprite;
	public var playField:PlayField;
	public var hud:HUD;

	public var gameCamera:FlxCamera;
	public var hudCamera:FlxCamera;
	public var altCamera:FlxCamera;

	public var player:Character;
	public var opponent:Character;
	public var crowd:Character;

	public var inst:FlxSound;
	public var vocals:FlxSound;

	public override function create():Void {
		super.create();

		FlxG.mouse.visible = true;

		gameCamera = FlxG.camera;
		hudCamera = new FlxCamera();
		altCamera = new FlxCamera();

		hudCamera.bgColor = altCamera.bgColor = 0x00000000;
		FlxG.cameras.add(hudCamera, false);
		FlxG.cameras.add(altCamera, false);

		ChartLoader.load(songName, "hard");
		Conductor.bpm = Chart.current.metadata.initialBPM;

		add(bg = new ForeverSprite(0, 0, 'bg', {alpha: 0.3, color: FlxColor.BLUE}));
		add(playField = new PlayField());
		add(hud = new HUD());

		for (lane in playField.lanes)
			lane.changeStrumSpeed(Chart.current.metadata.initialSpeed);

		add(player = new Character(0, 0, "bf-psych", true));
		add(opponent = new Character(0, 0, "pico-crow", false));

		// test position characters
		player.screenCenter(XY);
		opponent.screenCenter(XY);
		player.x = FlxG.width / 2.0;
		opponent.x = FlxG.width / 6.0;

		playField.camera = hud.camera = hudCamera;

		inst = new FlxSound().loadEmbedded(AssetHelper.getSound('songs/${songName}/audio/Inst.ogg'));
		vocals = new FlxSound().loadEmbedded(AssetHelper.getSound('songs/${songName}/audio/Voices.ogg'));
		FlxG.sound.list.add(vocals);
		FlxG.sound.music = inst;

		FlxG.sound.music.play();
		vocals.play();

		DiscordRPC.updatePresence('Playing: ${songName}', '${hud.scoreBar.text}');
	}

	public override function update(elapsed:Float):Void {
		super.update(elapsed);
		checkKeys();
	}

	private function checkKeys():Void {
		if (FlxG.keys.justPressed.ESCAPE)
			endPlay();

		if (FlxG.keys.justPressed.SEVEN)
			openCharter();

		var controls:Array<Bool> = [Controls.LEFT, Controls.DOWN, Controls.UP, Controls.RIGHT];

		for (i in 0...controls.length) {
			if (controls[i] == true) {
				player.playAnim(player.singingSteps[i], true);
				opponent.playAnim(opponent.singingSteps[i], true);
			}
		}

		if (FlxG.keys.justPressed.SPACE)
			player.playAnim("hey", true);

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

	public override function onBeat(beat:Int):Void {
		// processEvent(PlaySound("metronome.wav", 1.0));
		var chars:Array<Character> = [player, opponent];
		if (crowd != null)
			chars.push(crowd);

		for (character in chars) {
			if (beat % character.danceInterval == 0)
				character.dance();
		}
	}

	public override function closeSubState():Void {
		switch (FlxG.state.subState.ID) {
			case 1:
				DiscordRPC.updatePresence('Playing: ${songName}', '${hud.scoreBar.text}');
		}

		super.closeSubState();
	}

	public function preloadEvent(which:ForeverEvents):Void {
		switch (which) {
			case ChangeCharacter(who, toCharacter):
				var newChar:Character = new Character(0, 0);
				newChar.loadCharacter(toCharacter);
				newChar.alpha = 0.000001;
			// characterGroup.add(newChar);
			default:
				// do nothing
		}
	}

	public function processEvent(which:ForeverEvents):Void {
		switch (which) {
			case FocusCamera(who, noEasing):
			//
			case ChangeCharacter(who, toCharacter):
				getCharacterFromID(who).loadCharacter(toCharacter);
			case PlaySound(soundName, volume):
				FlxG.sound.play(AssetHelper.getSound('sounds/${soundName}'), volume);
			default:
				// do nothing
		}
	}

	// -- HELPER FUNCTIONS -- //

	function openCharter():Void {
		FlxG.sound.music.pause();
		DiscordRPC.updatePresence('Charting: ${songName}', '${hud.scoreBar.text}');

		var charter:Charter = new Charter();
		charter.camera = altCamera;
		charter.ID = 1;

		openSubState(charter);
	}

	function endPlay():Void {
		FlxG.sound.music.stop();
		vocals.stop();

		switch (playMode) {
			default:
				FlxG.switchState(new FreeplayMenu());
		}
	}

	@:noCompletion @:noPrivateAccess
	function getCharacterFromID(id:Int):Character {
		return switch (id) {
			case 0: player;
			default: opponent;
			case 2: crowd;
		}
	}
}
