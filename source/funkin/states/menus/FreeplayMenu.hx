package funkin.states.menus;

import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxColor;
import funkin.components.FNFState;
import funkin.components.ui.Alphabet;
import forever.ForeverSprite;
import forever.ui.ForeverText;

class FreeplayMenu extends FNFState {
	public var bg:ForeverSprite;
	public var songs:Array<FreeplaySong> = [];

	public var songGroup:FlxTypedGroup<Alphabet>;

	var folderIndicator:ForeverText;

	public override function create():Void {
		var localSongData:Array<String> = Utils.listFromFile(AssetHelper.getAsset("data/freeplaySonglist", TEXT));

		DiscordRPC.updatePresence("In the Menus", "FREEPLAY");

		for (i in localSongData) {
			var song:Array<String> = i.split(" || ");
			var name:String = song[0];
			var folder:String = song[1];
			var icon:String = song[2];
			var color:Null<FlxColor> = FlxColor.WHITE;

			songs.push(new FreeplaySong(name, folder, icon, color));
		};

		add(bg = new ForeverSprite(0, 0, "bg", {color: FlxColor.WHITE}));
		add(songGroup = new FlxTypedGroup());

		for (i in 0...songs.length) {
			var songTxt:Alphabet = new Alphabet(0, 10 + (60 * i), songs[i].name);
			songTxt.alignment = CENTER;
			songTxt.isMenuItem = true;
			songTxt.menuSpacing.y = 100;
			songTxt.alpha = 0.6;
			songTxt.targetY = i;
			songGroup.add(songTxt);
		}

		folderIndicator = new ForeverText(0, 0, FlxG.width, "", 20);
		folderIndicator.alignment = CENTER;
		folderIndicator.screenCenter(XY);
		folderIndicator.y = (FlxG.height - folderIndicator.height) - 5;
		add(folderIndicator);

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

		folderIndicator.text = 'Folder: ${songs[curSelection].folder}';
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
