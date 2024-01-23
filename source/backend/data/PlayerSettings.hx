package backend.system;

enum SettingType {
	CHECKBOX(defaultValue:Bool);
	INTEGER(defaultValue:Int, minValue:Int, maxValue:Int, incValue:Int);
	FLOAT(defaultValue:Float, minValue:Float, maxValue:Float, incValue:Float);
	STRING(defaultValue:String, valueList:Array<String>);
}

class PlayerSettings {
	public static var data:Dynamic<SettingType> = {
		downscroll: CHECKBOX(false)
	};
}