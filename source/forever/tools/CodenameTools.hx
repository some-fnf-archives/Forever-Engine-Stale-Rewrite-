package forever.tools;

import haxe.xml.Access;
import forever.display.ForeverSprite;

enum abstract ErrorCode(Int) {
	var OK = 0;
	var FAILED = 1;
	var MISSING_PROPERTY = 2;
	var TYPE_INCORRECT = 3;
	var VALUE_NULL = 4;
	var REFLECT_ERROR = 5;
}

class CodenameTools {
	public static function addXMLAnimation(sprite:FlxSprite, anim:Access, loop:Bool = false):ErrorCode {
		// var animType:XMLAnimType = NONE;
		// if (sprite is FunkinSprite)
		//	animType = cast(sprite, FunkinSprite).spriteAnimType;

		return addAnimToSprite(sprite, extractAnimFromXML(anim, /*animType, */ loop));
	}

	public static function extractAnimFromXML(anim:Access, /*animType:XMLAnimType = NONE, */ loop:Bool = false):AnimData {
		var animData:AnimData = {
			name: null,
			anim: null,
			fps: 24,
			loop: loop,
			// animType: animType,
			x: 0,
			y: 0,
			indices: []
		};

		if (anim.has.name)
			animData.name = anim.att.name;
		// if (anim.has.type) animData.animType = XMLAnimType.fromString(anim.att.type, animData.animType);
		if (anim.has.anim)
			animData.anim = anim.att.anim;
		if (anim.has.fps)
			animData.fps = Std.parseFloat(anim.att.fps);
		if (anim.has.x)
			animData.x = Std.parseFloat(anim.att.x);
		if (anim.has.y)
			animData.y = Std.parseFloat(anim.att.y);
		if (anim.has.loop)
			animData.loop = anim.att.loop == "true";
		if (anim.has.indices) {
			var indicesSplit = anim.att.indices.split(",");
			for (indice in indicesSplit) {
				var i = Std.parseInt(indice.trim());
				if (i != null)
					animData.indices.push(i);
			}
		}

		return animData;
	}

	public static function addAnimToSprite(sprite:FlxSprite, animData:AnimData):ErrorCode {
		if (animData.name != null && animData.anim != null) {
			if (animData.fps <= 0 #if web || animData.fps == null #end)
				animData.fps = 24;

			// if (sprite is FunkinSprite && cast(sprite, FunkinSprite).animateAtlas != null) {
			//	var animateAnim = cast(sprite, FunkinSprite).animateAtlas.anim;
			//	if (animData.indices.length > 0)
			//		animateAnim.addBySymbolIndices(animData.name, animData.anim, animData.indices, animData.fps, animData.loop);
			//	else
			//		animateAnim.addBySymbol(animData.name, animData.anim, animData.fps, animData.loop);
			// } else {
			// addAtlasAnim(animData.name, animData.anim, animData.fps, animData.loop, animData.indices);
			if (animData.indices.length > 0)
				sprite.animation.addByIndices(animData.name, animData.anim, animData.indices, "", animData.fps, animData.loop);
			else
				sprite.animation.addByPrefix(animData.name, animData.anim, animData.fps, animData.loop);
			// }

			if (sprite is ForeverSprite)
				cast(sprite, ForeverSprite).setOffset(animData.name, animData.x, animData.y);

			/*if (sprite is FunkinSprite) {
				var xmlSpr = cast(sprite, FunkinSprite);
				switch(animData.animType) {
					case BEAT:
						xmlSpr.beatAnims.push(animData.name);
					case LOOP:
						xmlSpr.animation.play(animData.name);
					default:
						// nothing
				}
				xmlSpr.animDatas.set(animData.name, animData);
			}*/
			return OK;
		}
		return MISSING_PROPERTY;
	}

	/*
	 * Returns `v` if not null, `defaultValue` otherwise.
	 * @param v The value
	 * @param defaultValue The default value
	 * @return The return value
	 */
	public static inline function getDefault<T>(v:Null<T>, defaultValue:T):T {
		return (v == null || isNaN(v)) ? defaultValue : v;
	}

	/**
	 * Whenever a value is NaN or not.
	 * @param v Value
	 */
	public static inline function isNaN(v:Dynamic) {
		if (v is Float || v is Int)
			return Math.isNaN(cast(v, Float));
		return false;
	}
}

typedef AnimData = {
	var name:String;
	var anim:String;
	var fps:Float;
	var loop:Bool;
	var x:Float;
	var y:Float;
	var indices:Array<Int>;
	// var animType:XMLAnimType;
}
