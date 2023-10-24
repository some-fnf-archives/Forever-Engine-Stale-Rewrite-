package funkin.components;

class DifficultyHelper {
	public static final defaults:Array<String> = ["easy", "normal", "hard"];
	public static var currentList:Array<String> = defaults;

	public inline static function changeList(newList:Array<String>):Void {
		currentList = newList;
	}

	public inline static function toString(id:Int):String {
		return currentList[id];
	}
}
