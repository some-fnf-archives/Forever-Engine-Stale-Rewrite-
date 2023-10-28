package funkin.states.menus;

import flixel.FlxBasic;
import flixel.FlxObject;
import flixel.group.FlxGroup.FlxTypedGroup;
import forever.tools.ForeverOption;
import forever.display.ForeverSprite;
import forever.display.ForeverText;
import funkin.ui.Alphabet;
import funkin.states.base.BaseMenuState;
import funkin.subStates.NoteConfigurator;
import haxe.ds.StringMap;

class OptionsMenu extends BaseMenuState {
	public var bg:ForeverSprite;

	public var optionsGroup:FlxTypedGroup<Alphabet>;
	public var iconGroup:FlxTypedGroup<Dynamic>;

	public var topBarTxt:ForeverText;

	public var optionsListed:StringMap<Array<ForeverOption>> = [
		"main" => [
			new ForeverOption("General", CATEGORY),
			new ForeverOption("Gameplay", CATEGORY),
			new ForeverOption("Visuals", CATEGORY),
			new ForeverOption("Exit", CATEGORY),
		],
		"general" => [
			new ForeverOption("Auto Pause", "autoPause", CHECKMARK),
			new ForeverOption("Anti-aliasing", "globalAntialias", CHECKMARK),
			new ForeverOption("VRAM Sprites", "vramSprites", CHECKMARK),
			new ForeverOption("Framerate Cap", "framerateCap", NUMBER(30, 240, 1)),
			new ForeverOption("Filter", "screenFilter", CHOICE(["none", "deuteranopia", "protanopia", "tritanopia"])),
		],
		"gameplay" => [
			new ForeverOption("Downscroll", "downScroll", CHECKMARK),
			new ForeverOption("Centered Notefield", "centerNotefield", CHECKMARK),
			new ForeverOption("Ghost Tapping", "ghostTapping", CHECKMARK),
		],
		"visuals" => [
			new ForeverOption("Note Skin >", CATEGORY),
			new ForeverOption("Clip Style", "sustainLayer", CHOICE(["stepmania", "fnf"])),
			// new ForeverOption("Note Skin", "noteSkin", CHOICE(["default"])),
			new ForeverOption("UI Skin", "uiStyle", CHOICE(["default"])),
		],
	];

	var curCateg:String = "main";
	var categoriesAccessed:Array<String> = [];
	var infoText:ForeverText;

