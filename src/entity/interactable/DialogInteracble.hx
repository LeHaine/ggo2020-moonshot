package entity.interactable;

import h2d.Flow.FlowAlign;

class DialogInteracble extends Interactable {
	var onInteract:() -> Void;

	public function new(x:Int, y:Int, ?text:String = "", onInteract:() -> Void) {
		super(x, y);
		this.onInteract = onInteract;
		focusRange = 3.2;
		createWindow(text);
		wrapper.y -= M.ceil(wrapper.outerHeight * 1.35);
	}

	private function createWindow(text:String) {
		window.maxWidth = 200;
		window.horizontalAlign = FlowAlign.Middle;
		new HSprite(Assets.tiles, "keyE", window);
		var title = new h2d.Text(Assets.fontPixel, window);
		title.text = text;
		wrapper.x -= wrapper.outerWidth / 2;
	}

	override function interact(by:Hero) {
		super.interact(by);
		onInteract();
	}
}
