package funkin.states.menus;

import flixel.group.FlxGroup.FlxTypedGroup;
import forever.display.ForeverSprite;
import forever.display.ForeverText;
import forever.tools.ForeverOption;
import funkin.states.PlayState.PlaySong;
import funkin.states.base.BaseMenuState;
import funkin.states.menus.*;
import funkin.states.options.*;
import funkin.ui.Alphabet;
import haxe.ds.StringMap;

class OptionsMenu extends BaseMenuState {
	public var bg:ForeverSprite;

	public var optionsGroup:FlxTypedGroup<Alphabet>;
	public var iconGroup:FlxTypedGroup<Dynamic>;

	public var topBarTxt:ForeverText;

	public var optionsListed:StringMap<Array<ForeverOption>> = [
		"main" => [
			new ForeverOption("Preferences", CATEGORY),
			#if FE_DEV new ForeverOption("Controls", NONE),
			new ForeverOption("Offset", NONE), #end
			new ForeverOption("Exit", NONE),
		],
		"preferences" => [
			new ForeverOption("General", CATEGORY),
			new ForeverOption("Gameplay", CATEGORY),
			new ForeverOption("Visuals", CATEGORY),
		],
		"general" => [
			new ForeverOption("Auto Pause", "autoPause"),
			new ForeverOption("Anti-aliasing", "globalAntialias"),
			new ForeverOption("VRAM Sprites", "vramSprites"),
			new ForeverOption("Framerate Cap", "framerateCap", NUMBER(30, 240, 1)),
			new ForeverOption("Filter", "screenFilter", CHOICE(["none", "deuteranopia", "protanopia", "tritanopia"])),
		],
		"gameplay" => [
			new ForeverOption("Downscroll", "downScroll"),
			new ForeverOption("Centered Receptors", "centerStrums"),
			new ForeverOption("Ghost Tapping", "ghostTapping"),
			new ForeverOption("Reset Button", "resetButton"),
		],
		"visuals" => [
			// new ForeverOption("Note Skin >", CATEGORY),
			new ForeverOption("Stage Dim", "stageDim", NUMBER(0, 100, 1)),
			new ForeverOption("Fixed Judgements", "fixedJudgements"),
			new ForeverOption("Clip Style", "sustainLayer", CHOICE(["stepmania", "fnf"])),
		],
	];

	var curCateg:String = "main";
	var categoriesAccessed:Array<String> = [];
	var infoText:ForeverText;

	var gameplayMusic:PlaySong = null;

	public function new(gameplayMusic:PlaySong = null):Void {
		super("OptionsMenu");
		this.gameplayMusic = gameplayMusic;
	}

