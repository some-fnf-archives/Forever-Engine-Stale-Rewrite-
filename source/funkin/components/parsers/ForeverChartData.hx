package funkin.components.parsers;

/**
 * Structure for the Conductor to use to adjust itself to tailor the song,
 * 
 * Contains BPM and Time Signature Information, along with additional helper data.
**/
typedef ForeverSongData = {
	/** Declares how many beats per minute there are in a song. **/
	var beatsPerMinute:Float;

	/** Declares how many steps there are in a beat (time signatures part 1). **/
	var stepsPerBeat:Int;

	/** Declares how many steps there are in a bar/measure (time signatures part 2). **/
	var beatsPerBar:Int;
}

typedef ForeverGameplayData = { // :3

	/** Declares the gameplay's note speed. **/
	var noteSpeed:Float;

	/** Declares your chart characters, in order, player, enemy, crowd. **/
	var chars:Array<String>;

	/** Declares the game's background/stage during gameplay. **/
	var stageBG:String;

	/** Declares the name of the skin used in game. **/
	var skin:String;
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
