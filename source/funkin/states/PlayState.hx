package funkin.states;

import flixel.FlxCamera;
import flixel.FlxObject;
import flixel.math.FlxMath;
import flixel.sound.FlxSound;
import flixel.util.FlxTimer;
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

enum abstract MusicState(Int) to Int {
	var STOPPED = 0;
	var PLAYING = 1;
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
	public var songState:Int = STOPPED;

	public var bg:ForeverSprite;
	public var playField:PlayField;
	public var playStats:ScoreManager;
	public var hud:HUD;

	public var camLead:FlxObject;

	public var gameCamera:FlxCamera;
	public var hudCamera:FlxCamera;
	public var altCamera:FlxCamera;

	public var stage:StageBase;

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

		// -- PREPARE AUDIO -- //
		inst = new FlxSound().loadEmbedded(AssetHelper.getSound('songs/${currentSong.folder}/audio/Inst.ogg'));
		vocals = new FlxSound().loadEmbedded(AssetHelper.getSound('songs/${currentSong.folder}/audio/Voices.ogg'));
		FlxG.sound.list.add(vocals);
		FlxG.sound.music = inst;

		Conductor.time = -(60.0 / Conductor.bpm) * 16.0;
		FlxG.mouse.visible = false;

		// -- PREPARE CAMERAS -- //
		gameCamera = FlxG.camera;
		hudCamera = new FlxCamera();
		altCamera = new FlxCamera();

		hudCamera.bgColor = altCamera.bgColor = 0x00000000;
		FlxG.cameras.add(hudCamera, false);
		FlxG.cameras.add(altCamera, false);

		// -- PREPARE BACKGROUNDS AND USER INTERFACE -- //
		ChartLoader.load(currentSong.folder, currentSong.difficulty);
		Conductor.bpm = Chart.current.data.initialBPM;
		playStats = new ScoreManager();

		add(stage = new DadStage());
		add(playField = new PlayField());
		add(hud = new HUD());

		// -- SETUP CAMERA AFTER STAGE IS DONE -- //
		add(camLead = new FlxObject(0, 0, 1, 1));
		gameCamera.follow(camLead, LOCKON);

		// update song display so it shows song name and difficulty (like intended)
		hud.centerMark.text = '- ${currentSong.display} [${currentSong.difficulty.toUpperCase()}] -';
		hud.centerMark.screenCenter(X);

		playField.camera = hud.camera = hudCamera;

		for (lane in playField.noteFields) {
			lane.changeStrumSpeed(Chart.current.data.initialSpeed);
			lane.onNoteHit.add(hitBehavior);
			lane.onNoteMiss.add(missBehavior);
		}

		for (i in 0...playField.playerField.members.length) {
			var strum = playField.playerField.members[i];
			strum.doNoteSplash(null, true);
		}

		// -- PREPARE CHARACTERS -- //
		add(player = new Character(stage.playerPosition.x, stage.playerPosition.y, "bf", true));
		add(enemy = new Character(stage.enemyPosition.x, stage.enemyPosition.y, "bf", false));
		add(crowd = new Character(stage.crowdPosition.x, stage.crowdPosition.y, "bf", false));

		DiscordRPC.updatePresence('Playing: ${currentSong.display}', '${hud.scoreBar.text}');

