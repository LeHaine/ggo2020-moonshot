package entity.interactable;

import ui.ModStationWindow;
import h2d.Flow.FlowAlign;

class ModStationInteractable extends Interactable {
	var onItemBought:() -> Void;

	public function new(x:Int, y:Int, onItemBought:() -> Void) {
		super(x, y);
		this.onItemBought = onItemBought;
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

	override function interact(by:Hero) {
		super.interact(by);
		new ModStationWindow(0, onItemBought);
	}
}
