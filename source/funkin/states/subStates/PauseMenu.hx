package funkin.states.subStates;

import flixel.FlxSubState;
import flixel.tweens.FlxTween;
import flixel.group.FlxGroup.FlxTypedGroup;
import funkin.states.menus.*;
import funkin.components.ui.Alphabet;

@:access(funkin.states.PlayState)
class PauseMenu extends FlxSubState{
    var bg:FlxSprite;
    var pauseItens:Array<String> = [
        'Resume',
        'Restart Song',
        'Options',
        'Exit to menu'
    ];
    var pauseGroup:FlxTypedGroup<Alphabet>;
    var selected:Int = 0;

    var closing:Bool; // isso impede de crashar caso aperte ESCAPE/BACKSPACE mais de uma vez

    public function new():Void {
        super();
    }
    
    public override function create() {
        super.create();

        closing = true;
        bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
        add(bg);
        bg.alpha = 0;
        FlxTween.tween(bg, {alpha:0.3}, 0.5, {ease: FlxEase.expoIn, onComplete: function (twn:FlxTween) {
            closing = false;        
            updOptions(0);    
        }});

        pauseGroup = new FlxTypedGroup<Alphabet>();
        add(pauseGroup);

        for (i in 0...pauseItens.length) {
            var option:Alphabet = new Alphabet(0, 100 + (60*i), pauseItens[i]);
            option.isMenuItem = true;
            option.alpha = 0;
            option.targetY = i;
            FlxTween.tween(option, {alpha:0.6}, 0.5, {ease: FlxEase.expoIn});
            pauseGroup.add(option);
        }
    }

    public override function update(elapsed:Float) {
        super.update(elapsed);
        if ((FlxG.keys.justPressed.ESCAPE || FlxG.keys.justPressed.BACKSPACE) && !closing) {
            resumeSong();
        }
        if (FlxG.keys.justPressed.UP)
            updOptions(-1);
        if (FlxG.keys.justPressed.DOWN)
            updOptions(1);
        if (FlxG.keys.justPressed.ENTER) {
            switch (selected) {
                case 0:
                    resumeSong();
                case 1: 
                    FlxG.resetState();
                case 3:
                    FlxG.sound.music.stop();
                    FlxG.switchState(new FreeplayMenu());
            }
        }
    }

    function resumeSong() {
        closing = true;
        for (i in 0...pauseGroup.members.length) {
            FlxTween.tween(pauseGroup.members[i], {alpha:0}, 0.5, {ease: FlxEase.expoIn});
        }

        FlxTween.tween(bg, {alpha:0}, 0.5, {ease: FlxEase.expoIn, onComplete: function(twn:FlxTween) {
            FlxG.state.closeSubState();    
        }});
        
    }

    function updOptions(upd:Int) {
        selected = selected + upd;
        if (selected < 0)
            selected = 0;
        else if (selected > pauseItens.length-1)
            selected = pauseItens.length-1;
        else{
            if (upd != 0)
                FlxG.sound.play(AssetHelper.getAsset('music/sfx/scrollMenu', SOUND));
            for (i in 0...pauseGroup.members.length) {
                pauseGroup.members[i].targetY = pauseGroup.members[i].targetY - upd;
                if (pauseGroup.members[i].targetY == 0)
                    pauseGroup.members[i].alpha = 1;
                else
                    pauseGroup.members[i].alpha = 0.6;
            }
        }
    }
}