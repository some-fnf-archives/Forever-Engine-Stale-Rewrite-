package funkin.states.menus;

import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxSpriteGroup;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import forever.display.ForeverSprite;
import funkin.components.ui.Alphabet;
import funkin.states.base.FNFState;

class TitleScreen extends FNFState {
	public var bg:FlxSprite;
	public var logo:FlxSprite;
	public var gfDance:ForeverSprite;
	public var enterTxt:ForeverSprite;

	public var textGroup:TitleTextGroup;
	public var mainGroup:FlxSpriteGroup;
	public var randomBlurb:Array<String> = ["blahblah", "coolswag"];

	// -- BEHAVIOR FIELDS -- //
	public static var seenIntro:Bool = false;

	var transitioning:Bool = false;

	public override function create():Void {
		super.create();

		DiscordRPC.updatePresence("In the Menus", "TITLE SCREEN");
		randomBlurb = FlxG.random.getObject(getRandomText());

		FlxTransitionableState.skipNextTransIn = false;
		FlxTransitionableState.skipNextTransOut = false;

		add(bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000));
		add(textGroup = new TitleTextGroup());
		add(mainGroup = new FlxSpriteGroup());
		mainGroup.visible = false;

		logo = new FlxSprite(20, 50);
		logo.loadGraphic(AssetHelper.getAsset('images/menus/title/logo', IMAGE));
		logo.scale.set(0.9, 0.9);
		logo.updateHitbox();

		gfDance = new ForeverSprite(FlxG.width * 0.4, FlxG.height * 0.07);
		gfDance.frames = AssetHelper.getAsset('images/menus/title/gfDanceTitle', ATLAS_SPARROW);
		gfDance.addAtlasAnim('danceLeft', 'gfDance', 24, false, [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14]);
		gfDance.addAtlasAnim('danceRight', 'gfDance', 24, false, [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29]);
		mainGroup.add(gfDance);
		mainGroup.add(logo);

		enterTxt = new ForeverSprite(100, FlxG.height * 0.8);
		enterTxt.frames = AssetHelper.getAsset('images/menus/title/titleEnter', ATLAS_SPARROW);
		enterTxt.addAtlasAnim('idle', "Press Enter to Begin", 24);
		enterTxt.addAtlasAnim('press', "ENTER PRESSED", 24, true);
		enterTxt.playAnim('idle', true);
		enterTxt.updateHitbox();
		mainGroup.add(enterTxt);

		new flixel.util.FlxTimer().start(0.05, function(tmr) {
			Tools.checkMenuMusic("foreverMenu", true, 102.0);
		});

		if (seenIntro)
			skipIntro();
	}

	public override function update(elapsed:Float):Void {
		super.update(elapsed);

		if (seenIntro) {
			if (logo != null) {
				logo.scale.x = Tools.fpsLerp(logo.scale.x, 1.0, 0.05);
				logo.scale.y = Tools.fpsLerp(logo.scale.y, 1.0, 0.05);
			}

			if (Controls.ACCEPT && !transitioning) {
				FlxG.camera.flash(0xFFFFFFFF, 0.6);
				FlxG.sound.play(AssetHelper.getAsset("music/sfx/confirmMenu", SOUND));
				enterTxt.playAnim('press');
				transitioning = true;

				new flixel.util.FlxTimer().start(1.85, function(tmr) {
					FlxG.switchState(new MainMenu());
				});
			}
		}
		else {
			if (Controls.ACCEPT) {
				skipIntro();
				FlxG.sound.music.time = 9400.0;
			}
		}
	}

	var gfBopped:Bool = false;
	var logoTween:FlxTween;

	public override function onBeat(beat:Int):Void {
		if (logo != null) {
			if (logoTween != null)
				logoTween.cancel();

			logo.scale.set(1.05, 1.05);
			logo.updateHitbox();

			logoTween = FlxTween.tween(logo.scale, {x: 0.9, y: 0.9}, (60.0 / Conductor.bpm), {ease: FlxEase.expoOut});
		}

		if (gfDance != null) {
			var dir:String = gfBopped ? 'Left' : 'Right';
			gfDance.playAnim('dance${dir}');
			gfBopped = !gfBopped;
		}

		if (seenIntro)
			return;

		switch (beat) { // hardcoding for now lmfao
			case 1:
				textGroup.createText(["crowplexus", "ne_eo", "itsaizakku", "nxtvithor", "sayofthelor"]);
			case 3:
				textGroup.addText("PRESENT");
			case 4:
				textGroup.deleteText();
			case 5:
				textGroup.createText(["*Not* associated", "with"]);
			case 7:
				textGroup.addText("Newgrounds");
			case 8:
				textGroup.deleteText();
			case 9:
				textGroup.createText([randomBlurb[0]]);
			case 11:
				textGroup.addText(randomBlurb[1]);
			case 12:
				textGroup.deleteText();
			case 13:
				textGroup.addText("Funkin'", true);
			case 14:
				textGroup.addText('Forever');
			case 15:
				textGroup.addText('Engine');
			case 16:
				skipIntro();
		}
	}

	public function skipIntro():Void {
		FlxG.camera.flash(0xFFFFFFFF, 0.6);
		seenIntro = true;

		if (textGroup != null) {
			textGroup.deleteText();
			textGroup.destroy();
			remove(textGroup);
		}

		mainGroup.visible = true;
	}

	function getRandomText():Array<Array<String>> {
		var textFile:Array<String> = Tools.listFromFile(AssetHelper.getAsset("data/introText", TEXT));
		var textBoxes:Array<Array<String>> = [];

		for (i in textFile) // remind me to make this automatic per txt length later -Crow
			textBoxes.push(i.split("--"));

		return textBoxes;
	}
}

class TitleTextGroup extends FlxTypedSpriteGroup<Alphabet> {
	var hasTextDisplayed:Bool = false;

	public function createText(text:Array<String>, ?forceCreate:Bool = false):Void {
		if (hasTextDisplayed && !forceCreate) {
			var str:String = "";
			for (i in 0...text.length)
				str += text[i] + "\n";

			return addText(str);
		}

		for (i in 0...text.length) {
			final swagShit:Alphabet = new Alphabet(0, 0, text[i], BOLD, CENTER);
			swagShit.y += (i * 65) + 150;
			swagShit.screenCenter(X);
			add(swagShit);
		}

		hasTextDisplayed = true;
	}

	public function addText(text:String, ?forceAdd:Bool = false):Void {
		if (!hasTextDisplayed) {
			if (!forceAdd)
				return createText(text.split("\n"));
			else // ensure there's stuff to see.
				hasTextDisplayed = true;
		}

		final moneyMoney:Alphabet = new Alphabet(0, 0, text, BOLD, CENTER);
		moneyMoney.y += (this.members.length * 65) + 150;
		moneyMoney.screenCenter(X);
		add(moneyMoney);
	}

	public function deleteText():Void {
		this.clear();
		hasTextDisplayed = false;
	}
}
