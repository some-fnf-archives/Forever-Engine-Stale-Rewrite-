package funkin.states;

import flixel.FlxCamera;
import flixel.FlxObject;
import flixel.FlxSubState;
import flixel.math.FlxMath;
import flixel.sound.FlxSound;
import flixel.util.FlxTimer;
import forever.display.ForeverSprite;
import funkin.components.ChartLoader;
import funkin.components.Timings;
import funkin.components.ui.ComboSprite;
import funkin.components.ui.HUD;
import funkin.objects.*;
import funkin.objects.notes.Note;
import funkin.objects.StageBase;
import funkin.objects.stages.*;
import funkin.states.base.FNFState;
import funkin.states.editors.*;
import funkin.states.menus.*;
import funkin.subStates.PauseMenu;

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

	public var comboGroup:ComboGroup;

	/**
	 * Constructs the Gameplay State
	 * @param songInfo 			Assigns a new song to the PlayState.
	**/
	public function new(songInfo:PlaySong):Void {
		super();
		this.currentSong = songInfo;
	}

	public override function create():Void {
		super.create();

		current = this;

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		scriptPack = initAllScriptsAt([
			AssetHelper.getPath("data/scripts/global"),
			AssetHelper.getPath('songs/${currentSong.folder}/scripts'),
		]);
		callFunPack("create", []);
		setPackVar('game', this);

		// -- PREPARE AUDIO -- //
		inst = new FlxSound().loadEmbedded(AssetHelper.getAsset('songs/${currentSong.folder}/audio/Inst', SOUND));
		vocals = new FlxSound().loadEmbedded(AssetHelper.getAsset('songs/${currentSong.folder}/audio/Voices', SOUND));
		FlxG.sound.list.add(vocals);
		inst.onComplete = endPlay.bind();
		FlxG.sound.music = inst;

		FlxG.sound.music.looped = false;
		vocals.looped = false;

		Timings.reset();

		Conductor.time = -(60.0 / Conductor.bpm) * 16.0;
		FlxG.mouse.visible = false;

		// -- PREPARE CAMERAS -- //
		gameCamera = FlxG.camera;
		hudCamera = new FlxCamera();
		altCamera = new FlxCamera();

		hudCamera.bgColor = altCamera.bgColor = 0x00000000;
		FlxG.cameras.add(hudCamera, false);
		FlxG.cameras.add(altCamera, false);

		// -- PREPARE BACKGROUND -- //
		add(stage = new StageBase(Chart.current.data.stageBG));

		// -- SETUP CAMERA -- //
		add(camLead = new FlxObject(0, 0, 1, 1));
		gameCamera.follow(camLead, LOCKON);

		// -- PREPARE CHARACTERS -- //
		add(player = new Character(stage.playerPosition.x, stage.playerPosition.y, Chart.current.data.playerChar, true));
		add(enemy = new Character(stage.enemyPosition.x, stage.enemyPosition.y, Chart.current.data.enemyChar, false));
		add(crowd = new Character(stage.crowdPosition.x, stage.crowdPosition.y, Chart.current.data.crowdChar, false));

		// -- PREPARE USER INTERFACE -- //
		add(comboGroup = new ComboGroup());
		add(playField = new PlayField());
		add(hud = new HUD());
		hud.alpha = 0;

		// update song display so it shows song name and difficulty (like intended)
		hud.centerMark.text = '- ${currentSong.display} [${currentSong.difficulty.toUpperCase()}] -';
		hud.centerMark.screenCenter(X);

		playField.camera = hud.camera = hudCamera;

		// -- PREPARE CHART AND NOTEFIELDS -- //
		Conductor.bpm = Chart.current.data.initialBPM;

		for (lane in playField.noteFields) {
			lane.changeStrumSpeed(Chart.current.data.initialSpeed);
			lane.onNoteHit.add(hitBehavior);
			lane.onNoteMiss.add(missBehavior);
		}

		for (i in 0...playField.playerField.members.length) {
			var strum = playField.playerField.members[i];
			strum.doNoteSplash(null, true);
		}

		DiscordRPC.updatePresence('Playing: ${currentSong.display}', '');

		// cache combo and stuff
		var comboCache:ComboSprite = new ComboSprite();
		comboCache.loadSprite("sick-perfect");
		comboCache.alpha = 0.0000001;
		comboGroup.add(comboCache);
		new FlxTimer().start(0.3, function(tmr:FlxTimer):Void comboCache.kill());

		callFunPack("createPost", []);

		countdownRoutine();
		if (Chart.current != null && Chart.current.events[0] != null)
			processEvent(Chart.current.events[0].event);
	}

	public override function update(elapsed:Float):Void {
		super.update(elapsed);

		callFunPack("update", [elapsed]);

		FlxG.camera.followLerp = FlxMath.bound(elapsed * 2.4 * stage.cameraSpeed * (FlxG.updateFramerate / 60.0), 0.0, 1.0);

		if (Conductor.time >= 0 && !FlxG.sound.music.playing) {
			songState = PLAYING;
			FlxG.sound.music.play();
			vocals.play();
		}

		while (eventIndex < Chart.current.events.length) {
			var curEvent = Chart.current.events[eventIndex];
			if ((curEvent.time - Conductor.time) > 0.0)
				break;

			processEvent(curEvent.event);
			eventIndex += 1;
		}

		if (FlxG.keys.justPressed.SEVEN)
			openChartEditor();
		if (Controls.PAUSE)
			openPauseMenu();

		callFunPack("postUpdate", [elapsed]);
	}

	public override function destroy():Void {
		callFunPack("destroy", []);
		var i:Int = 0;
		while (i < scriptPack.length - 1) {
			scriptPack[i].destroy();
			i++;
		}
		scriptPack = [];
		current = null;
		super.destroy();
	}

	public function hitBehavior(note:Note):Void {
		if (note.wasHit)
			return;

		callFunPack("hitBehavior", [note]);

		final isEnemy:Bool = (note.parent == playField.enemyField);
		var character:Character = isEnemy ? enemy : player;
		// TODO: a better system -Crow
		if (character.animationContext != 3) {
			character.playAnim(character.singingSteps[note.data.direction], true);
			character.holdTmr = 0.0;
		}

		if (!note.parent.cpuControl) {
			var millisecondTiming:Float = Math.abs((note.data.time - Conductor.time) * 1000.0);
			var judgement:Judgement = Timings.judgeNote(millisecondTiming);
			Timings.totalMs += millisecondTiming;

			Timings.score += judgement.getParameters()[1];
			Timings.health += 0.035;
			if (Timings.combo < 0)
				Timings.combo = 0;
			Timings.combo += 1;

			Timings.totalNotesHit += 1;
			Timings.accuracyWindow += Math.max(0, judgement.getParameters()[2]);
			Timings.increaseJudgeHits(judgement.getParameters()[0]);

			if (judgement.getParameters()[3] || note.splash)
				note.parent.members[note.direction].doNoteSplash(note);

			final chosenType:ComboPopType = FlxMath.roundDecimal(Timings.accuracy, 2) >= 100 ? PERFECT : NORMAL;
			displayJudgement(judgement.getParameters()[0], chosenType);
			displayCombo(Timings.combo, chosenType);

			Timings.updateRank();
			hud.updateScore();
		}

		note.parent.invalidateNote(note);
		note.wasHit = true;

		callFunPack("postHitBehavior", []);
	}

	public function missBehavior(dir:Int, note:Note = null):Void {
		callFunPack("missBehavior", [dir, note]);
		if (note != null)
			note.parent.invalidateNote(note);

		if (Timings.combo > 0)
			Timings.combo = 0;
		else
			Timings.combo--;
		Timings.misses += 1;

		displayJudgement("miss", MISS);
		displayCombo(Timings.combo, MISS);

		Timings.updateRank();
		hud.updateScore();

		callFunPack("postMissBehavior", [dir]);
	}

	public function displayJudgement(name:String, type:ComboPopType = NORMAL):Void {
		if (type == PERFECT && name == "sick")
			name = "sick-perfect";

		final placement:Float = FlxG.width * 0.35;

		var judgement:ComboSprite = comboGroup.recycleLoop(ComboSprite).resetProps();
		judgement.loadSprite('${name}0');
		judgement.screenCenter(Y);
		judgement.x = placement - 40;
		judgement.y += 60;

		judgement.scale.set(0.7, 0.7);
		judgement.updateHitbox();

		judgement.acceleration.y = 550 * Conductor.rate * Conductor.rate;
		judgement.velocity.y = -FlxG.random.int(140, 175) * Conductor.rate;
		judgement.velocity.x = -FlxG.random.int(0, 10) * Conductor.rate;

		final crochet:Float = (60.0 / Conductor.bpm);

		judgement.tween({alpha: 0}, 0.4 / Conductor.rate, {
			onComplete: function(twn:FlxTween):Void {
				judgement.kill();
				comboGroup.remove(judgement, true);
			},
			startDelay: crochet + (crochet * 4.0) * 0.05
		});
	}

	public function displayCombo(combo:Int, type:ComboPopType = NORMAL):Void {
		final prefix:String = type == PERFECT ? "gold" : "normal";
		final placement:Float = FlxG.width * 0.35;
		final comboArr:Array<String> = Std.string(combo).split("");
		final xOff:Float = comboArr.length - 3;

		for (i in 0...comboArr.length) {
			var comboName:String = '${prefix}${comboArr[i]}0';
			if (comboArr[i] == "-" && type == MISS)
				comboName = '${prefix}minus';

			var comboNumber:ComboSprite = comboGroup.recycleLoop(ComboSprite).resetProps();
			comboNumber.loadSprite(comboName);
			comboNumber.screenCenter(Y);

			if (type == MISS)
				comboNumber.color = FlxColor.fromRGB(204, 66, 66);

			comboNumber.x = placement + (43 * (i - xOff)) + 25;
			comboNumber.y += 150;

			comboNumber.scale.set(0.5, 0.5);
			comboNumber.updateHitbox();

			comboNumber.acceleration.y = FlxG.random.int(200, 300) * Conductor.rate * Conductor.rate;
			comboNumber.velocity.y = -FlxG.random.int(140, 160) * Conductor.rate;
			comboNumber.velocity.x = FlxG.random.int(-5, 5) * Conductor.rate;

			final crochet:Float = (60.0 / Conductor.bpm);

			comboNumber.tween({alpha: 0}, 0.5 / Conductor.rate, {
				onComplete: function(twn:FlxTween):Void {
					comboNumber.kill();
					comboGroup.remove(comboNumber, true);
				},
				startDelay: (crochet * 4.0) * 0.02
			});
		}
	}

	public override function onBeat(beat:Int):Void {
		callFunPack("onBeat", [beat]);
		hud.onBeat(beat);
		// let 'em do their thing!
		doDancersDance(beat);
	}

	public override function onStep(step:Int):Void {
		callFunPack("onStep", [step]);
	}

	public override function onBar(bar:Int):Void {
		for (contextNames in ["onBar", "onSection", "onMeasure"])
			callFunPack(contextNames, [bar]);
	}

	function doDancersDance(beat:Int):Void {
		var chars:Array<Character> = [player, enemy, crowd];
		for (character in chars) {
			if (character == null)
				continue;
			// 0 = IDLE | 1 = SING | 2 = MISS
			if (character.animationContext == 0 && beat % character.danceInterval == 0)
				character.dance();
		}
	}

	public override function openSubState(SubState:FlxSubState):Void {
		if (FlxG.sound.music != null && FlxG.sound.music.playing)
			FlxG.sound.music.pause();
		if (vocals != null && vocals.playing)
			vocals.pause();
		super.openSubState(SubState);
	}

	public override function closeSubState():Void {
		playField.paused = false;
		if (FlxG.sound.music != null && FlxG.sound.music.playing)
			FlxG.sound.music.resume();
		if (vocals != null && vocals.playing)
			vocals.resume();
		DiscordRPC.updatePresence('${currentSong.display}', '${hud.scoreBar.text}');
		pauseTweens(false);
		super.closeSubState();
	}

	public function preloadEvent(which:ForeverEvents):Void {
		switch (which) {
			case ChangeCharacter(who, toCharacter):
			/*
				var newChar:Character = new Character(0, 0);
				newChar.loadCharacter(toCharacter);
				newChar.alpha = 0.000001;
				characterGroup.add(newChar);
			 */
			case Scripted(name, script, args):
			// init hscript here.
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
				FlxG.sound.play(AssetHelper.getAsset('audio/sfx/${soundName}'), volume);
			case Scripted(name, script, args):
			// init hscript here.
			default:
				// do nothing
		}
	}

	// -- HELPER FUNCTIONS -- //

	function openChartEditor():Void {
		DiscordRPC.updatePresence('Charting: ${currentSong.display}');
		final charter:ChartEditor = new ChartEditor();
		charter.camera = altCamera;
		playField.paused = true;
		openSubState(charter);
	}

	function openPauseMenu():Void {
		pauseTweens(true);
		DiscordRPC.updatePresence('${currentSong.display} [PAUSED]', '${hud.scoreBar.text}');
		final pause:PauseMenu = new PauseMenu();
		pause.camera = altCamera;
		playField.paused = true;
		openSubState(pause);
	}

	function pauseTweens(resume:Bool):Void {
		FlxTween.globalManager.forEach(function(t) t.active = !resume);
		FlxTimer.globalManager.forEach(function(t) t.active = !resume);
	}

	function endPlay():Void {
		FlxG.sound.music.stop();
		vocals.stop();

		var cb:Void->Void = switch playMode {
			case STORY: function():Void FlxG.switchState(new MainMenu());
			case CHARTER: function():Void {
					Conductor.init();
					openChartEditor();
				}
			case _: function():Void FlxG.switchState(new FreeplayMenu());
		}
		cb();
	}

	var countdownPosition:Int = 0;
	var countdownTween:FlxTween;

	public function countdownRoutine():Void {
		if (songState != PLAYING) {
			Conductor.time = -(60.0 / Conductor.bpm) * 4.0;
			FlxTween.tween(hud, {alpha: 1.0}, (60.0 / Conductor.bpm) * 2.0, {ease: FlxEase.sineIn});
		}

		var sprCount:ForeverSprite = null;
		final sounds:Array<String> = ['intro3', 'intro2', 'intro1', 'introGo'];

		var countdownTimer:FlxTimer = new FlxTimer().start(60.0 / Conductor.bpm, function(tmr:FlxTimer) {
			if (countdownPosition > sounds.length - 1) {
				sprCount.destroy();
				return;
			}

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

			FlxG.sound.play(AssetHelper.getAsset('audio/sfx/countdown/normal/${sounds[countdownPosition]}', SOUND), 0.8);
			countdownPosition += 1;
		}, 4);
	}

	inline function getCharacterFromID(id:Int):Character {
		return switch (id) {
			default: enemy;
			case 1: player;
			case 2: crowd;
		}
	}

	function getCountdownSprite(tick:Int):ForeverSprite {
		final sprites:Array<String> = ["prepare", "ready", "set", "go"];
		if (sprites[tick] != null && Tools.fileExists(AssetHelper.getPath('images/ui/normal/${sprites[tick]}', IMAGE)))
			return new ForeverSprite(0, 0, 'images/ui/normal/${sprites[tick]}', {"scale.x": 0.9, "scale.y": 0.9});
		return null;
	}
}
