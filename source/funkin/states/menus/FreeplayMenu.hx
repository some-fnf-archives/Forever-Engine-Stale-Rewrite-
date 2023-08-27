package funkin.states.menus;

import flixel.FlxG;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxColor;
import forever.ui.ForeverText;

class FreeplayMenu extends FlxState {
	public var songs:Array<FreeplaySong> = [];

	public var songGroup:FlxTypedGroup<ForeverText>;

	var folderIndicator:ForeverText;

	public override function create():Void {
		var localSongData:Array<String> = Utils.listFromFile(AssetHelper.getAsset("data/freeplaySonglist", TEXT));

		for (i in localSongData) {
			var song:Array<String> = i.split(" || ");
			var name:String = song[0];
			var folder:String = song[1];
			var icon:String = song[2];
			var color:Null<FlxColor> = FlxColor.WHITE;

			songs.push(new FreeplaySong(name, folder, icon, color));
		}

		songGroup = new FlxTypedGroup();
		add(songGroup);

		for (i in 0...songs.length) {
			var songTxt:ForeverText = new ForeverText(0, 10 + (20 * i), FlxG.width, songs[i].name, 18);
			songTxt.alignment = CENTER;
			songTxt.alpha = 0.6;
			songTxt.ID = i;
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

		for (i in songGroup.members)
			i.alpha = i.ID == curSelection ? 1.0 : 0.6;

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
