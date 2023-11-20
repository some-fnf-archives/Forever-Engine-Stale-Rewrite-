package funkin.states.options;

import flixel.FlxSubState;

@:access(Conductor)
@:allow(funkin.states.menus.OptionsMenu)
class OffsetMenu extends FlxSubState {
    public function new():Void {
        super(0xFF000000);
        _bgSprite.alpha = 0.0;

        Conductor.onBeat.add(beatHit);

        FlxTween.tween(_bgSprite, {alpha: 0.6}, 0.5);
    }

    public override function update(elapsed:Float):Void {
        if (Controls.BACK)
            close();
    }

    public function beatHit(beat:Int):Void {
        // *
        FlxG.sound.play(Paths.sound("metronome"));
        // *
    }
}