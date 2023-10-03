package funkin.states.menus;

import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxColor;
import funkin.states.base.FNFState;
import funkin.components.ui.Alphabet;
import forever.ForeverSprite;
import forever.ui.ForeverText;

class FreeplayMenu extends FNFState {
	public var bg:ForeverSprite;
	public var songs:Array<FreeplaySong> = [];

	public var songGroup:FlxTypedGroup<Alphabet>;

	public override function create():Void {
		var localSongData:Array<String> = Utils.listFromFile(AssetHelper.getAsset("data/freeplaySonglist", TEXT));

		DiscordRPC.updatePresence("In the Menus", "FREEPLAY");

		for (i in localSongData) {
			var song:Array<String> = Utils.removeSpaces(i).split("|");
			var name:String = song[0];
			var folder:String = song[1];
			var icon:String = song[2];
			var color:Null<FlxColor> = 0xFF606060;

			songs.push(new FreeplaySong(name, folder, icon, color));
		};

		add(bg = new ForeverSprite(0, 0, "bg", {color: 0xFF606060}));
		add(songGroup = new FlxTypedGroup());

		for (i in 0...songs.length) {
			var songTxt:Alphabet = new Alphabet(0, 10 + (60 * i), songs[i].name);
			songTxt.isMenuItem = true;
			songTxt.alpha = 0.6;
			songTxt.targetY = i;
			songGroup.add(songTxt);
		}

		updateSelection();
	}

	public override function update(elapsed:Float):Void {
		super.update(elapsed);

		if (Controls.UP_P || Controls.DOWN_P)
			updateSelection(Controls.UP_P ? -1 : 1);
		if (Controls.ACCEPT)
			FlxG.switchState(new funkin.states.PlayState());
	}

	public var curSelection:Int = 0;

	public function updateSelection(newSelection:Int = 0):Void {
		curSelection = flixel.math.FlxMath.wrap(curSelection + newSelection, 0, songs.length - 1);

		var bs:Int = 0;
		for (i in songGroup.members) {
			i.targetY = bs - curSelection;
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
