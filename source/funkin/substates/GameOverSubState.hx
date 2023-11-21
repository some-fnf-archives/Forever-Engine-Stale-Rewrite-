package funkin.substates;

import funkin.states.PlayState;
import flixel.FlxSubState;

import funkin.states.menus.MainMenu;
import funkin.states.menus.FreeplayMenu;

class GameOverSubState extends FlxSubState {
    public function new() {
        super();

        final bg = new FlxSprite().makeSolid(FlxG.width, FlxG.height, 0xFF000000);
		bg.antialiasing = false;
		add(bg);

        FlxG.sound.play(AssetHelper.getAsset('audio/sfx/gameOver', SOUND));
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
        if (Controls.BACK || Controls.ACCEPT) {
            camera.fade(FlxColor.BLACK, 0.0000000001);
            
            if (Controls.BACK) {
                if (FlxG.sound.music != null) FlxG.sound.music.stop();
                FlxG.switchState(new FreeplayMenu());
            }
            else FlxG.switchState(new PlayState(PlayState.current.songMeta));
        }

    }
}