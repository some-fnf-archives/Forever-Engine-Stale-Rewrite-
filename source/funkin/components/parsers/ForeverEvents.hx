package funkin.components.parsers;

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
