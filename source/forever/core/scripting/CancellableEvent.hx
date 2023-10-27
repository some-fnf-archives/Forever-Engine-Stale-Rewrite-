package forever.core.scripting;

class CancellableEvent {
	public var cancelled:Bool = false;

	public function new():Void {
		cancelled = false;
	}

	public function cancel():Void {
		cancelled = true;
	}
}
