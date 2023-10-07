package funkin.states.menus;

import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxColor;
import forever.ForeverSprite;
import funkin.components.ui.Alphabet;
import funkin.states.base.BaseMenuState;

class FreeplayMenu extends BaseMenuState {
	public var bg:ForeverSprite;
	public var songs:Array<FreeplaySong> = [];

	public var songGroup:FlxTypedGroup<Alphabet>;

	public override function create():Void {
		Utils.checkMenuMusic("foreverMenu", false, 102.0);
		DiscordRPC.updatePresence("In the Menus", "FREEPLAY");

		var localSongData:Array<String> = Utils.listFromFile(AssetHelper.getAsset("data/freeplaySonglist", TEXT));
	
		for (i in localSongData) {
			var song:Array<String> = Utils.removeSpaces(i).split("|");
			var name:String = song[0];
			var folder:String = song[1];
			var icon:String = song[2];
			var color:Null<FlxColor> = 0xFF606060;

			songs.push(new FreeplaySong(name, folder, icon, color));
		};

		add(bg = new ForeverSprite(0, 0, "bg", {color: 0xFF606060}));
		bg.scale.set(1.15, 1.15);
		bg.updateHitbox();

		add(songGroup = new FlxTypedGroup());

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
				difficulty: "hard"
			};

			if (FlxG.sound.music != null)
				FlxG.sound.music.stop();

			FlxG.switchState(new funkin.states.PlayState(song));
		};

		onBack = function()
			FlxG.switchState(new MainMenu());

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
	}
}

class FreeplaySong {
	public var name:String = "Test";
	public var folder:String = "test";
	public var character:String = "bf";
	public var color:Null<FlxColor> = FlxColor.WHITE;

	public function new(name:String, folder:String, character:String = "bf", color:Null<FlxColor> = FlxColor.WHITE):Void {
		this.name = name;
		this.folder = folder;
		this.character = character;
		this.color = color;
	}
}
