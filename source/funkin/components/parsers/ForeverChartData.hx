package funkin.components.parsers;

/**
 * Structure for the Conductor to use to adjust itself to tailor the song,
 * 
 * Contains BPM and Time Signature Information, along with additional helper data.
**/
@:structInit class ForeverSongData {
	/** Declares how many beats per minute there are in a song. **/
	public var beatsPerMinute:Float = 100.0;

	/** Declares how many steps there are in a beat (time signatures part 1). **/
	public var stepsPerBeat:Int = 4;

	/** Declares how many steps there are in a bar/measure (time signatures part 2). **/
	public var beatsPerBar:Int = 4;
}

@:structInit class ForeverGameplayData { // :3

	/** Declares the gameplay's note speed. **/
	public var noteSpeed:Float = 1.0; // default speed btw.

	/** Declares your player character. **/
	public var player:String = "bf";

	/** Declares the enemy character. **/
	public var enemy:String = "dad";

	/** Declares the game's spectator character (gf). **/
	public var crowd:String = "gf";

	/** Declares the game's background/stage during gameplay. **/
	public var stageBG:String = null;
}

@:structInit class NoteData {
	/** Time (in seconds) for when the note spawns. **/
	public var time:Float;

	/** Direction of the note. **/
	public var dir:Int;

	/** The note's target notefield. **/
	public var notefield:Int;

	/** Type of the note. **/
	public var type:String = null;

	/** The length of the note's hold/sustain. **/
	public var holdLen:Float = 0.0;

	/** The note's animation, acts as a suffix if it starts with "-" **/
	public var animation:String = null;
}

@:structInit class NoteFieldData {}

typedef ChartEvent<T> = {
	var event:T;
	var time:Float;
	var delay:Float;
}

enum ForeverEvents {
	BPMChange(nextBPM:Float);
	PlayAnimation(who:Int, animation:String);
	ChangeCharacter(who:Int, toCharacter:String);
	FocusCamera(who:Int, noEasing:Bool);
	PlaySound(soundName:String, volume:Float);

	/**
	 * HScript Event
	 *
	 * @param name 		Name (in the chart editor).
	 * @param script	Script to run for the event.
	 * @param args 		Arguments for the event.
	**/
	Scripted(name:String, script:String, args:Array<String>);
}
