package funkin.states.options;

import forever.tools.ControlsFormatter;
import flixel.FlxSubState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import forever.display.ForeverText;
import haxe.ds.StringMap;
import openfl.Vector;

using flixel.util.FlxSpriteUtil;

@:allow(funkin.states.menus.OptionsMenu)
class ControlsMenu extends FlxSubState {
    public var curSel:Int = 0;
    public var isBinding:Bool = false;

    public function new():Void {
        super();
    }

    final descriptors:StringMap<String> = [
        // -- SEPARATORS --
        'NOTES' => 'YOUR CONTROLS WHEN YOU ARE PLAYING.',
        'USER INTERFACE' => 'YOUR CONTROLS WHEN ACCESS ANY MENU.',
        'DEBUG' => 'OTHER CONTROLS IN GENERAL.',
        // -- KEYS --
    ];

    // order: categories, controls list
    public var maxListItems:Vector<Int> = new Vector<Int>(2);

    public var grpOptions:FlxTypedGroup<ForeverText>;
    public var grpControls:FlxTypedGroup<ForeverText>;
    public var grpDescriptions:FlxTypedGroup<ForeverText>;

    var editing:Bool = false;
    
    override function create():Void {
        super.create();

        // -- VISUALS -- //

        final wbg:FlxSprite = new FlxSprite(47, 47).makeSolid(FlxG.width - 94, FlxG.height - 94);
        add(wbg);

        final bg:FlxSprite = new FlxSprite(50, 50).makeSolid(FlxG.width - 100, FlxG.height - 100, FlxColor.BLACK);
        bg.alpha = 0.8;
        add(bg);

        final titleText:ForeverText = new ForeverText(0, 60, bg.width, "Controls", 40);
        titleText.alignment = CENTER;
        add(titleText);

        add(grpOptions = new FlxTypedGroup<ForeverText>());
        add(grpControls = new FlxTypedGroup<ForeverText>());
        add(grpDescriptions = new FlxTypedGroup<ForeverText>());

        // -- OPTIONS -- //

        final optionsList:Array<Array<String>> = Controls.current.keyOrder;

        for (i in 0...optionsList.length) {
            final initY:Float = titleText.y + 80;
            final isCategory:Bool = optionsList[i].length == 1;

            for (j in 0...optionsList[i].length) {
                // no need to export blank or null keys
                if (optionsList[i][j] == "" || optionsList[i][j] == null) continue;

                final hasDesc:Bool = descriptors.exists(optionsList[i][j]);

                final optionName:ForeverText = new ForeverText(0, 0, 0, "", 48);
                optionName.text = ControlsFormatter.format(optionsList[i][j]).toUpperCase();
                
                if (isCategory) { // CATEGORIES
                    optionName.setPosition(130, initY + (60 * i));
                    maxListItems[0]++;
                    grpOptions.add(optionName);
                } else { // ACTUAL CONTROLS
                    optionName.setPosition(FlxG.width * 0.5 + 30, initY + (60 * j));
                    maxListItems[1]++;
                    grpControls.add(optionName);
                }

                grpDescriptions.add(!hasDesc ? null : new ForeverText(FlxG.width * 0.5 + 30, initY, FlxG.width * 0.4, descriptors.get(optionsList[i][j]), 40));
            }
        }
        trace(maxListItems);

        updateText();
        /*
                        CONTROLS

        NOTES <         |   YOUR CONTROLS WHEN YOU ARE PLAYING.
        USER INTERFACE  |   YOUR CONTROLS WHEN ACCESS ANY MENU. 
        ADDITIONAL      |   OTHER CONTROLS IN GENERAL.

                        CONTROLS

        NOTES <editing>   | > LEFT: (left_p) <
        USER INTERFACE    | DOWN: (down_p)
        ADDITIONAL        | UP: (up_p)
                          | RIGHT: (right_p)
        */
    }

    function updateText():Void {    
        final optionsList:Array<Array<String>> = Controls.current.keyOrder;
        for (i in 0...grpOptions.length) {
            if (grpDescriptions.members[i] != null) grpDescriptions.members[i].visible = i == curSel;
            if (i == curSel) grpOptions.members[i].text = "> " + optionsList[i][0];
            else grpOptions.members[i].text = optionsList[i][0];
        }
        if(editing){
            grpControls.visible = true;
            grpDescriptions.visible = false;
        }
        else{
            grpControls.visible = false;
            grpDescriptions.visible = true;
        }
    }
    
    function updateSelection(newSel:Int = 0):Void {
        curSel = FlxMath.wrap(curSel + newSel, 0, maxListItems[(!isBinding ? 0 : 1)] - 1);
        updateText();
	}

    override function update(elapsed:Float):Void {
        super.update(elapsed);

        if (Controls.UI_UP_P || Controls.UI_DOWN_P)
            updateSelection(Controls.UI_UP_P ? -1 : 1);

        if (Controls.BACK) {
            // Settings.saveControls();
            if (!editing)
                close();
            else{
                editing = false;
                updateText();
            }
        }
        if (Controls.ACCEPT && editing == false) {
            editing = true;
            updateText();
        }
    }
}
