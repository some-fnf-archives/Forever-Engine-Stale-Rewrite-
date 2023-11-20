package funkin.states.base;

import flixel.math.FlxMath;

/**
 * Helper Class to assist in the creation of custom menus.
**/
class BaseMenuState extends FNFState {
	/** Your current selected item. **/
	public var curSel:Int = 0;

	/** Your alternative selected item **/
	public var curSelAlt:Int = 0;

	/** If you can scroll through items (up and down selection) **/
	public var canChangeSelection:Bool = true;

	/** If you can scroll through items (left and right selection) **/
	public var canChangeAlternative:Bool = false;

	/** If pressing the "accept" button actually does something. **/
	public var canAccept:Bool = true;

	/** If pressing the "cancel" button actually does something. **/
	public var canBackOut:Bool = true;

	/** How many selectors there are **/
	public var maxSelections:Int = 0;

	/** How many horizontal selecotrs there are **/
	public var maxSelectionsAlt:Int = 0;

	/** Your confirm button callback **/
	public var onAccept:Void->Void = null;

	/** Your cancel button callback **/
	public var onBack:Void->Void = null;

	override function update(elapsed:Float):Void {
		super.update(elapsed);

		if (canChangeSelection) {
			final pressUp:Bool = Controls.UI_UP_P;
			final pressDown:Bool = Controls.UI_DOWN_P;

			if (pressUp || pressDown)
				updateSelection(pressUp ? -1 : 1);
		}

		if (canChangeAlternative) {
			final pressLeft:Bool = Controls.UI_LEFT_P;
			final pressRight:Bool = Controls.UI_RIGHT_P;

			if (pressLeft || pressRight)
				updateSelectionAlt(pressLeft ? -1 : 1);
		}

		if (canAccept && Controls.ACCEPT) {
			if (onAccept != null)
				onAccept();
		}

		if (canBackOut && Controls.BACK) {
			if (onBack != null)
				onBack();
		}
	}

	/**
	 * Updates your current selected item
	 * @param newSel        By how much should the current selection be increment/decremented?
	**/
	public function updateSelection(newSel:Int = 0):Void {
		curSel = FlxMath.wrap(curSel + newSel, 0, maxSelections);
	}

	/**
	 * Updates your alternative selected item
	 * @param newSelAlt     By how much should the alternative selection be increment/decremented?
	**/
	public function updateSelectionAlt(newSelAlt:Int = 0):Void {
		curSelAlt = FlxMath.wrap(curSelAlt + newSelAlt, 0, maxSelectionsAlt);
	}
}