	override function create():Void {
		super.create();

		add(bg = new ForeverSprite(0, 0, "menus/menuDesat", {color: 0xFFEA71FD}));
		bg.scale.set(1.15, 1.15);
		bg.updateHitbox();

		add(optionsGroup = new FlxTypedGroup<Alphabet>());
		add(iconGroup = new FlxTypedGroup<Dynamic>());

		add(infoText = new ForeverText(0, 0, 0, "...", 18));
		infoText.textField.background = true;
		infoText.textField.backgroundColor = 0xFF000000;
		infoText.screenCenter(XY);
		infoText.alignment = CENTER;

		var topBar:FlxSprite = new FlxSprite().makeSolid(FlxG.width, 50, 0xFF000000);
		topBar.alpha = 0.6;
		add(topBar);

		add(topBarTxt = new ForeverText(topBar.x, topBar.height - 40, topBar.width, "- [SELECT A CATEGORY] -", 32));
		topBarTxt.alignment = CENTER;

		reloadOptions();

		onAccept = function():Void {
			var option:ForeverOption = optionsListed.get(curCateg)[curSel];

			switch (option.type) {
				case CATEGORY:
					switch (option.name.toLowerCase()) {
						case "note skin >":
							persistentUpdate = false;
							openSubState(new NoteConfigurator());
						case "exit":
							FlxG.sound.play(AssetHelper.getAsset('audio/sfx/cancelMenu', SOUND));
							canChangeSelection = false;
							canBackOut = false;
							canAccept = false;
							exitMenu();
						default: reloadCategory(option.name);
					}
				default:
					FlxG.sound.play(AssetHelper.getAsset('audio/sfx/confirmMenu', SOUND));

					option.changeValue();
					var isSelector:Bool = false;

					switch (option.type) {
						case CHECKMARK:
							// safe casting, HashLink won't let me write unsafe code :( -Crow
							cast(iconGroup.members[curSel], ForeverSprite).playAnim('${option.value}');
						case CHOICE(options):
							isSelector = true;
						case NUMBER(min, max, decimals, clamp):
							isSelector = true;
						default:
					}

					if (isSelector)
						cast(iconGroup.members[curSel], Alphabet).text = '${option.value}';
			}
		}

		onBack = function():Void {
			FlxG.sound.play(AssetHelper.getAsset('audio/sfx/cancelMenu', SOUND));

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

	override function update(elapsed:Float):Void {
		super.update(elapsed);

		if (Std.isOfType(iconGroup.members[curSel], Alphabet)) {
			final left:Bool = Controls.LEFT_P;
			final right:Bool = Controls.RIGHT_P;
			final option:ForeverOption = optionsListed.get(curCateg)[curSel];

			if (left || right) {
				option.changeValue(left ? -1 : 1);
				cast(iconGroup.members[curSel], Alphabet).text = '${option.value}';
				FlxG.sound.play(AssetHelper.getAsset('audio/sfx/scrollMenu', SOUND));
			}
		}
	}

	override function updateSelection(newSel:Int = 0):Void {
		super.updateSelection(newSel);

		if (newSel != 0)
			FlxG.sound.play(AssetHelper.getAsset('audio/sfx/scrollMenu', SOUND));

		for (i in 0...optionsGroup.members.length) {
			final let:Alphabet = optionsGroup.members[i];
			let.targetY = i - curSel;
			let.alpha = let.targetY == 0 ? 1.0 : 0.6;
			if (iconGroup.members[i] != null)
				cast(iconGroup.members[i], FlxSprite).alpha = let.alpha;
		}

		infoText.text = optionsListed.get(curCateg)[curSel].description;
		infoText.x = Math.floor(FlxG.width - infoText.width) * 0.5;
		infoText.y = Math.floor(FlxG.height - infoText.height) - 5;
	}

	function reloadOptions():Void {
		while (optionsGroup.members.length != 0) {
			var i:Alphabet = optionsGroup.members.last();
			if (i != null)
				i.destroy();
			optionsGroup.remove(i, true);
		}

		while (iconGroup.members.length != 0) {
			var i:FlxSprite = cast(iconGroup.members.last(), FlxSprite);
			if (i != null)
				i.destroy();
			iconGroup.remove(i, true);
		}

		var cataOptions:Array<ForeverOption> = optionsListed.get(curCateg);

		for (i in 0...cataOptions.length) {
			final optionLabel:Alphabet = new Alphabet(0, 0, cataOptions[i].name, BOLD, LEFT);
			optionLabel.screenCenter();

			optionLabel.y += (90 * (i - Math.floor(cataOptions.length * 0.5)));
			optionLabel.isMenuItem = curCateg.toLowerCase() != "main"; // HARD CODED LOL
			optionLabel.menuSpacing.y = 80;

			optionLabel.alpha = 0.6;
			optionLabel.targetY = i;
			optionsGroup.add(optionLabel);

			var isSelector:Bool = false;

			switch (cataOptions[i].type) { // create an attachment
				case CHECKMARK:
					var newCheckmark:ChildSprite = Tools.generateCheckmark();
					newCheckmark.parent = optionLabel;
					newCheckmark.align = LEFT;

					newCheckmark.playAnim('${cataOptions[i].value} finished');
					iconGroup.add(newCheckmark);

				case CHOICE(options):
					isSelector = true;
				case NUMBER(min, max, decimals, clamp):
					isSelector = true;
				default:
					iconGroup.add(new FlxSprite()); // prevent issues
			}

			if (isSelector) {
				final selectorName:ChildAlphabet = new ChildAlphabet(Std.string(cataOptions[i].value), BOLD, RIGHT);
				selectorName.parent = optionLabel;
				iconGroup.add(selectorName);
			}
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
			trace('[OptionsMenu.reloadCategory()]: category of name "${name}" does not exist.');
	}

	function exitMenu():Void {
		Settings.flush();

		/**
			if (fromGameplay)
				FlxG.switchState(new funkin.states.PlayState());
			else
		**/
		FlxG.switchState(new MainMenu());
	}
}