	override function create():Void {
		super.create();

		#if MODS
		if (gameplayMusic == null)
			optionsListed.get("main").insert(#if FE_DEV 2 #else 1 #end, new ForeverOption("Mods", NONE));
		#end

		#if DISCORD
		DiscordRPC.updatePresenceDetails("In the Menus", "OPTIONS");
		#end
		Tools.checkMenuMusic(null, false, 102.0);

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

		topBar.antialiasing = false;

		add(topBarTxt = new ForeverText(topBar.x, topBar.height - 40, topBar.width, "- [SELECT A CATEGORY] -", 32));
		topBarTxt.alignment = CENTER;

		reloadOptions();

		onAccept = function():Void {
			var option:ForeverOption = optionsListed.get(curCateg)[curSel];
			switch (option.name.toLowerCase()) {
				#if FE_DEV
				case "controls":
					persistentUpdate = false;
					openSubState(new ControlsMenu());
				case "offset":
					persistentUpdate = false;
					openSubState(new OffsetMenu());
				#end
				#if MODS
				case "mods":
					persistentUpdate = false;
					openSubState(new ModsMenu());
				#end
				case "exit":
					FlxG.sound.play(AssetHelper.getAsset('audio/sfx/cancelMenu', SOUND));
					canChangeSelection = false;
					canBackOut = false;
					canAccept = false;
					exitMenu();
				default:
					switch (option.type) {
						case NONE: // nothing.
						case CATEGORY:
							reloadCategory(option.name);
						default:
							FlxG.sound.play(AssetHelper.getAsset('audio/sfx/confirmMenu', SOUND));
							option.changeValue();

							function changeSelector():Void cast(iconGroup.members[curSel], Alphabet).text = '${option.value}';

							switch (option.type) {
								case CHECKMARK:
									// safe casting, HashLink won't let me write unsafe code :( -Crow
									cast(iconGroup.members[curSel], ForeverSprite).playAnim('${option.value}');
								case CHOICE(options): changeSelector();
								case NUMBER(min, max, decimals, clamp): changeSelector();
								default:
							}
					}
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

	var holdTime:Float = 0.0;

	override function update(elapsed:Float):Void {
		super.update(elapsed);

		if (Std.isOfType(iconGroup.members[curSel], Alphabet)) {
			function optionChange(changeFactor:Int = 0):Void {
				final option:ForeverOption = optionsListed.get(curCateg)[curSel];
				option.changeValue(changeFactor);
	
				cast(iconGroup.members[curSel], Alphabet).text = '${option.value}';
				FlxG.sound.play(AssetHelper.getAsset('audio/sfx/scrollMenu', SOUND));
			}

			if (Controls.UI_LEFT_P || Controls.UI_RIGHT_P) {
				optionChange(Controls.UI_LEFT_P ? -1 : 1);
				holdTime = 0.0;
			}

			if (Controls.UI_LEFT || Controls.UI_RIGHT) {
				// literally stolen from psych engine thx shadowmario
				var checkLastHold:Int = Math.floor((holdTime - 0.5) * 20);
				holdTime += elapsed;
				var checkNewHold:Int = Math.floor((holdTime - 0.5) * 20);

				if(holdTime > 0.5 && checkNewHold - checkLastHold > 0)
					optionChange((checkNewHold - checkLastHold) * (Controls.UI_LEFT ? -1 : 1));
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
		while (optionsGroup.members.length != 0) optionsGroup.members.pop().destroy();
		while (iconGroup.members.length != 0) cast(iconGroup.members.pop(), FlxSprite).destroy();

		final cataOptions:Array<ForeverOption> = optionsListed.get(curCateg);

		for (i in 0...cataOptions.length) {
			final optionLabel:Alphabet = new Alphabet(0, 0, cataOptions[i].name, BOLD, LEFT);
			optionLabel.screenCenter();

			optionLabel.y += (90 * (i - Math.floor(cataOptions.length * 0.5)));
			optionLabel.isMenuItem = curCateg.toLowerCase() != "main"; // HARD CODED LOL
			optionLabel.forceLerp.x = 100;
			optionLabel.menuSpacing.y = 80;

			optionLabel.alpha = 0.6;
			optionLabel.targetY = i;
			optionsGroup.add(optionLabel);

			function generateSelector():Void {
				final selectorName:ChildAlphabet = new ChildAlphabet(Std.string(cataOptions[i].value), BOLD, RIGHT);
				selectorName.parent = optionLabel;
				iconGroup.add(selectorName);
			}

			switch (cataOptions[i].type) { // create an attachment
				case CHECKMARK:
					final newCheckmark:ChildSprite = Tools.generateCheckmark();
					newCheckmark.parent = optionLabel;
					newCheckmark.align = LEFT;

					newCheckmark.playAnim('${cataOptions[i].value} finished');
					iconGroup.add(newCheckmark);

				case CHOICE(options): generateSelector();
				case NUMBER(min, max, decimals, clamp): generateSelector();
				default: iconGroup.add(new FlxSprite()); // prevent issues
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
		if (gameplayMusic != null) 
			FlxG.switchState(new funkin.states.PlayState(gameplayMusic));
		else FlxG.switchState(new MainMenu());
	}
}