		countdownRoutine();
		processEvent(FocusCamera(1, false));
	}

	public override function update(elapsed:Float):Void {
		super.update(elapsed);

		FlxG.camera.followLerp = FlxMath.bound(elapsed * 2.4 * stage.cameraSpeed * (FlxG.updateFramerate / 60.0), 0.0, 1.0);

		if (Conductor.time >= 0 && !FlxG.sound.music.playing) {
			songState = PLAYING;
			FlxG.sound.music.play();
			vocals.play();
		}

		while (eventIndex < Chart.current.events.length) {
			var curEvent = Chart.current.events[eventIndex];
			if ((curEvent.step - Conductor.time) > 0.0)
				break;

			processEvent(curEvent.event);
			eventIndex += 1;
		}

		if (FlxG.keys.justPressed.SEVEN)
			openChartEditor();
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

		final character:Character = (note.parent == playField.enemyField) ? enemy : player;

		// TODO: a better system -Crow
		character.playAnim(character.singingSteps[note.data.direction], true);
		character.holdTmr = 0.0;

		if (!note.parent.cpuControl) {
			var millisecondTiming:Float = Math.abs((note.data.time - Conductor.time) * 1000.0);
			var judgement:Judgement = ScoreManager.judgeNote(millisecondTiming);
			playStats.totalMs += millisecondTiming;

			playStats.score += judgement.getParameters()[1];
			playStats.health += 0.035;
			if (playStats.combo < 0)
				playStats.combo = 0;
			playStats.combo += 1;

			playStats.totalNotesHit += 1;
			playStats.accuracyWindow += Math.max(0, judgement.getParameters()[2]);
			playStats.increaseJudgeHits(judgement.getParameters()[0]);

			if (judgement.getParameters()[3] || note.splash)
				note.parent.members[note.direction].doNoteSplash(note);

			playStats.updateRank();
			hud.updateScore();
		}

		note.parent.invalidateNote(note);
		// note.wasHit = true;
	}

	public function missBehavior(dir:Int, note:Note = null):Void {
		if (note != null)
			note.parent.invalidateNote(note);

		playStats.misses += 1;
		playStats.updateRank();
		hud.updateScore();
	}

	public override function onBeat(beat:Int):Void {
		// let 'em do their thing!
		doDancersDance(beat);
	}

	function doDancersDance(beat:Int):Void {
		var chars:Array<Character> = [player, enemy, crowd];

		for (character in chars) {
			if (character == null)
				continue;

			// 0 = IDLE | 1 = SING | 2 = MISS
			if (character.animationState != 1 && beat % character.danceInterval == 0)
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

	var eventIndex:Int = 0;

	public function processEvent(which:ForeverEvents):Void {
		switch (which) {
			case FocusCamera(who, noEasing):
				var character:Character = getCharacterFromID(who);
				var xPoint:Float = character.getMidpoint().x + character.cameraDisplace.x;
				var yPoint:Float = character.getMidpoint().y + character.cameraDisplace.y;

				if (camLead.x != xPoint)
					camLead.setPosition(xPoint, yPoint);

			case ChangeCharacter(who, toCharacter):
				getCharacterFromID(who).loadCharacter(toCharacter);
			case PlaySound(soundName, volume):
				FlxG.sound.play(AssetHelper.getSound('sounds/${soundName}'), volume);
			default:
				// do nothing
		}
	}

	// -- HELPER FUNCTIONS -- //

	function openChartEditor():Void {
		FlxG.sound.music.pause();
		DiscordRPC.updatePresence('Charting: ${currentSong.display}', '${hud.scoreBar.text}');

		var charter:ChartEditor = new ChartEditor();
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

	var countdownPosition:Int = 0;
	var countdownTween:FlxTween;

	public function countdownRoutine():Void {
		if (songState != PLAYING)
			Conductor.time = -(60.0 / Conductor.bpm) * 4.0;

		var sprCount:ForeverSprite = null;
		final sounds:Array<String> = ['intro3', 'intro2', 'intro1', 'introGo'];

		new FlxTimer().start(60.0 / Conductor.bpm, function(tmr:FlxTimer) {
			doDancersDance(tmr.loopsLeft);

			sprCount = getCountdownSprite(countdownPosition);
			if (sprCount != null) {
				sprCount.screenCenter();
				sprCount.camera = hudCamera;
				add(sprCount);

				if (countdownTween != null)
					countdownTween.cancel();

				countdownTween = FlxTween.tween(sprCount, {alpha: 0}, (60.0 / Conductor.bpm), {
					ease: FlxEase.sineOut,
					onComplete: function(t) {
						sprCount.kill();
					}
				});
			}

			FlxG.sound.play(AssetHelper.getAsset('sounds/countdown/normal/${sounds[countdownPosition]}', SOUND), 0.8);
			countdownPosition += 1;
		}, 4);
	}

	function getCharacterFromID(id:Int):Character {
		return switch (id) {
			default: enemy;
			case 1: player;
			case 2: crowd;
		}
	}

	function getCountdownSprite(tick:Int):ForeverSprite {
		final sprites:Array<String> = ["prepare", "ready", "set", "go"];

		var thingExists:Bool = openfl.utils.Assets.exists(AssetHelper.getPath('images/ui/normal/${sprites[tick]}', IMAGE));
		if (sprites[tick] != null && thingExists)
			return new ForeverSprite(0, 0, 'ui/normal/${sprites[tick]}', {"scale.x": 0.9, "scale.y": 0.9});
		return null;
	}
}
