package funkin.states.menus;

import funkin.states.base.BaseMenuState;
import funkin.states.menus.FreeplayMenu.FreeplaySong;

enum Week {
    Week(tagline:String, songs:Array<FreeplaySong>, image:String, ?characters:Array<String>, ?difficulties:Array<String>);
}

class StoryMenu extends BaseMenuState {
    public final weeks:Array<Week> = [
        Week("Daddy's Home", [new FreeplaySong("BBG", "bbg", "sans-bgg")], "week0")
    ];
}