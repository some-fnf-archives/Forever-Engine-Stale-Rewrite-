package funkin.states.menus;

import funkin.components.ui.HealthIcon;
import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import forever.ForeverSprite;
import forever.ui.ForeverText;
import funkin.components.DifficultyHelper;
import funkin.components.Highscore;
import funkin.components.ui.Alphabet;
import funkin.states.base.BaseMenuState;

class FreeplayMenu extends BaseMenuState {
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

	public override function create():Void {
		DiscordRPC.updatePresence("In the Menus", "FREEPLAY");
		Utils.checkMenuMusic("foreverMenu", false, 102.0);

		canChangeAlternative = true;

		var localSongData:Array<String> = Utils.listFromFile(AssetHelper.getAsset("data/freeplaySonglist", TEXT));

		for (i in localSongData) {
			final song:Array<String> = i.trim().split("|");

			// gotta do manual trimming here
			var name:String = song[0].trim();
			var folder:String = song[1].trim();
			var icon:String = song[2].trim();

			var color:Null<FlxColor> = 0xFF606060;

			var difficulties:Array<String> = null;
			if (song[3] != null)
				color = FlxColor.fromString(song[3].trim());
			if (song[4] != null)
				difficulties = Utils.removeSpaces(song[4]).split(",");

			songs.push(new FreeplaySong(name, folder, icon, color, difficulties));
		};

		add(bg = new ForeverSprite(0, 0, "menus/menuDesat", {color: 0xFF606060}));
		bg.scale.set(1.15, 1.15);
		bg.updateHitbox();

		if (songs.length > 0) {
			add(songGroup = new FlxTypedGroup<Alphabet>());
			add(iconGroup = new FlxTypedGroup<HealthIcon>());

			// -- UI -- //
			final position = FlxG.width * 0.7;

			add(backPB = new FlxSprite(position - 6, 0).makeGraphic(1, 60, 0xFF000000));
			add(scoreTxt = new ForeverText(position, 5, 0, "", 32));

			scoreTxt.alignment = RIGHT;
			backPB.alpha = 0.6;

			add(difficultyTxt = new ForeverText(0, scoreTxt.y + 30, 0, "-", 24));
			difficultyTxt.centerToObject(backPB, X);

			for (t in [scoreTxt, difficultyTxt])
				t.borderSize = 0;

			// -- -- -- //

			for (i in 0...songs.length) {
				var songTxt:Alphabet = new Alphabet(0, 10 + (60 * i), songs[i].name);
				songTxt.isMenuItem = true;
				songTxt.alpha = 0.6;
				songTxt.targetY = i;
				songGroup.add(songTxt);

				var icon:HealthIcon = new HealthIcon(songs[i].character);
				icon.parent = songTxt;
				iconGroup.add(icon);
			}

			maxSelections = songs.length - 1;

			onAccept = function() {
				// ensuring.
				canChangeSelection = false;
				canChangeAlternative = false;
				canBackOut = false;
				canAccept = false;

				var song:funkin.states.PlayState.PlaySong = {
					display: songs[curSel].name,
					folder: songs[curSel].folder,
					difficulty: DifficultyHelper.currentList[curSelAlt]
				};

				if (FlxG.sound.music != null)
					FlxG.sound.music.stop();

				FlxG.switchState(new funkin.states.PlayState(song));
			};
		}
		else {
			var errorText:Alphabet = new Alphabet(0, 0, "No songs were found, please check your song list file.", BOLD, CENTER);
			errorText.screenCenter();
			add(errorText);
		}

		onBack = function() {
			canChangeSelection = false;
			canChangeAlternative = false;
			canBackOut = false;
			canAccept = false;
			FlxG.switchState(new MainMenu());
		}

		updateSelection();
	}

	public override function update(elapsed:Float):Void {
		super.update(elapsed);

		for (si in iconGroup.members)
			if (si.animation.curAnim.curFrame != 0)
				si.animation.curAnim.curFrame = 0;

		lerpScore = Math.floor(Utils.fpsLerp(lerpScore, intendedScore, 0.1));
		scoreTxt.text = 'PERSONAL BEST:${lerpScore}';

		// just copied from base game lol
		scoreTxt.x = FlxG.width - scoreTxt.width - 6;
		backPB.scale.x = FlxG.width - scoreTxt.x + 6;
		backPB.x = FlxG.width - backPB.scale.x / 2;

		difficultyTxt.x = Math.floor(backPB.x + backPB.width / 2);
		difficultyTxt.x -= (difficultyTxt.width / 2);
	}

	public override function updateSelection(newSel:Int = 0):Void {
		super.updateSelection(newSel);

		if (newSel != 0)
			FlxG.sound.play(AssetHelper.getAsset('music/sfx/scrollMenu', SOUND));

		for (i in 0...songGroup.members.length) {
			var sn:Alphabet = songGroup.members[i];
			var si:HealthIcon = iconGroup.members[i];

			sn.targetY = i - curSel;
			sn.alpha = sn.targetY == 0 ? 1.0 : 0.6;
			si.alpha = sn.alpha;
		}

		if (bg.color != songs[curSel].color) {
			bg.stopTweens();
			bg.colorTween(songs[curSel].color, 0.8, {ease: flixel.tweens.FlxEase.sineIn});
		}

		if (songs[curSel].difficulties != null && songs[curSel].difficulties.length > 0)
			DifficultyHelper.changeList(songs[curSel].difficulties);
		else // handle error?
			DifficultyHelper.changeList(DifficultyHelper.defaults);

		maxSelectionsAlt = DifficultyHelper.currentList.length - 1;
		updateSelectionAlt();
	}

	public override function updateSelectionAlt(newSelAlt:Int = 0):Void {
		if (maxSelectionsAlt < 2)
			difficultyTxt.text = DifficultyHelper.currentList[0];

		super.updateSelectionAlt(newSelAlt);

		if (newSelAlt != 0)
			FlxG.sound.play(AssetHelper.getAsset('music/sfx/scrollMenu', SOUND));

		difficultyTxt.text = '« ${DifficultyHelper.toString(curSelAlt).toUpperCase()} »';

		intendedScore = Highscore.getSongScore(songs[curSel].folder).score;
	}
}

class FreeplaySong {
	public var name:String = "Test";
	public var folder:String = "test";
	public var character:String = "bf";
	public var color:Null<FlxColor> = 0xFF606060;
	public var difficulties:Array<String> = null;

	public function new(name:String, folder:String, character:String = "bf", color:Null<FlxColor> = 0xFF606060, ?difficulties:Array<String>):Void {
		this.name = name;
		this.folder = folder;
		this.character = character;
		this.difficulties = difficulties;
		this.color = color;
	}
}
