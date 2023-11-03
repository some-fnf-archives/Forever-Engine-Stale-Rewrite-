package funkin.objects;

import flixel.group.FlxSpriteGroup;
import flixel.math.FlxPoint;
import forever.core.scripting.HScript;
import forever.display.ForeverSprite;
import haxe.ds.StringMap;

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

	var stageObjects:StringMap<ForeverSprite> = new StringMap<ForeverSprite>();
	var scriptModule:HScript = null;

	public function new(stageName:String = "", cameraZoom:Float = 1.05, hudZoom:Float = 1.0):Void {
		super();

		if (stageName != null && stageName.length > 0) {
			if (Tools.fileExists(AssetHelper.getAsset('data/stages/${stageName}', YAML))) {
				var data = AssetHelper.parseAsset('data/stages/${stageName}', YAML);
				cameraZoom = data.cameraZoom ?? 1.05;
				cameraSpeed = data.cameraSpeed ?? 1.0;
				hudZoom = data.hudZoom ?? 1.0;

				playerPosition.x = data.playerPos?.x ?? 770;
				playerPosition.y = data.playerPos?.y ?? 430;

				enemyPosition.x = data.enemyPos?.x ?? 770;
				enemyPosition.y = data.enemyPos?.y ?? 430;

				crowdPosition.x = data.crowdPos?.x ?? 770;
				crowdPosition.y = data.crowdPos?.y ?? 430;

				var objects:Array<Dynamic> = data.objects;
				for (obj in objects) {
					if (obj.name == null) {
						trace('[StageBase:new()]: WARNING, an object that you\'ve tried to create NEEDS a name.');
						continue;
					}

					final newSprite:ForeverSprite = new ForeverSprite(obj.position?.x, obj.position?.y);
					final img:String = 'images/${obj.image}';

					if (Tools.fileExists(AssetHelper.getPath(img, XML)) || Tools.fileExists(AssetHelper.getPath('${img}.txt')))
						newSprite.frames = AssetHelper.getAsset(img, ATLAS);
					else
						newSprite.loadGraphic(AssetHelper.getAsset(img, IMAGE));

					newSprite.alpha = obj.alpha ?? 1.0;
					newSprite.color = obj.color ?? 0xFFFFFFFF;
					newSprite.antialiasing = obj.antialiasing ?? true;

					if (obj.scroll != null) {
						newSprite.scrollFactor.set(obj.scroll?.x ?? 1.0, obj.scroll?.y ?? 1.0);
					}

					if (obj.scale != null) {
						newSprite.scale.set(obj.scale?.x ?? 1.0, obj.scale?.y ?? 1.0);
						newSprite.updateHitbox();
					}
					add(newSprite);

					if (!stageObjects.exists(obj.name))
						stageObjects.set(obj.name, newSprite);
				}
			}
		}

		this.stageName = stageName;
		this.cameraZoom = cameraZoom;
		this.hudZoom = hudZoom;

		// scripts lol
		if (stageName != null && stageName.length > 0) {
			if (Tools.fileExists(AssetHelper.getAsset('data/stages/${stageName}', HSCRIPT))) {
				final curState = cast(FlxG.state, funkin.states.base.FNFState);

				scriptModule = new HScript(AssetHelper.getAsset('data/stages/${stageName}', HSCRIPT));
				// so I don't need to call functions here
				curState.appendToScriptPack(scriptModule);
				scriptModule.set('stage', this);
				scriptModule.set('game', curState);
				scriptModule.call('create', []);
			}
		}
	}

	override function destroy():Void {
		playerPosition?.put();
		enemyPosition?.put();
		crowdPosition?.put();
		super.destroy();
	}
}
