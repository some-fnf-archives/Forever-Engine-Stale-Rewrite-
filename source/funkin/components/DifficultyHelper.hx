package funkin.components;

class DifficultyHelper {
	public static final defaults:Array<String> = ["easy", "normal", "hard"];
	public static var currentList:Array<String> = defaults;

	public static function changeList(newList:Array<String>):Void {
		if (currentList != newList)
			currentList = newList;
	}

	public static function toString(id:Int):String {
		return currentList[id];
	}
}
