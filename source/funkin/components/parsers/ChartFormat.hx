package funkin.components.parsers;

/**
 * Structure for the Conductor to use to adjust itself to tailor the song,
 * 
 * Contains BPM and Time Signature Information, along with additional helper data.
**/
@:structInit class BeatSignature {
	/** Declares how many beats per minute there are in a song. **/
	public var beatsPerMinute:Float = 100.0;

	/** Declares how many steps there are in a beat (time signatures part 1). **/
	public var stepsPerBeat:Int = 4;

	/** Declares how many steps there are in a bar/measure (time signatures part 2). **/
	public var beatsPerBar:Int = 4;
}

@:structInit class GameplayData { // :3
	/** Declares the gameplay's note speed. **/
	public var noteSpeed:Float = 1.0;

	/** Declares your chart characters, in order, player, enemy, crowd. **/
	public var chars:Array<String> = ["bf", "dad", "gf"];

	/** Declares the game's background/stage during gameplay. **/
	public var stageBG:String = "stage";

	/** Declares the name of the skin used in game. **/
	public var skin:String = "default";
}

typedef NoteData = {
	/** Time (in seconds) for when the note spawns. **/
	var time:Float;

	/** Direction of the note. **/
	var dir:Int;

	/** The note's target strumline. **/
	@:optional var lane:Int;

	/** Type of the note. **/
	@:optional var type:String;

	/** The length of the note's hold/sustain. **/
	@:optional var holdLen:Float;

	/** The note's animation, acts as a suffix if it starts with "-" **/
	@:optional var animation:String;
}

typedef ChartEvent<T:ForeverEvents> = {
	var event:T;
	var time:Float;
}
