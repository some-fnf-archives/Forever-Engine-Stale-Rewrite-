package funkin.substates;

import flixel.sound.FlxSound;
import funkin.states.PlayState;
import flixel.FlxSubState;

import funkin.states.menus.StoryMenu;
import funkin.states.menus.FreeplayMenu;

import funkin.objects.Character;

import openfl.media.Sound;

@:structInit class GameOverData {
    /** Character that appears when dying. **/
    public var character:String = "bf-dead";
    /** Plays during the game over screen. **/
    public var loopMusic:String = "gameOver";
    /** Plays after hitting the confirm key on the game over screen. **/
    public var confirmSound:String = "gameOverEnd";
    /** Plays when entering the game over screen**/
    public var deathSFX:String = "fnf_loss_sfx";
}

class GameOverSubState extends FlxSubState {
    public var character:Character;
    public var data:GameOverData;

    public function new(?x:Float = 0, ?y:Float = 0, screenData:GameOverData, isPlayer:Bool = true):Void {
        super();

        if (FlxG.sound.music != null)
            FlxG.sound.music.stop();

        Conductor.active = false;
        Conductor.time = 0.0;

        this.data = screenData;

        // checking both the music and sound paths lol -Crow
        var confirmPath:Sound = Paths.music(screenData.confirmSound);
        if (confirmPath == null) Paths.sound(screenData.confirmSound);

        confirmSound = new FlxSound().loadEmbedded(confirmPath);
        confirmSound.persist = true;

        final bg = new FlxSprite().makeSolid(FlxG.width, FlxG.height, 0xFF000000);
		bg.antialiasing = false;
		add(bg);

        add(character = new Character(x, y, screenData.character, isPlayer));
        character.animation.finishCallback = function(name:String):Void {
            switch (name) {
                case "firstDeath":
                    character.playAnim("deathLoop", true);
                    startMusicLoop(1.0);
            }
        }

        FlxG.sound.play(Paths.sound(screenData.deathSFX));
        character.playAnim("firstDeath");

        Conductor.active = true;
    }

    var leaving:Bool = false;
    var isCameraPointing:Bool = false;
    var confirmSound:FlxSound;

    override function update(elapsed:Float) {
        super.update(elapsed);

        if (character.animation.curAnim != null) {
            if (character.animation.curAnim.name == "firstDeath") {
                if (character.animation.curAnim.curFrame >= 12 && !isCameraPointing) {
                    camera.follow(character, LOCKON, 0.35);
                    isCameraPointing = true;
                }
            }
        }

        if (Controls.BACK || Controls.ACCEPT) {
            leaving = true;

            if (Controls.BACK) {
                if (FlxG.sound.music != null) FlxG.sound.music.stop();
                FlxG.switchState(new FreeplayMenu());
            }
            else {
                confirmSound.play(true, 0.0);
                camera.fade(FlxColor.BLACK, 1.5, false, () -> {
                    FlxG.switchState(new PlayState(PlayState.current.songMeta));
                });
            }
        }
    }

    function startMusicLoop(vol:Float = 1.0):Void {
        FlxG.sound.playMusic(Paths.music(data.loopMusic), vol, true);
        if (vol != 1.0 && !leaving) FlxG.sound.music.fadeIn(vol, 1.0, 4.0);
    }
}