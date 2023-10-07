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

typedef PlaySong = {
	var display:String;
	var folder:String;
	var difficulty:String;
}

class PlayState extends FNFState {
	public var currentSong:PlaySong = {display: "Test", folder: "test", difficulty: "normal"};
	public var playMode:Int = FREEPLAY;

	public var bg:ForeverSprite;
	public var playField:PlayField;
	public var hud:HUD;

	public var gameCamera:FlxCamera;
	public var hudCamera:FlxCamera;
	public var altCamera:FlxCamera;

	public var player:Character;
	public var enemy:Character;
	public var crowd:Character;

	public var inst:FlxSound;
	public var vocals:FlxSound;

	/**
	 * Constructs the Gameplay State
	 * 
	 * @param songInfo 			Assigns a new song to the PlayState.
	**/
	public function new(songInfo:PlaySong):Void {
		super();
		this.currentSong = songInfo;
	}

	public override function create():Void {
		super.create();

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		Conductor.time = -(60.0 / Conductor.bpm) * 4.0;

		FlxG.mouse.visible = false;

		// -- SET UP CAMERAS -- //
		gameCamera = FlxG.camera;
		hudCamera = new FlxCamera();
		altCamera = new FlxCamera();

		hudCamera.bgColor = altCamera.bgColor = 0x00000000;
		FlxG.cameras.add(hudCamera, false);
		FlxG.cameras.add(altCamera, false);

		// -- PREPARE PLAYFIELD -- //
		ChartLoader.load(currentSong.folder, currentSong.difficulty);
		Conductor.bpm = Chart.current.data.initialBPM;

		add(bg = new ForeverSprite(0, 0, 'bg', {alpha: 0.3, color: 0xFF606060}));
		add(playField = new PlayField());
		add(hud = new HUD());

		playField.camera = hud.camera = hudCamera;

		for (lane in playField.lanes)
			lane.changeStrumSpeed(Chart.current.data.initialSpeed);

		// -- PREPARE CHARACTERS -- //
		add(player = new Character(0, 0, "bf", true));
		add(enemy = new Character(0, 0, "bf", false));

		// test position characters
		player.screenCenter(XY);
		enemy.screenCenter(XY);
		player.x = FlxG.width / 2.0;
		enemy.x = FlxG.width / 6.0;

		// -- PREPARE AUDIO -- //
		inst = new FlxSound().loadEmbedded(AssetHelper.getSound('songs/${currentSong.folder}/audio/Inst.ogg'));
		vocals = new FlxSound().loadEmbedded(AssetHelper.getSound('songs/${currentSong.folder}/audio/Voices.ogg'));
		FlxG.sound.list.add(vocals);
		FlxG.sound.music = inst;

		DiscordRPC.updatePresence('Playing: ${currentSong.display}', '${hud.scoreBar.text}');
	}

	public override function update(elapsed:Float):Void {
		super.update(elapsed);

		if (Conductor.time >= 0 && !FlxG.sound.music.playing) {
			FlxG.sound.music.play();
			vocals.play();
		}
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
				enemy.playAnim(enemy.singingSteps[i], true);
			}
		}

		if (FlxG.keys.justPressed.SPACE)
			player.playAnim("hey", true);

		/*
			if (FlxG.keys.justPressed.SPACE) {
				Settings.downScroll = !Settings.downScroll;
				Settings.flush();

				if (!Settings.downScroll) {
					trace('uhhhhhh');
					bg.colorTween(FlxColor.LIME, 1, {ease: FlxEase.expoOut});
				} else {
					trace('peekaboo');
					bg.colorTween(FlxColor.BLUE, 1, {ease: FlxEase.expoOut});
				}
			}
		 */
	}

	public override function onBeat(beat:Int):Void {
		// processEvent(PlaySound("metronome.wav", 1.0));
		var chars:Array<Character> = [player, enemy];
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
				DiscordRPC.updatePresence('Playing: ${currentSong.display}', '${hud.scoreBar.text}');
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
		DiscordRPC.updatePresence('Charting: ${currentSong.display}', '${hud.scoreBar.text}');

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
			default: enemy;
			case 2: crowd;
		}
	}
}
