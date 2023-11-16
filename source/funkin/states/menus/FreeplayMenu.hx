package funkin.states.menus;

import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxColor;
import forever.display.ForeverSprite;
import forever.display.ForeverText;
import funkin.components.ChartLoader;
import funkin.components.Difficulty;
import funkin.components.Highscore;
import funkin.states.base.BaseMenuState;
import funkin.ui.Alphabet;
import funkin.ui.HealthIcon;

class FreeplayMenu extends BaseMenuState {
	static var prevSel:Int = 0;
	static var lastDiff:String = null;

	public var bg:ForeverSprite;
	public var songs:Array<FreeplaySong> = [];

	public var songGroup:FlxTypedGroup<Alphabet>;
	public var iconGroup:FlxTypedGroup<HealthIcon>;

	// -- SCORE UI STUFF -- //
	public var backPB:FlxSprite;
	public var scoreTxt:ForeverText;
	public var difficultyTxt:ForeverText;

	var lerpScore:Int = 0;
	var intendedScore:Int = 0;

	@:dox(hide) var _loaded = true;

	override function create():Void {
		super.create();

		#if DISCORD
		DiscordRPC.updatePresenceDetails("In the Menus", "FREEPLAY");
		#end
		Tools.checkMenuMusic(null, false, 102.0);

		canChangeMods = true;
		canChangeAlternative = true;

		var localSongData:Array<String> = Tools.listFromFile(AssetHelper.getAsset("data/freeplaySonglist", TEXT));

		for (i in localSongData) {
			final song:Array<String> = i.trim().split("|");
			final song:FreeplaySong = {
				name: song[0].trim(),
				folder: song[1].trim(),
				character: song[2].trim(),
				color: FlxColor.fromString(song[3]?.trim()) ?? 0xFF606060, // penis
				difficulties: song[4] != null ? Tools.removeSpaces(song[4]).split(",") : Difficulty.getDefault()
			}
			if (songs.contains(song)) continue;
			songs.push(song);
		};

		add(bg = new ForeverSprite(0, 0, "menus/menuDesat", {color: 0xFF606060}));
		bg.scale.set(1.15, 1.15);
		bg.updateHitbox();

		if (songs.length > 0) {
			add(songGroup = new FlxTypedGroup<Alphabet>());
			add(iconGroup = new FlxTypedGroup<HealthIcon>());

			// -- UI -- //
			final position = FlxG.width * 0.7;

			add(backPB = new FlxSprite(position - 6, 0).makeSolid(1, 60, 0xFF000000));
			add(scoreTxt = new ForeverText(position, 5, 0, "", 32));

			scoreTxt.alignment = RIGHT;
			backPB.alpha = 0.6;
			backPB.antialiasing = false;

			add(difficultyTxt = new ForeverText(0, scoreTxt.y + 30, 0, "-", 20));
			difficultyTxt.centerToObject(backPB, X);

			for (t in [scoreTxt, difficultyTxt])
				t.borderSize = 0;

			// -- -- -- //

			for (i in 0...songs.length) {
				final songTxt:Alphabet = new Alphabet(0, 10 + (60 * i), songs[i].name);
				songTxt.isMenuItem = true;
				songTxt.alpha = 0.6;
				songTxt.targetY = i;
				songGroup.add(songTxt);

				var icon:HealthIcon = new HealthIcon(songs[i].character);
				icon.parent = songTxt;
				iconGroup.add(icon);
			}

			onAccept = function():Void {
				// ensuring.
				canChangeSelection = false;
				canChangeAlternative = false;
				canBackOut = false;
				canAccept = false;

				var song:funkin.states.PlayState.PlaySong = {
					display: songs[curSel].name,
					folder: songs[curSel].folder,
					difficulty: Difficulty.list[curSelAlt]
				};

				Chart.current = ChartLoader.load(song.folder, song.difficulty);
				FlxG.switchState(new funkin.states.PlayState(song));
			};

			maxSelections = songs.length - 1;
			if (prevSel < 0 || prevSel > maxSelections)
				prevSel = 0;
			curSel = prevSel;
		}
		else {
			final errorText:Alphabet = new Alphabet(0, 0, "No songs were found,\nplease check your song list file.", BOLD, CENTER, 0.8);
			errorText.screenCenter();
			add(errorText);

			canChangeSelection = false;
			canChangeAlternative = false;
			canAccept = false;
			_loaded = false;
		}

		onBack = function():Void {
			canChangeSelection = false;
			canChangeAlternative = false;
			canBackOut = false;
			canAccept = false;
			FlxG.switchState(new MainMenu());
		}

		updateSelection();
	}

	override function update(elapsed:Float):Void {
		super.update(elapsed);

		if (!_loaded)
			return;

		lerpScore = Math.floor(Tools.fpsLerp(lerpScore, intendedScore, 0.1));
		scoreTxt.text = 'PERSONAL BEST:${lerpScore}';

		// just copied from base game lol
		scoreTxt.x = FlxG.width - scoreTxt.width - 6;
		backPB.scale.x = FlxG.width - scoreTxt.x + 6;
		backPB.x = FlxG.width - backPB.scale.x * 0.5;

		difficultyTxt.x = Math.floor(backPB.x + backPB.width * 0.5);
		difficultyTxt.x -= (difficultyTxt.width * 0.5);
	}

	override function updateSelection(newSel:Int = 0):Void {
		super.updateSelection(newSel);

		if (newSel != 0)
			FlxG.sound.play(AssetHelper.getAsset('audio/sfx/scrollMenu', SOUND));

		for (i in 0...songGroup.members.length) {
			final sn:Alphabet = songGroup.members[i];
			final si:HealthIcon = iconGroup.members[i];

			sn.targetY = i - curSel;
			sn.alpha = sn.targetY == 0 ? 1.0 : 0.6;
			si.alpha = sn.alpha;
			si.animation.curAnim.curFrame = 0;
		}

		if (bg.color != songs[curSel].color) {
			bg.stopTweens();
			bg.colorTween(songs[curSel].color, 0.8, {ease: flixel.tweens.FlxEase.sineIn});
		}

		prevSel = curSel;
		Difficulty.list = null; // ensure its using the default ones.
		if (songs[curSel].difficulties != null && songs[curSel].difficulties.length > 0)
			Difficulty.list = songs[curSel].difficulties;

		if (lastDiff != null && Difficulty.list.contains(lastDiff))
			curSelAlt = Difficulty.list.indexOf(lastDiff);

		maxSelectionsAlt = Difficulty.list.length - 1;
		updateSelectionAlt();
	}

	override function updateSelectionAlt(newSelAlt:Int = 0):Void {
		if (Difficulty.list.length == 1) {
			difficultyTxt.text = Difficulty.list[0].toUpperCase();
			curSelAlt = 0;
			return;
		}

		super.updateSelectionAlt(newSelAlt);

		if (newSelAlt != 0)
			FlxG.sound.play(AssetHelper.getAsset('audio/sfx/scrollMenu', SOUND));

		difficultyTxt.text = '« ${Difficulty.list[curSelAlt].toUpperCase()} »';
		intendedScore = Highscore.getSongScore(songs[curSel].folder).score;
		lastDiff = Difficulty.list[curSelAlt];
	}
}

@:structInit class FreeplaySong {
	public var name:String = "Test";
	public var folder:String = "test";
	public var character:String = "bf";
	public var color:Null<FlxColor> = 0xFF606060;
	public var difficulties:Array<String> = null;
}
