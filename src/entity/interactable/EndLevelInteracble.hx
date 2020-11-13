package entity.interactable;

import h2d.Flow.FlowAlign;

class EndLevelInteracble extends Interactable {
	var onEndLevel:() -> Void;

	public function new(x:Int, y:Int, onEndLevel:() -> Void) {
		super(x, y);
		this.onEndLevel = onEndLevel;
		focusRange = 3.2;
		createWindow();
	}

	private function createWindow() {
		window.maxWidth = 200;
		window.horizontalAlign = FlowAlign.Middle;
		new HSprite(Assets.tiles, "keyE", window).scale(2);
		var title = new h2d.Text(Assets.fontPixel, window);
		title.text = "Proceed";
		wrapper.x -= wrapper.outerWidth / 2;
	}

	override function interact(by:Hero) {
		super.interact(by);
		onEndLevel();
	}
}
