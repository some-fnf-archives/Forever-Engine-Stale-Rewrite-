package funkin.states.subStates;

import flixel.FlxSubState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import forever.data.Mods;
import funkin.components.ui.Alphabet;

class ModsMenu extends FlxSubState {
	static var curSel:Int = 0;

	public var modsGroup:FlxTypedGroup<Alphabet>;

	public function new():Void {
		super();

		Mods.refreshMods();

		// placeholder
		var bg1:FlxSprite;
		var bg2:FlxSprite;

		add(bg1 = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK));
		add(bg2 = new FlxSprite().loadGraphic(AssetHelper.getAsset("images/menus/bgBlack", IMAGE)));

		bg2.blend = DIFFERENCE;
		bg1.alpha = 0.7;
		bg2.alpha = 0.07;

		for (i in [bg1, bg2]) {
			i.scale.set(1.15, 1.15);
			i.updateHitbox();
		}

		add(modsGroup = new FlxTypedGroup<Alphabet>());

		if (Mods.mods.length > 0) {
			var listThing:Array<String> = Mods.mods.map(function(mod) return mod.title);
			listThing.insert(0, "Friday Night Funkin'");
			var modsAdded:Array<String> = []; // stupid fix for duplicated mods

			for (i in 0...listThing.length) {
				if (modsAdded.contains(listThing[i]))
					continue;

				var modLetter:Alphabet = new Alphabet(0, 0, listThing[i], BOLD, LEFT);
				modLetter.isMenuItem = true;
				modLetter.targetY = i;
				modsGroup.add(modLetter);

				modsAdded.push(listThing[i]);
			}

			if (curSel < 0 || curSel > Mods.mods.length - 1)
				curSel = 0;

			updateSelection();
		}
		else {
			final txt:String = "No mods were found,\nplease check your mods folder.";
			final errorText:Alphabet = new Alphabet(0, 0, txt, BOLD, CENTER, 0.8);
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
			Mods.loadMod(modsGroup.members[curSel].text);
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
