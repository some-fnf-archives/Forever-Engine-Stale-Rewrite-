package funkin.states.menus;

import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxColor;
import forever.ForeverSprite;
import forever.ui.ForeverText;
import funkin.components.ui.Alphabet;
import funkin.components.DifficultyHelper;
import funkin.states.base.BaseMenuState;

class FreeplayMenu extends BaseMenuState {
	public var bg:ForeverSprite;
	public var songs:Array<FreeplaySong> = [];

	public var songGroup:FlxTypedGroup<Alphabet>;

	public var pbBackground:FlxSprite;
	public var difficultyTxt:ForeverText;

	public override function create():Void {
		Utils.checkMenuMusic("foreverMenu", false, 102.0);
		DiscordRPC.updatePresence("In the Menus", "FREEPLAY");

		canChangeAlternative = true;

		var localSongData:Array<String> = Utils.listFromFile(AssetHelper.getAsset("data/freeplaySonglist", TEXT));

		for (i in localSongData) {
			var song:Array<String> = Utils.removeSpaces(i).split("|");
			var name:String = song[0];
			var folder:String = song[1];
			var icon:String = song[2];
			var color:Null<FlxColor> = 0xFF606060;
			var difficulties:Array<String> = null;
			if (song[3] != null)
				color = FlxColor.fromString(song[3]);
			if (song[4] != null)
				difficulties = Utils.removeSpaces(song[4]).split(",");

			songs.push(new FreeplaySong(name, folder, icon, color, difficulties));
		};

		add(bg = new ForeverSprite(0, 0, "bg", {color: 0xFF606060}));
		bg.scale.set(1.15, 1.15);
		bg.updateHitbox();

		add(songGroup = new FlxTypedGroup<Alphabet>());
		add(pbBackground = new FlxSprite().makeGraphic(FlxG.width, 60, 0xFF000000));
		pbBackground.alpha = 0.6;

		add(difficultyTxt = new ForeverText(0, pbBackground.height - 25, Std.int(pbBackground.width), "-", 20));
		difficultyTxt.alignment = CENTER;

		for (i in 0...songs.length) {
			var songTxt:Alphabet = new Alphabet(0, 10 + (60 * i), songs[i].name);
			songTxt.isMenuItem = true;
			songTxt.alpha = 0.6;
			songTxt.targetY = i;
			songGroup.add(songTxt);
		}

		maxSelections = songs.length - 1;

		onAccept = function() {
			// ensuring.
			canChangeSelection = canChangeAlternative = false;
			canAccept = canBackOut = false;

			var song:funkin.states.PlayState.PlaySong = {
				display: songs[curSel].name,
				folder: songs[curSel].folder,
				difficulty: DifficultyHelper.currentList[curSelAlt]
			};

			if (FlxG.sound.music != null)
				FlxG.sound.music.stop();

			FlxG.switchState(new funkin.states.PlayState(song));
		};

		onBack = function() FlxG.switchState(new MainMenu());

		updateSelection();
	}

	public override function updateSelection(newSel:Int = 0):Void {
		super.updateSelection(newSel);

		if (newSel != 0)
			FlxG.sound.play(AssetHelper.getAsset('music/sfx/scrollMenu', SOUND));

		var bs:Int = 0;
		for (i in songGroup.members) {
			i.targetY = bs - curSel;
			i.alpha = i.targetY == 0 ? 1.0 : 0.6;
			bs++;
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

		difficultyTxt.text = '< ${DifficultyHelper.toString(curSelAlt).toUpperCase()} >';
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
