package funkin.states.menus;

import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import forever.display.ForeverSprite;
import forever.ui.text.ForeverText;
import funkin.states.base.BaseMenuState;

using flixel.effects.FlxFlicker;

#if MODS
import funkin.subStates.ModsMenu;
#end

typedef MainMenuOption = {
	var name:String;
	var callback:Void->Void;
}

class MainMenu extends BaseMenuState {
	public var bg:ForeverSprite;
	public var magenta:ForeverSprite;
	public var buttons:FlxTypedGroup<FlxSprite>;

	public var camLead:FlxObject;

	var options:Array<MainMenuOption> = [
		{name: "story", callback: function():Void FlxG.switchState(new FreeplayMenu())},
		{name: "freeplay", callback: function():Void FlxG.switchState(new FreeplayMenu())},
		{name: "options", callback: function():Void FlxG.switchState(new OptionsMenu())}
	];

	public override function create():Void {
		super.create();

		DiscordRPC.updatePresence("In the Menus", "MAIN MENU");
		Tools.checkMenuMusic(null, false, 102.0);

		camLead = new FlxObject(0, 0, 1, 1);
		camLead.moves = false;
		add(camLead);

		add(bg = new ForeverSprite(0, 0, "menus/menuBG"));
		add(magenta = new ForeverSprite(0, 0, "menus/menuDesat"));
		magenta.visible = false;
		magenta.color = 0xFFFD719B;

		for (i in [bg, magenta]) {
			i.screenCenter();
			i.scale.set(1.15, 1.15);
			i.scrollFactor.set(0.0, 0.18);
			i.updateHitbox();
		}

		add(buttons = new FlxTypedGroup<FlxSprite>());

		var bttnSpacing:Int = 160;
		var bttnScale:Float = 1.0;

		for (i in 0...options.length) {
			final bttn:FlxSprite = new FlxSprite(0, 120 + (bttnSpacing * i));
			bttn.frames = AssetHelper.getAsset('menus/main/${options[i].name.toLowerCase()}', ATLAS);
			bttn.scale.set(bttnScale, bttnScale);
			bttn.ID = i;

			bttn.animation.addByPrefix("idle", "idle", 24);
			bttn.animation.addByPrefix("selected", "selected", 24);
			bttn.animation.play(i == curSel ? "selected" : "idle");

			bttn.screenCenter(X);
			bttn.scrollFactor.set();
			bttn.updateHitbox();

			buttons.add(bttn);
		}

		FlxG.camera.follow(camLead, null, 0.16);

		var versionLabel:ForeverText = new ForeverText(5, FlxG.height - #if MODS 35 #else 30 #end, 0, 'Forever Engine v${Main.version}', 16);
		#if MODS
		var modKb1:String = BaseControls.getKeyFromAction("switch mods").toString();
		var modKb2:String = BaseControls.getKeyFromAction("switch mods", 1).toString();
		versionLabel.text += '\nPress ${modKb1} or ${modKb2} to Switch Mods';
		#end
		versionLabel.scrollFactor.set();
		add(versionLabel);

		maxSelections = options.length - 1;

		onAccept = function():Void {
			canChangeSelection = false;
			canBackOut = false;
			canAccept = false;

			magenta.flicker(1.1, 0.15);
			FlxG.sound.play(AssetHelper.getAsset('audio/sfx/confirmMenu', SOUND));

			for (button in buttons.members) {
				if (button == null)
					continue;

				if (button.ID != curSel) {
					FlxTween.tween(button, {alpha: 0}, 0.4, {
						ease: FlxEase.quadOut,
						onComplete: function(twn:FlxTween) {
							button.kill();
						}
					});
				}
				else {
					button.flicker(1.0, 0.06, false, function(flk:FlxFlicker) {
						if (options[curSel].callback != null)
							options[curSel].callback();
					});
				}
			}
		}

		onBack = function():Void FlxG.switchState(new TitleScreen());

		updateSelection();
	}

	public override function update(elapsed:Float):Void {
		super.update(elapsed);

		buttons.forEach(function(button:FlxSprite) button.screenCenter(X));

		#if MODS
		if (canChangeSelection && Controls.current.justPressed("switch mods")) {
			FlxG.state.persistentUpdate = false;
			openSubState(new ModsMenu());
		}
		#end
	}

	public override function updateSelection(newSel:Int = 0):Void {
		super.updateSelection(newSel);

		if (newSel != 0)
			FlxG.sound.play(AssetHelper.getAsset('audio/sfx/scrollMenu', SOUND));

		for (i in 0...buttons.members.length) {
			final button:FlxSprite = buttons.members[i];
			button.animation.play(i == curSel ? "selected" : "idle", true);
			button.updateHitbox();

			camLead.setPosition(button.getGraphicMidpoint().x, button.getGraphicMidpoint().y);
		}
	}
}
