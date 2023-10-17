package funkin.states.subStates;

import flixel.FlxSubState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import forever.data.ModManager;
import funkin.components.ui.Alphabet;

class ModsMenu extends FlxSubState {
	static var curSel:Int = 0;

	public var modsGroup:FlxTypedGroup<Alphabet>;

	public function new():Void {
		super();

		ModManager.refreshMods();

		// placeholder
		var bg1:FlxSprite;
		var bg2:FlxSprite;

		add(bg1 = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK));
		add(bg2 = new FlxSprite().loadGraphic(AssetHelper.getAsset("images/menus/bgBlack", IMAGE)));

		bg2.blend = DIFFERENCE;
		bg1.alpha = 0.7;
		bg2.alpha = 0.07;

		add(modsGroup = new FlxTypedGroup<Alphabet>());

		if (ModManager.mods.length > 0) {
			var listThing:Array<String> = ModManager.mods.map(function(mod) return mod.id);
			listThing.insert(0, "Friday Night Funkin'");

			for (i in 0...listThing.length) {
				var modLetter:Alphabet = new Alphabet(0, 0, listThing[i], BOLD, LEFT);
				modLetter.isMenuItem = true;
				modLetter.targetY = i;
				modsGroup.add(modLetter);
			}

			if (curSel < 0 || curSel > ModManager.mods.length - 1)
				curSel = 0;

            updateSelection();
		}
		else {
            var errorText:Alphabet = new Alphabet(0, 0, "No mods were found, please check your mods folder.", BOLD, CENTER);
			errorText.screenCenter();
			add(errorText);
        }
	}

	public override function update(elapsed:Float):Void {
		super.update(elapsed);

		var up:Bool = Controls.UP_P;
		var down:Bool = Controls.DOWN_P;

		if (up || down)
			updateSelection(up ? -1 : 1);

		if (Controls.ACCEPT) {
			trace('loading "${modsGroup.members[curSel].text}" mod...');
			ModManager.loadMod(modsGroup.members[curSel].text);
			FlxG.resetState();
		}
		if (FlxG.keys.justPressed.ESCAPE) {
			FlxG.state.persistentUpdate = true;
			close();
		}
	}

	public function updateSelection(newSel:Int = 0):Void {
		if (modsGroup.members.length < 1)
			return;

		curSel = FlxMath.wrap(curSel + newSel, 0, modsGroup.members.length - 1);
		if (newSel != 0)
			FlxG.sound.play(AssetHelper.getAsset('music/sfx/scrollMenu', SOUND));

		for (i in 0...modsGroup.members.length) {
			var sn:Alphabet = modsGroup.members[i];
			sn.targetY = i - curSel;
			sn.alpha = sn.targetY == 0 ? 1.0 : 0.6;
		}
	}
}
