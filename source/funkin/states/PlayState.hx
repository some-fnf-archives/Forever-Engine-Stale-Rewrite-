package funkin.states;

import flixel.FlxCamera;
import flixel.sound.FlxSound;
import forever.ForeverSprite;
import funkin.components.ChartLoader;
import funkin.components.ScoreManager;
import funkin.components.ui.HUD;
import funkin.objects.*;
import funkin.objects.notes.Note;
import funkin.stages.DadStage;
import funkin.states.base.FNFState;
import funkin.states.editors.*;
import funkin.states.menus.*;

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
	public static var current:PlayState;

	public var currentSong:PlaySong = {display: "Test", folder: "test", difficulty: "normal"};
	public var playMode:Int = FREEPLAY;

	public var bg:ForeverSprite;
	public var playField:PlayField;
	public var playStats:ScoreManager;
	public var hud:HUD;

	public var gameCamera:FlxCamera;
	public var hudCamera:FlxCamera;
	public var altCamera:FlxCamera;

	public var stage:StageBuilder;

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
		current = this;

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
		playStats = new ScoreManager();

		add(stage = new DadStage());
		add(playField = new PlayField());
		add(hud = new HUD());

		// update song display so it shows song name and difficulty (like intended)
		hud.centerMark.text = '- ${currentSong.display} [${currentSong.difficulty.toUpperCase()}] -';
		hud.centerMark.screenCenter(X);

		playField.camera = hud.camera = hudCamera;

		for (lane in playField.noteFields) {
			lane.changeStrumSpeed(Chart.current.data.initialSpeed);
			lane.onNoteHit.add(hitBehavior);
			lane.onNoteMiss.add(missBehavior);
		}

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

		if (FlxG.keys.justPressed.SEVEN)
			openCharter();
		if (FlxG.keys.justPressed.ESCAPE)
			endPlay();
	}

	public override function destroy():Void {
		current = null;
		super.destroy();
	}

	public function hitBehavior(note:Note):Void {
		if (note.wasHit)
			return;

		final isEnemy:Bool = note.parent == playField.enemyField;
		final character:Character = isEnemy ? enemy : player;

		// TODO: a better system -Crow
		character.playAnim(character.singingSteps[note.data.direction], true);
		// character.holdTimer = 0.0;

		if (!note.parent.cpuControl) {
			PlayState.current.playStats.combo++;
			// note.parent.doNoteSplash(note);
			playStats.updateRank();
			hud.updateScore();
		}

		note.parent.invalidateNote(note);
		// note.wasHit = true;
	}

	public function missBehavior(dir:Int, note:Note = null):Void {
		if (note != null)
			note.parent.invalidateNote(note);

		playStats.misses++;
		playStats.updateRank();
		hud.updateScore();
	}

	public override function onBeat(beat:Int):Void {
		// processEvent(PlaySound("metronome.wav", 1.0));
		var chars:Array<Character> = [player];
		if (enemy != null)
			chars.push(enemy);
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
