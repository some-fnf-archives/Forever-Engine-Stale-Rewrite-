package funkin.objects;

import flixel.group.FlxGroup;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.math.FlxMath;

import forever.display.ForeverText;
import forever.display.RecycledSpriteGroup;

import funkin.components.ChartLoader.Chart;
import funkin.components.Timings;
import funkin.components.parsers.ForeverChartData.NoteData;
import funkin.objects.play.*;
import funkin.states.PlayState;
import funkin.ui.HealthBar;
import funkin.ui.HealthIcon;

import haxe.ds.Vector;

/**
 * Play Field contains basic objects to handle gameplay
 * Note Fields, Notes, etc.
**/
class PlayField extends FlxGroup {
	private var play(get, never):PlayState;

	public var skin(get, never):String;
	public static var isPixel(get, never):Bool;

	public var strumLines:Array<StrumLine> = [];
	public var plrStrums:StrumLine;
	public var enmStrums:StrumLine;

	public var noteGroup:FlxTypedSpriteGroup<Note>;
	public var splashGroup:RecycledSpriteGroup<NoteSplash>;

	public var paused:Bool = false;
	public var noteList:Vector<NoteData>;
	public var curNote:Int = 0;

	// -- UI NODES -- //
	public var scoreBar:ForeverText;
	public var centerMark:ForeverText;

	public var healthBar:HealthBar;
	public var iconP1:HealthIcon;
	public var iconP2:HealthIcon;

	public function new():Void {
		super();

		final strumY:Float = Settings.downScroll ? FlxG.height - 150 : 50;
		final speed:Float = Chart.current.gameInfo.noteSpeed;

		add(enmStrums = new StrumLine(this, 100, strumY, speed, skin, true));
		add(plrStrums = new StrumLine(this, FlxG.width - 550, strumY, speed, skin, false));

		if (Settings.centerStrums) {
			enmStrums.visible = false;
			plrStrums.x = (FlxG.width - plrStrums.width) * 0.5;
		}

		add(noteGroup = new FlxTypedSpriteGroup<Note>());
		add(splashGroup = new RecycledSpriteGroup<NoteSplash>());

		final hbY:Float = Settings.downScroll ? FlxG.height * 0.1 : FlxG.height * 0.875;

		add(healthBar = new HealthBar(0, hbY));
		healthBar.screenCenter(X);

		add(iconP1 = new HealthIcon(PlayState.current?.player?.icon ?? "face", true));
		add(iconP2 = new HealthIcon(PlayState.current?.enemy?.icon ?? "face", false));
		for (i in [iconP1, iconP2]) i.y = healthBar.y - (i.height * 0.5);

		centerMark = new ForeverText(0, (Settings.downScroll ? FlxG.height - 40 : 15), 0, '- ${play.currentSong.display} [${play.currentSong.difficulty.toUpperCase()}] -', 20);
		centerMark.alignment = CENTER;
		centerMark.borderSize = 2.0;
		centerMark.screenCenter(X);
		add(centerMark);

		scoreBar = new ForeverText(healthBar.x - healthBar.width - 190, healthBar.y + 40, Std.int(healthBar.width + 150), "", 18);
		scoreBar.alignment = CENTER;
		scoreBar.borderSize = 1.5;
		add(scoreBar);

		updateScore();

		noteList = new Vector<NoteData>(Chart.current.notes.length);

		var allocateThisMany:Int = 5; // remind me to make this be higher depending on the note count of a song
		// allocate notes before beginning
		var i:Int = 0;
		while (i < allocateThisMany) {
			var oi = new Note();
			noteGroup.add(oi);
			oi.kill();
			i++;
		}

		// I know this is dumb as shit and I should just make a group but I don't wanna lol
		forEachOfType(StrumLine, function(n:StrumLine) strumLines.push(n));
		// also arrays are just easier to iterate !!!

		for (i in 0...Chart.current.notes.length)
			noteList[i] = Chart.current.notes[i];
	}

	override function destroy():Void {
		for (strumLine in strumLines)
			strumLine.destroy();
		noteGroup.destroy();
		splashGroup.destroy();
		super.destroy();
	}

	override function update(elapsed:Float):Void {
		healthBar.bar.percent = Timings.health * 50;

		while (!paused && noteGroup != null && noteList.length != 0 && curNote != noteList.length) {
			var unspawnNote:NoteData = noteList[curNote];
			if (unspawnNote == null) {
				curNote++; // skip
				break;
			}
			var strum:StrumLine = strumLines[unspawnNote.lane];
			if (strum == null) {
				curNote++; // skip
				break;
			}
			final timeDifference:Float = unspawnNote.time - Conductor.time;
			if (timeDifference > 1.5 / (strum.members[unspawnNote.dir].speed / Conductor.rate)) // 1500 / (scrollSpeed / rate)
				break;

			var epicNote:Note = noteGroup.recycle(Note);
			epicNote.parent = strumLines[unspawnNote.lane];
			epicNote.appendData(unspawnNote);
			add(epicNote);

			curNote++;
		}

		super.update(elapsed);
	}

	public var divider:String = " • ";

	public dynamic function updateScore():Void {
		if (scoreBar == null) return;

		var tempScore:String = 'Score: ${Timings.score}' //
		+ divider + 'Accuracy: ${FlxMath.roundDecimal(Timings.accuracy, 2)}%' //
		+ divider + 'Combo Breaks: ${Timings.comboBreaks}' //
		+ divider + 'Rank: ${Timings.rank}';

		scoreBar.text = '< ${tempScore} >\n';
		scoreBar.screenCenter(X);

		#if DISCORD
		if (play != null)
			DiscordRPC.updatePresence('Playing: ${play.currentSong.display}', '${scoreBar.text}');
		#end
	}

	public function onBeat(beat:Int):Void {
		for (icon in [iconP1, iconP2])
			icon.doBump(beat);
	}

	public function getHUD():Array<FlxSprite>
		return [healthBar, iconP1, iconP2, scoreBar, centerMark];

	// -- GETTERS & SETTERS, DO NOT MESS WITH THESE -- //

	function get_play():PlayState { return PlayState.current; }
	function get_skin():String return Chart.current.gameInfo.skin ?? "normal";

	static function get_isPixel():Bool
		return Chart.current.gameInfo.skin == "pixel" || Chart.current.gameInfo.skin.endsWith("-pixel");
}
