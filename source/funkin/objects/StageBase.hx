package funkin.objects;

import flixel.group.FlxSpriteGroup;
import flixel.math.FlxPoint;

class StageBase extends FlxSpriteGroup {
	/** Stage Name Identifier. **/
	public var stageName:String = "stage";

	/** The default zoom of this stage. **/
	public var cameraZoom:Float = 1.05;

	/** The default speed of the camera. **/
	public var cameraSpeed:Float = 1.0;

	/** The default hud zoom of this stage. **/
	public var hudZoom:Float = 1.0;

	/** The default player position **/
	public var playerPosition:FlxPoint = FlxPoint.get(770, 430);

	/** The default enemy position **/
	public var enemyPosition:FlxPoint = FlxPoint.get(100, 100);

	/** The default crowd position **/
	public var crowdPosition:FlxPoint = FlxPoint.get(400, 130);

	public function new(stageName:String = "", cameraZoom:Float = 1.05, hudZoom:Float = 1.0):Void {
		super();

		this.stageName = stageName;
		this.cameraZoom = cameraZoom;
		this.hudZoom = hudZoom;
	}

	public override function destroy():Void {
		playerPosition.put();
		enemyPosition.put();
		crowdPosition.put();

		super.destroy();
	}
}
