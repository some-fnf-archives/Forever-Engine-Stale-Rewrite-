package funkin.states.menus;

import funkin.states.base.BaseMenuState;
import funkin.states.menus.FreeplayMenu.FreeplaySong;

class StoryMenu extends BaseMenuState {
	public final weeks:Array<StoryWeek> = [
		//
	];
}

@:structInit class StoryWeek {
	public var tagline:String = "My Week";
	public var songs:Array<FreeplaySong> = null;
	public var image:String = "week1";

	public var characters:String = null;
	public var difficulties:Array<String> = null;
}
