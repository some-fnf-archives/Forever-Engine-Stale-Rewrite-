package funkin.states.menus;

import flixel.text.FlxText;
import flixel.group.FlxGroup.FlxTypedGroup;
import forever.ForeverSprite;
import forever.data.ForeverOption;
import forever.ui.ForeverText;
import funkin.components.ui.Alphabet;
import funkin.states.base.BaseMenuState;
import haxe.ds.StringMap;

class OptionsMenu extends BaseMenuState {
	public var bg:ForeverSprite;
	public var optionsGroup:FlxTypedGroup<Alphabet>;

	public var topBarTxt:ForeverText;

	public var optionsListed:StringMap<Array<ForeverOption>> = [
		"main" => [
			new ForeverOption("Gameplay", CATEGORY),
			new ForeverOption("Accessibility", CATEGORY),
			new ForeverOption("Visuals", CATEGORY),
			new ForeverOption("Exit", CATEGORY),
		],
		"accessibility" => [
			new ForeverOption("Auto Pause", "Check this if you want the game not to pause when unfocusing the window.", "autoPause", CHECKMARK),
			new ForeverOption("Anti-aliasing", "Defines if the antialiasing filter affects all graphics.", "globalAntialias", CHECKMARK),
			new ForeverOption("Filter", "Applies a Screen Filter to your game, to view the game as a colorblind person would..", "screenFilter", CHECKMARK),
		],
		"gameplay" => [
			new ForeverOption("Downscroll", "Check this if you want your notes to come from top to bottom.", "downScroll", CHECKMARK),
			new ForeverOption("Centered Notefield", "Check this to center your notes to the screen, and hide the Enemy's notes.", "centerNotefield", CHECKMARK),
			new ForeverOption("Ghost Tapping", "Check this if you want to be able to mash keys while there's no notes to hit.", "ghostTapping", CHECKMARK),
		],
		"visuals" => [
			new ForeverOption("Clip Style", "Where should the sustain clip to?", "sustainLayer", CHOICE(["stepmania", "fnf"])),
			new ForeverOption("Note Skin", "Style of your scrolling notes.", CHOICE(["default"])),
			new ForeverOption("UI Skin", "Style of the healthbar, score popups, etc.", "uiStyle", CHOICE(["default"])),
		],
	];

	var curCateg:String = "main";
	var categoriesAccessed:Array<String> = [];

	override function create():Void {
		super.create();

		add(bg = new ForeverSprite(0, 0, "menus/backgrounds/menuDesat", {color: 0xFFEA71FD}));
		bg.scale.set(1.15, 1.15);
		bg.updateHitbox();

		add(optionsGroup = new FlxTypedGroup<Alphabet>());

		var topBar:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, 50, 0xFF000000);
		topBar.alpha = 0.6;
		add(topBar);

		add(topBarTxt = new ForeverText(topBar.x, topBar.height - 40, topBar.width, "- [SELECT A CATEGORY] -", 32));
		topBarTxt.alignment = CENTER;

		reloadOptions();

		onAccept = function() {
			if (optionsListed.get(curCateg)[curSel].name.toLowerCase() == "exit") {
				FlxG.sound.play(AssetHelper.getAsset('music/sfx/cancelMenu', SOUND));
				exitMenu();
				return;
			}

			FlxG.sound.play(AssetHelper.getAsset('music/sfx/confirmMenu', SOUND));

			switch (optionsListed.get(curCateg)[curSel].type) {
				case CATEGORY:
					reloadCategory(optionsListed.get(curCateg)[curSel].name);
				default:
					optionsListed.get(curCateg)[curSel].changeValue();
			}
		}

		onBack = function() {
			FlxG.sound.play(AssetHelper.getAsset('music/sfx/cancelMenu', SOUND));

			if (categoriesAccessed.length == 0) {
				exitMenu();
			}
			else {
				var lastAccessed:String = categoriesAccessed.pop();
				if (categoriesAccessed.length == 0) {
					reloadCategory("main");
					categoriesAccessed.clearArray();
				}
				else
					reloadCategory(categoriesAccessed.last());
			}
		}
	}

	override function updateSelection(newSel:Int = 0):Void {
		super.updateSelection(newSel);

		if (newSel != 0)
			FlxG.sound.play(AssetHelper.getAsset('music/sfx/scrollMenu', SOUND));

		var bs:Int = 0;
		for (i in optionsGroup.members) {
			i.targetY = bs - curSel;
			i.alpha = i.targetY == 0 ? 1.0 : 0.6;
			bs++;
		}
	}

	function reloadOptions():Void {
		while (optionsGroup.members.length != 0) {
			var i:Alphabet = optionsGroup.members.last();
			if (i != null)
				i.destroy();
			optionsGroup.remove(i, true);
		}

		var cataOptions:Array<ForeverOption> = optionsListed.get(curCateg);

		for (i in 0...cataOptions.length) {
			var optionLabel:Alphabet = new Alphabet(0, 0, cataOptions[i].name, BOLD, LEFT);
			optionLabel.screenCenter();
			optionLabel.y += (90 * (i - Math.floor(cataOptions.length / 2.0)));
			optionLabel.isMenuItem = curCateg.toLowerCase() != "main"; // HARD CODED LOL

			optionLabel.alpha = 0.6;
			optionLabel.targetY = i;
			optionsGroup.add(optionLabel);
		}

		maxSelections = cataOptions.indexOf(cataOptions.last());
		curSel = 0;

		updateSelection();
	}

	function reloadCategory(name:String):Void {
		name = name.toLowerCase();

		if (optionsListed.exists(name)) {
			curCateg = name;

			final defaultTopText = "- [SELECT A CATEGORY] -";

			topBarTxt.text = curCateg != "main" ? '- [${curCateg.toUpperCase()}] -' : defaultTopText;
			if (!categoriesAccessed.contains(name))
				categoriesAccessed.push(name);

			reloadOptions();
		}
		else
			trace('[OptionsMenu]: category of name "${name}" does not exist.');
	}

	function exitMenu():Void {
		/**
			if (fromGameplay)
				FlxG.switchState(new funkin.states.PlayState());
			else
		**/
		FlxG.switchState(new MainMenu());
	}
}
