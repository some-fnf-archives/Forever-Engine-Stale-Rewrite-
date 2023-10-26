package forever.core.events;

class CancellableEvent {
	public var cancelled:Bool = false;

	public function new():Void {
		cancelled = false;
	}

	public function cancel():Void {
		cancelled = true;
	}
}
