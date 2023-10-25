package forever.core;

#if DISCORD
import hxdiscord_rpc.Discord;
import hxdiscord_rpc.Types.DiscordEventHandlers;
import hxdiscord_rpc.Types.DiscordRichPresence;
import hxdiscord_rpc.Types.DiscordUser;

class DiscordWrapper {
	@:allow(Init)
	/**
	 * Initializes the Discord Rich Presence Wrapper.
	 * @param clientID			your app's ClientID, from Discord Developer Portal.
	**/
	static function initialize(clientID:String):Void {
		var evHandler:DiscordEventHandlers = DiscordEventHandlers.create();
		evHandler.ready = cpp.Function.fromStaticFunction(_onReady);
		evHandler.disconnected = cpp.Function.fromStaticFunction(_onDc);
		evHandler.errored = cpp.Function.fromStaticFunction(_onErr);

		Discord.Initialize(Std.string(clientID), cpp.RawPointer.addressOf(evHandler), 1, null);

		// Daemon Thread
		sys.thread.Thread.create(function():Void {
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

	/**
	 * Updates your Discord Rich Presence Status, including icons and text
	 * @param state 				Rich Presence State, e.g: IN FREEPLAY
	 * @param details 				Rich Presence Details, e.g: In the Menus
	 * @param largeImage 			Image that displays when viewing your status on Discord.
	 * @param largeText 			Text that displays when hovering over the large image on Discord.
	 * @param smallImage 			Small image that displays near the large image on Discord.
	 * @param smallText
	**/
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

	@:dox(hide) @:noCompletion
	static function _onReady(req:cpp.RawConstPointer<DiscordUser>):Void {
		final pointer:cpp.Star<DiscordUser> = cpp.ConstPointer.fromRaw(req).ptr;

		var username = if (cast(pointer.discriminator, String) != "0") '${pointer.username}#${pointer.discriminator}'; else '${pointer.username}';

		// lime.app.Application.current.window.alert("Hello " + username + ", i know where you live", "Death");

		trace('[DiscordWrapper:_onReady] Connection Established, Welcome ${username}.');
	}

	@:dox(hide) @:noCompletion
	static function _onDc(errorCode:Int, message:cpp.ConstCharStar):Void {
		trace('[DiscordWrapper:_onDc] Connection Lost with message: ${message}! - Error Code: ${errorCode}');
	}

	@:dox(hide) @:noCompletion
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

	@:dox(hide)
	public static function updatePresence(state:String = "", details:String = "", ?largeImage:String = "forevermic", ?largeText:String = null,
		?smallImage:String = "", ?smallText:String = ""):Void {}
}
#end
