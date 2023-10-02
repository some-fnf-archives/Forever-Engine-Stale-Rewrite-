package forever.data;

#if DISCORD
import hxdiscord_rpc.Discord;
import hxdiscord_rpc.Types.DiscordEventHandlers;
import hxdiscord_rpc.Types.DiscordRichPresence;
import hxdiscord_rpc.Types.DiscordUser;

class DiscordWrapper {
	@:allow(Init)
	function new(clientID:String):Void {
		var evHandler:DiscordEventHandlers = DiscordEventHandlers.create();
		evHandler.ready = cpp.Function.fromStaticFunction(_onReady);
		evHandler.disconnected = cpp.Function.fromStaticFunction(_onDc);
		evHandler.errored = cpp.Function.fromStaticFunction(_onErr);

		Discord.Initialize(Std.string(clientID), cpp.RawPointer.addressOf(evHandler), 1, null);

		// Daemon Thread
		sys.thread.Thread.create(function() {
			while (true) {
				#if DISCORD_DISABLE_IO_THREAD
				Discord.UpdateConnection();
				#end
				Discord.RunCallbacks();

				// Wait 2 seconds until the next loop...
				Sys.sleep(2);
			}
		});

		openfl.Lib.application.onExit.add((exitCode:Int) -> Discord.Shutdown());
	}

	public static function updatePresence(state:String = "", details:String = "", ?largeImage:String = "forevermic", ?largeText:String = null,
			?smallImage:String = "", ?smallText:String = ""):Void {
		final presence:DiscordRichPresence = DiscordRichPresence.create();
		presence.details = details;
		presence.state = state;

		if (largeText == null)
			largeText = 'WIP - v${Main.version}';

		presence.largeImageKey = largeImage;
		presence.largeImageText = largeText;
		presence.smallImageKey = smallImage;
		presence.smallImageText = smallText;

		Discord.UpdatePresence(cpp.RawConstPointer.addressOf(presence));
	}

	static function _onReady(req:cpp.RawConstPointer<DiscordUser>):Void {
		final pointer:cpp.Star<DiscordUser> = cpp.ConstPointer.fromRaw(req).ptr;
		trace('[DiscordWrapper:_onReady] Connection Established, Welcome ${cast (pointer.username)}.');
	}

	static function _onDc(errorCode:Int, message:cpp.ConstCharStar):Void {
		trace('[DiscordWrapper:_onDc] Connection Lost with message: ${message}! - Error Code: ${errorCode}');
	}

	static function _onErr(errorCode:Int, message:cpp.ConstCharStar):Void {
		trace('[DiscordWrapper:_onErr] An Error has occurred, message: ${message}! - Error Code: ${errorCode}');
	}
}
#else

/**
 * This Platform cannot use Discord Rich Presence.
 * thus, this is a stub class.
**/
class DiscordWrapper {
	@:allow(Init)
	function new(clientID:String):Void {}

	public static function updatePresence(state:String = "", details:String = "", ?imageInfo:ImageInfo = null):Void {}
}
#end
