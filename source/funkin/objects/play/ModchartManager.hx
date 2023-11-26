package funkin.objects.play;

import funkin.objects.play.StrumLine.Receptor;

@:structInit class ModchartEvent {
	public var step:Float;
	public var func:StrumLine->Void;
}

/**
 * This is a game component made to assist in the creation of Modcharts.
 *
 * To use it, attach the component to a StrumLine and you will be able to
 * create events and such, along with having neat helper functions for receptors.
**/
class ModchartManager {
	/**
	 * This array stores all the scheduled events that exist
	 * in this instance of the modchart manager.
	**/
	public var storedEvents:Array<ModchartEvent> = [];

	/** The StrumLine attached to this Manager. **/
	public var strumLine:StrumLine;

	/** The receptors present in the StrumLine. **/
	public var receptors:Array<Receptor> = [];

	/**
	 * Constructs the Modchart Manager
	 * @param strumLine         the StrumLine attached to this manager.
	**/
	public function new(strumLine:StrumLine):Void {
		this.strumLine = strumLine;

		this.receptors = strumLine.members.filter(function(receptor:Receptor):Bool {
			return receptor != null && receptor.alive && receptor.exists;
		});
	}
}
