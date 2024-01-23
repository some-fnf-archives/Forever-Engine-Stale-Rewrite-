package meta.dependency;

#if SHOW_DISCORD_RPC
import sys.thread.Thread;
import discord_rpc.DiscordRpc as Dc;
#end

class DiscordRPC {
	public static final clientID:String = "1198503131886141511";

	public static function init() {
		#if SHOW_DISCORD_RPC
		Thread.create(() -> {
			Dc.start({
				clientID: clientID,
				onReady: onReady,
				onError: onError,
				onDisconnected: onDisconnected
			});
			while(true) {
				Dc.process();
				Sys.sleep(2);
			}
			Dc.shutdown();
		});
		FlxG.stage.window.onClose.add(() -> {
			Dc.shutdown();
		});
		Console.log(INFO, "Discord RPC initialized");
		#end
	}

	public static function changePresence(details:String = '', state:Null<String> = '', ?smallImageKey:String, ?hasStartTimestamp:Bool, ?endTimestamp:Float) {
		#if SHOW_DISCORD_RPC
		var startTimestamp:Float = (hasStartTimestamp) ? Date.now().getTime() : 0;

		if (endTimestamp > 0)
			endTimestamp = startTimestamp + endTimestamp;

		Dc.presence({
			details: details,
			state: state,
			largeImageKey: "fe-logo",
			largeImageText: "Forever Engine",
			smallImageKey: smallImageKey,
			// Obtained times are in milliseconds so they are divided so Discord can use it
			startTimestamp: Std.int(startTimestamp / 1000),
			endTimestamp: Std.int(endTimestamp / 1000)
		});
		#end
	}

	private static function onReady() {
		#if SHOW_DISCORD_RPC
		Dc.presence({
			details: 'Title Screen',
			state: null,
			largeImageKey: "fe-logo",
			largeImageText: 'Forever Engine'
		});
		#end
	}

	private static function onError(code:Int, message:String) {
		Console.log(ERROR, 'Discord RPC encountered an error: $message [$code]');
	}

	private static function onDisconnected(code:Int, message:String) {
		Console.log(WARN, 'Discord RPC disconnected: $message [$code]');
	}
}