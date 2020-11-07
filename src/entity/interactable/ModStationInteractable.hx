package entity.interactable;

import h2d.Flow.FlowAlign;

class ModStationInteractable extends Interactable {
	public function new(x:Int, y:Int) {
		super(x, y);
		focusRange = 2.2;
		createWindow();
	}

	private function createWindow() {
		window.maxWidth = 200;
		window.horizontalAlign = FlowAlign.Middle;
		new HSprite(Assets.tiles, "keyE", window).scale(2);
		var title = new h2d.Text(Assets.fontPixel, window);
		title.text = "Modify Weapon";
		wrapper.x -= wrapper.outerWidth / 2;
	}
}
