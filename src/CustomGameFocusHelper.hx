import dn.heaps.GameFocusHelper;

class CustomGameFocusHelper extends GameFocusHelper {
	var onResume:Null<() -> Void>;

	public function new(s:h2d.Scene, font:h2d.Font, ?resumeCb:() -> Void) {
		super(s, font);
		onResume = resumeCb;
	}

	override function resumeGame() {
		super.resumeGame();
		if (onResume != null) {
			delayer.addS("reusme", onResume, 0.1);
		}
	}
}
